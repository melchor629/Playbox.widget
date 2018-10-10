//
//  GetCurrentTrackApp.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 4/1/18.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GetCurrentTrackApp.h"
#import "Network/HTTPServer.h"
#import "Players/Player.h"
#import "Players/SpotifyPlayer.h"
#import "Players/iTunesPlayer.h"
#import "Players/VOXPlayer.h"

#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>

extern volatile bool notInterrupted;
NSString* getBaseDirectory(NSString* extra);

#define checc(v, msg) {if((v) == -1) {NSLog(@"Failed in %s:%d: %s: %s\n", __FILE__, __LINE__, strerror(errno), msg);}}
#define TSTR(x) #x
#define TO_STRING(x) TSTR(x)
#define PORT 45988
#define PORT_STR TO_STRING(PORT)


@implementation GetCurrentTrackApp {
    SongMetadata* last;
    bool songChanged;
    NSString* coverFileUrl, *oldCoverFileUrl;
    NSArray* players;
    NSString* pidFilePath;
    NSString* coverBasePath;
    HTTPServer* server;
}

- (instancetype) initWithArgs: (NSDictionary*) args {
    id _self = [super init];
    NSLog(@"Current working directory: %@", getBaseDirectory(nil));
    last = [[SongMetadata alloc] init];
    //Put here new player implementations
    players = @[
               [[SpotifyPlayer alloc] init],
               [[iTunesPlayer alloc] init],
               [[VOXPlayer alloc] init]
               ];
    songChanged = false;
    pidFilePath = getBaseDirectory(@"Playbox.widget/lib/pidfile");
    coverBasePath = getBaseDirectory(@"Playbox.widget/covers");
    if(mkdir([coverBasePath cStringUsingEncoding:NSUTF8StringEncoding], 0733) != 0) {
        [[NSFileManager defaultManager] removeItemAtPath:coverBasePath error:nil];
        mkdir([coverBasePath cStringUsingEncoding:NSUTF8StringEncoding], 0733);
    }

    pid_t pid = getpid();
    FILE* pidFile = fopen([pidFilePath cStringUsingEncoding:NSUTF8StringEncoding], "w");
    fprintf(pidFile, "%d", pid);
    fclose(pidFile);

    server = [[HTTPServer alloc] init];
    [server setDelegate:self];
    if(![server listenToAddress:@"::1" andPort:PORT]) {
        [NSApp terminate:self];
        exit(1);
    }

    return _self;
}

- (Player*) getPlayingPlayer {
    for(NSUInteger i = 0; i < [players count]; i++) {
        Player* player = [players objectAtIndex:i];
        PlayerStatus status = [player status];
        if(status == PlayerStatusPlaying || status == PlayerStatusPaused) {
            return player;
        }
    }
    return nil;
}

bool areEqualsWithNil(NSString* a, NSString* b) {
    if(a == nil && b != nil) return false;
    if(a != nil && b == nil) return false;
    if(a == nil && b == nil) return true;
    return [a isEqualToString:b];
}

- (bool) didSongChange: (SongMetadata*) current {
    return !(
             areEqualsWithNil(current.artist, last.artist) &&
             areEqualsWithNil(current.name, last.name) &&
             areEqualsWithNil(current.album, last.album)
             );
}

- (bool) didCoverChange: (SongMetadata*) current {
    if(current.album != nil) {
        if(current.albumArtist != nil) {
            return !(areEqualsWithNil(current.albumArtist, last.albumArtist) && areEqualsWithNil(current.album, last.album));
        }
        return !(areEqualsWithNil(current.artist, last.artist) && areEqualsWithNil(current.album, last.album));
    } else {
        return true;
    }
}

- (void) checkForChanges: (Player*) player {
    if(player != nil) {
        SongMetadata* current = [player getMetadata];
        if([self didSongChange:current]) {
            if([self didCoverChange:current]) {
                if(oldCoverFileUrl != nil && ![[oldCoverFileUrl substringToIndex:4] isEqualToString:@"http"]) {
                    NSLog(@"Deleting %@", oldCoverFileUrl);
                    [[NSFileManager defaultManager] removeItemAtPath:oldCoverFileUrl error:nil];
                }
                oldCoverFileUrl = coverFileUrl;
                coverFileUrl = [player getCover: coverBasePath];
            }

            songChanged = true;
        } else {
            songChanged = false;
        }
        last = current;
    }
}

- (void) request: (HTTPRequest*) req withResponse: (HTTPResponse*) res {
    Player* player = [self getPlayingPlayer];
    [self checkForChanges: player];
    NSDictionary* dict = nil;
    if(player != nil) {
        dict = @{
                 @"metadata": [last asDict],
                 @"coverUrl": coverFileUrl ? [coverFileUrl stringByReplacingOccurrencesOfString:getBaseDirectory(nil) withString:@""] : @"/Playbox.widget/lib/default.png",
                 @"songChanged": [NSNumber numberWithBool:songChanged],
                 @"status": [player status] == PlayerStatusPlaying ? @"playing" : @"paused",
                 @"player": [player name]
                 };
    } else {
        dict = @{ @"status": @"stopped" };
    }

    [res setValue:@"application/json; encoding=utf-8" forHeader:@"Content-Type"];
    [res setValue:@"*" forHeader:@"Access-Control-Allow-Origin"];

    [res writeData:[NSJSONSerialization dataWithJSONObject:dict options:0 error:nil]];
    [res end];
}

- (void) cleanup {
    if(oldCoverFileUrl != nil && ![[oldCoverFileUrl substringToIndex:4] isEqualToString:@"http"]) {
        NSLog(@"Deleting %@", oldCoverFileUrl);
        [[NSFileManager defaultManager] removeItemAtPath:oldCoverFileUrl error:nil];
    }
    if(coverFileUrl != nil && ![[coverFileUrl substringToIndex:4] isEqualToString:@"http"]) {
        NSLog(@"Deleting %@", coverFileUrl);
        [[NSFileManager defaultManager] removeItemAtPath:coverFileUrl error:nil];
    }
    [[NSFileManager defaultManager] removeItemAtPath:pidFilePath error:nil];
    [server close];
}

@end

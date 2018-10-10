//
//  GetCurrentTrackApp.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 4/1/18.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GetCurrentTrackApp.h"
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
#define PORT 45987
#define PORT_STR TO_STRING(PORT)


@implementation GetCurrentTrackApp {
    SongMetadata* last;
    bool songChanged;
    NSString* coverFileUrl, *oldCoverFileUrl;
    NSArray* players;
    NSString* pidFilePath;
    NSString* coverBasePath;
}

- (instancetype) init {
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

- (void) loop {
    int sock = socket(PF_INET6, SOCK_STREAM, 0);

    int opt = 1; //Avoid "Address already in use" error
    setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, (char*) &opt, sizeof(opt));

    struct sockaddr_in6 addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin6_family = AF_INET6;
    struct in6_addr a = IN6ADDR_LOOPBACK_INIT;
    memcpy(&addr.sin6_addr, &a, sizeof(addr.sin6_addr));
    addr.sin6_port = htons(PORT);
    checc(bind(sock, (struct sockaddr*) &addr, sizeof(addr)), "Cannot bind to http://[::1]:" PORT_STR);

    listen(sock, 10);
    NSLog(@"Listening at http://[::1]:%s", PORT_STR);

    while(!notInterrupted) {
        int client;
        checc(client = accept(sock, NULL, NULL), "Cannot accept a client :(");
        @autoreleasepool {
            Player* player = [self getPlayingPlayer];
            [self checkForChanges: player];
            NSData* data = nil;
            if(player != nil) {
                id dict = @{
                            @"metadata": [last asDict],
                            @"coverUrl": coverFileUrl ? [coverFileUrl stringByReplacingOccurrencesOfString:getBaseDirectory(nil) withString:@""] : @"/Playbox.widget/lib/default.png",
                            @"songChanged": [NSNumber numberWithBool:songChanged],
                            @"status": [player status] == PlayerStatusPlaying ? @"playing" : @"paused",
                            @"player": [player name]
                            };
                data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
            } else {
                data = [NSJSONSerialization dataWithJSONObject:@{@"status": @"stopped"} options:0 error:nil];
            }
            const char headers[] =
                "HTTP/1.1 200 OK\r\n"
                "Content-Type: application/json; encoding=utf-8\r\n"
                "Access-Control-Allow-Origin: *\r\n"
                "\r\n";
            write(client, headers, sizeof(headers) - 1);
            ssize_t written = 0;
            const void* outData = [data bytes];
            size_t outLen = [data length];
            while(written < outLen) {
                written += write(client, outData + written, outLen - written);
            }
            shutdown(client, SHUT_RDWR);
            close(client);
        }
    }
    close(sock);

    [self cleanup];
    [NSApp terminate: self];
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
}

@end

//
//  GetCurrentTrackApp.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 4/1/18.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

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


@implementation Player
- (bool) isPlaying { return false; }
- (SongMetadata*) getMetadata { return nil; }
- (NSString*) getCover { return nil; }
- (NSString*) name { return nil; }
@end
@implementation SongMetadata
@end


@implementation GetCurrentTrackApp {
    SongMetadata* last;
    bool songChanged;
    NSString* coverFileUrl, *oldCoverFileUrl;
    NSArray* players;
    NSString* pidFilePath;
}

- (instancetype) init {
    id _self = [super init];
    NSLog(@"Current working directory: %@", getBaseDirectory(nil));
    last = [[SongMetadata alloc] init];
    players = [[NSMutableArray alloc] initWithObjects:
               [[SpotifyPlayer alloc] init],
               [[iTunesPlayer alloc] init],
               [[VOXPlayer alloc] init],
               nil];
    songChanged = false;
    pidFilePath = getBaseDirectory(@"Playbox.widget/lib/pidfile");

    pid_t pid = getpid();
    FILE* pidFile = fopen([pidFilePath cStringUsingEncoding:NSUTF8StringEncoding], "w");
    fprintf(pidFile, "%d", pid);
    fclose(pidFile);

    return _self;
}

- (Player*) getPlayingPlayer {
    for(NSUInteger i = 0; i < [players count]; i++) {
        Player* player = [players objectAtIndex:i];
        if([player isPlaying]) {
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
             areEqualsWithNil(current.artistName, last.artistName) &&
             areEqualsWithNil(current.songName, last.songName) &&
             areEqualsWithNil(current.albumName, last.albumName)
             );
}

- (bool) didCoverChange: (SongMetadata*) current {
    if(current.albumName != nil) {
        return !(areEqualsWithNil(current.artistName, last.artistName) && areEqualsWithNil(current.albumName, last.albumName));
    } else {
        return true;
    }
}

- (void) checkForChanges: (Player*) player {
    if(player != nil) {
        SongMetadata* current = [player getMetadata];
        last.currentPosition = current.currentPosition;
        last.isLoved = current.isLoved;
        if([self didSongChange:current]) {
            if([self didCoverChange:current]) {
                if(oldCoverFileUrl != nil && ![[oldCoverFileUrl substringToIndex:4] isEqualToString:@"http"]) {
                    NSLog(@"Deleting %@", oldCoverFileUrl);
                    [[NSFileManager defaultManager] removeItemAtPath:oldCoverFileUrl error:nil];
                }
                oldCoverFileUrl = coverFileUrl;
                coverFileUrl = [player getCover];
            }

            last.artistName = current.artistName;
            last.albumName = current.albumName;
            last.songName = current.songName;
            last.songDuration = current.songDuration;
            last.isLoved = current.isLoved;
            songChanged = true;
        } else {
            songChanged = false;
        }
    }
}

- (void) loop: (bool) daemonized {
    int sock = socket(PF_INET6, SOCK_STREAM, 0);

    int opt = 1; //Avoid "Address already in use" error
    setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, (char*) &opt, sizeof(opt));

    struct sockaddr_in6 addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin6_family = AF_INET6;
    struct in6_addr a = IN6ADDR_LOOPBACK_INIT;
    memcpy(&addr.sin6_addr, &a, sizeof(addr.sin6_addr));
    addr.sin6_port = htons(daemonized ? 45987 : 45988);
    checc(bind(sock, (struct sockaddr*) &addr, sizeof(addr)), "Cannot bind to tcp://[::]:45987");

    listen(sock, 10);

    while(!notInterrupted) {
        int client;
        checc(client = accept(sock, NULL, NULL), "Cannot accept a client :(");
        @autoreleasepool {
            Player* player = [self getPlayingPlayer];
            [self checkForChanges: player];
            NSData* data = nil;
            if(player != nil) {
                id dict = @{
                            @"artistName": [last.artistName length] == 0 ? [NSNull null] : last.artistName,
                            @"songName": [last.songName length] == 0 ? [NSNull null] : last.songName,
                            @"albumName": [last.albumName length] == 0 ? [NSNull null] : last.albumName,
                            @"songDuration": [NSNumber numberWithUnsignedInteger:last.songDuration],
                            @"currentPosition": [NSNumber numberWithUnsignedInteger:last.currentPosition],
                            @"coverUrl": coverFileUrl ? [coverFileUrl stringByReplacingOccurrencesOfString:getBaseDirectory(nil) withString:@""] : [NSNull null],
                            @"songChanged": [NSNumber numberWithBool:songChanged],
                            @"isLoved": [NSNumber numberWithBool:last.isLoved],
                            @"isPlaying": [NSNumber numberWithBool:true],
                            @"player": [player name]
                            };
                data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
            } else {
                data = [NSJSONSerialization dataWithJSONObject:@{@"isPlaying": [NSNumber numberWithBool:false]} options:0 error:nil];
            }
            const char headers[] =
                "HTTP/1.1 200 OK\r\n"
                "Content-Type: application/json; encoding=utf-8\r\n"
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

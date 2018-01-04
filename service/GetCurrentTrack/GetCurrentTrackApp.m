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

- (bool) didSongChange: (SongMetadata*) current {
    return !(
             [current.artistName isEqualToString:last.artistName] &&
             [current.songName isEqualToString:last.songName] &&
             [current.albumName isEqualToString:last.albumName]
             );
}

- (bool) didCoverChange: (SongMetadata*) current {
    return !([current.artistName isEqualToString:last.artistName] && [current.albumName isEqualToString:last.albumName]);
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

- (void) loop {
    checc(mkfifo("/tmp/get_current_track", 0666), "Cannot create FIFO");
    int pipe;
    checc(pipe = open("/tmp/get_current_track", O_RDONLY), "Cannot open FIFO");
    while(!notInterrupted) {
        char buf[1000];
        ssize_t e;
        checc(e = read(pipe, buf, sizeof(buf)), "Cannot read from FIFO");
        close(pipe);
        //NSLog(@"Received request");
        if(e != -1) {
            checc(pipe = open("/tmp/get_current_track", O_WRONLY), "Cannot open FIFO for writing");
            Player* player = [self getPlayingPlayer];
            [self checkForChanges: player];
            NSData* data = nil;
            if(player != nil) {
                id dict = @{
                            @"artistName": last.artistName,
                            @"songName": last.songName,
                            @"albumName": last.albumName,
                            @"songDuration": [NSNumber numberWithUnsignedInteger:last.songDuration],
                            @"currentPosition": [NSNumber numberWithUnsignedInteger:last.currentPosition],
                            @"coverUrl": coverFileUrl ? [coverFileUrl stringByReplacingOccurrencesOfString:getBaseDirectory(nil) withString:@""] : nil,
                            @"songChanged": [NSNumber numberWithBool:songChanged],
                            @"isLoved": [NSNumber numberWithBool:last.isLoved],
                            @"isPlaying": [NSNumber numberWithBool:true],
                            @"player": [player name]
                            };
                data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
            } else {
                data = [NSJSONSerialization dataWithJSONObject:@{@"isPlaying": [NSNumber numberWithBool:false]} options:0 error:nil];
            }
            ssize_t written = 0;
            const void* outData = [data bytes];
            size_t outLen = [data length];
            while(written < outLen) {
                written += write(pipe, outData + written, outLen - written);
            }
            //NSLog(@"Send response: %.*s", (int) outLen, outData);
            close(pipe);
        }
        checc(pipe = open("/tmp/get_current_track", O_RDONLY), "Cannot reopen FIFO for reading");
    }
    close(pipe);
    checc(unlink("/tmp/get_current_track"), "Cannot delete FIFO");
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

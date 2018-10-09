//
//  Player.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 09/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Player.h"


@implementation Player
- (bool) isPlaying { return false; }
- (SongMetadata*) getMetadata { return nil; }
- (NSString*) getCover: (NSString*) path { return nil; }
- (NSString*) name { return nil; }
@end


@implementation SongMetadata

@synthesize artist;
@synthesize name;
@synthesize album;
@synthesize duration;
@synthesize loved;
@synthesize playerPosition;

- (NSDictionary*) asDict {
    return @{
        @"artistName": [artist length] == 0 ? [NSNull null] : artist,
        @"songName": [name length] == 0 ? [NSNull null] : name,
        @"albumName": [album length] == 0 ? [NSNull null] : album,
        @"songDuration": [NSNumber numberWithUnsignedInteger:duration],
        @"currentPosition": [NSNumber numberWithUnsignedInteger:playerPosition],
        @"isLoved": [NSNumber numberWithBool:loved]
    };
}

@end


bool isRunning(NSString* bundleId) {
    NSArray* running = [[NSWorkspace sharedWorkspace] runningApplications];
    NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(NSRunningApplication* evaluatedObject, NSDictionary* bindings) {
        return [[evaluatedObject bundleIdentifier] isEqualToString:bundleId];
    }];
    return 0 < [[running filteredArrayUsingPredicate: predicate] count];
}

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

@synthesize albumArtist;
@synthesize album;
@synthesize artist;
@synthesize discCount;
@synthesize discNumber;
@synthesize duration;
@synthesize genre;
@synthesize loved;
@synthesize name;
@synthesize trackCount;
@synthesize trackNumber;
@synthesize year;
@synthesize playerPosition;

- (instancetype) init {
    return [super init];
}

- (instancetype) initWithDict: (NSDictionary*) dict {
    self = [super init];

    albumArtist = [dict valueForKey:@"albumArtist"];
    album = [dict valueForKey:@"album"];
    artist = [dict valueForKey:@"artist"];
    discCount = [[dict valueForKey:@"discCount"] unsignedIntegerValue];
    discNumber = [[dict valueForKey:@"discNumber"] unsignedIntegerValue];
    duration = [[dict valueForKey:@"duration"] doubleValue];
    genre = [dict valueForKey:@"genre"];
    loved = [[dict valueForKey:@"loved"] boolValue];
    name = [dict valueForKey:@"name"];
    trackCount = [[dict valueForKey:@"trackCount"] unsignedIntegerValue];
    trackNumber = [[dict valueForKey:@"trackNumber"] unsignedIntegerValue];
    year = [[dict valueForKey:@"year"] unsignedIntegerValue];
    playerPosition = [[dict valueForKey:@"position"] doubleValue];

    return self;
}

- (NSDictionary*) asDict {
    return @{
             @"albumArtist": albumArtist ? albumArtist : [NSNull null],
             @"album": album ? album : [NSNull null],
             @"artist": artist ? artist : [NSNull null],
             @"discCount": discCount > 0 ? [NSNumber numberWithUnsignedInteger:discCount] : [NSNull null],
             @"discNumber": discNumber > 0 ? [NSNumber numberWithUnsignedInteger:discNumber] : [NSNull null],
             @"duration": [NSNumber numberWithDouble:duration],
             @"genre": genre ? genre : [NSNull null],
             @"loved": [NSNumber numberWithBool:loved],
             @"name": name ? name : [NSNull null],
             @"trackCount": trackCount > 0 ? [NSNumber numberWithUnsignedInteger:trackCount] : [NSNull null],
             @"trackNumber": trackNumber > 0 ? [NSNumber numberWithUnsignedInteger:trackNumber] : [NSNull null],
             @"year": year > 0 ? [NSNumber numberWithUnsignedInteger:year] : [NSNull null],
             @"position": [NSNumber numberWithDouble:playerPosition]
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

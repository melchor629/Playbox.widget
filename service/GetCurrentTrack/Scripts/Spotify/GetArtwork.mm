//
//  GetArtwork.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 09/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import "GetArtwork.h"

static const char* code = R"AS(
tell application "Spotify"
    with timeout of 0.5 seconds
        artwork url of current track
    end timeout
end tell
)AS";

@implementation SpotifyGetArtworkScript {
    NSAppleScript* script;
}

- (instancetype) init {
    self = [super init];

    script = [[NSAppleScript alloc] initWithSource:[[NSString alloc] initWithUTF8String: code]];
    [script compileAndReturnError:nil];

    return self;
}

- (NSString*) artwork {
    NSAppleEventDescriptor* event = [script executeAndReturnError: nil];
    return [event stringValue];
}

@end

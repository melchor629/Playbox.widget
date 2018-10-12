//
//  GetCurrentTrack.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 09/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import "GetCurrentTrack.h"

extern "C" NSDictionary* pseudoYaml_parse(NSString* yaml);

static const char* code = R"AS(
on getOrNull(value)
    if value is "" or value is 0 then
        return "null"
    else
        return value
    end if
end getOrNull

tell application "VOX"
    "artist: " & my getOrNull(artist) & "
album: " & my getOrNull(album) & "
albumArtist: " & my getOrNull(album artist) & "
duration: " & total time as text & "
name: " & my getOrNull(track) & "
position: " & current time as text
end tell
)AS";


@implementation VOXGetCurrentTrackScript {
    NSAppleScript* script;
}

- (instancetype) init {
    self = [super init];

    script = [[NSAppleScript alloc] initWithSource:[[NSString alloc] initWithUTF8String:code]];
    [script compileAndReturnError:nil];

    return self;
}

- (SongMetadata*) currentTrack {
    NSAppleEventDescriptor* event = [script executeAndReturnError: nil];
    NSString* yaml = [event stringValue];
    NSDictionary* dict = pseudoYaml_parse(yaml);
    return [[SongMetadata alloc] initWithDict:dict];
}


@end

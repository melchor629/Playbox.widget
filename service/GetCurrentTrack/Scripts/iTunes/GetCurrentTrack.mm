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
    if value is "" or value is 0 or value is missing value or value is null then
        return "null"
    else if class of value is text then
        return quote & value & quote
    else
        return value
    end if
end getOrNull

with timeout of 0.5 seconds
tell application "iTunes"
    set t to current track
    "artist: " & my getOrNull(artist of t) & "
album: " & my getOrNull(album of t) & "
albumArtist: " & my getOrNull(album artist of t) & "
discCount: " & my getOrNull(disc count of t) & "
disctNumber: " & my getOrNull(disc number of t) & "
duration: " & duration of t as text & "
genre: " & my getOrNull(genre of t) & "
name: " & my getOrNull(name of t) & "
trackCount: " & my getOrNull(track count of t) & "
trackNumber: " & my getOrNull(track number of t) & "
year: " & year of t & "
position: " & player position as text
end tell
end timeout
)AS";


@implementation iTunesGetCurrentTrackScript {
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
    if(yaml == nil) {
        return nil;
    }
    NSDictionary* dict = pseudoYaml_parse(yaml);
    return [[SongMetadata alloc] initWithDict:dict];
}


@end

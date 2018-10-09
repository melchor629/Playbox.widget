//
//  iTunesGetCurrentTrackScript.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 09/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import "GetCurrentTrack.h"

extern "C" NSDictionary* parse(NSString* yaml);

static const char* code = R"AS(
on getOrNull(value)
    if value is "" or value is 0 then
        return "null"
    else
        return value
    end if
end getOrNull

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
)AS";


@implementation iTunesCurrentTrack
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
@synthesize position;

- (instancetype) initWithDict: (NSDictionary*) dict {
    self = [super init];
    albumArtist = [dict valueForKey:@"albumArtist"];
    album = [dict valueForKey:@"album"];
    artist = [dict valueForKey:@"artist"];
    discCount = [dict valueForKey:@"discCount"];
    discNumber = [dict valueForKey:@"discNumber"];
    duration = [[dict valueForKey:@"duration"] doubleValue];
    genre = [dict valueForKey:@"genre"];
    loved = [[dict valueForKey:@"loved"] boolValue];
    name = [dict valueForKey:@"name"];
    trackCount = [dict valueForKey:@"trackCount"];
    trackNumber = [dict valueForKey:@"trackNumber"];
    year = [dict valueForKey:@"year"];
    position = [[dict valueForKey:@"position"] doubleValue];
    return self;
}
@end

@implementation iTunesGetCurrentTrackScript {
    NSAppleScript* script;
}

- (instancetype) init {
    self = [super init];

    script = [[NSAppleScript alloc] initWithSource:[[NSString alloc] initWithUTF8String:code]];
    [script compileAndReturnError:nil];

    return self;
}

- (iTunesCurrentTrack*) currentTrack {
    NSAppleEventDescriptor* event = [script executeAndReturnError: nil];
    NSString* yaml = [event stringValue];
    NSDictionary* dict = parse(yaml);
    return [[iTunesCurrentTrack alloc] initWithDict:dict];
}


@end
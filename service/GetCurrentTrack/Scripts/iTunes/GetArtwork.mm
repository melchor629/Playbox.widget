//
//  GetArtwork.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 09/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import "GetArtwork.h"

static const char* code = R"AS(
tell application "iTunes"
    set t to current track
    if (count of artworks of t) is not 0 then
        {format of artwork 1 of artworks of t, data of artwork 1 of artworks of t}
    end if
end tell
)AS";

@implementation iTunesGetArtworkScript {
    NSAppleScript* script;
}

- (instancetype) init {
    self = [super init];

    script = [[NSAppleScript alloc] initWithSource:[[NSString alloc] initWithUTF8String: code]];
    [script compileAndReturnError:nil];

    return self;
}

- (iTunesArtwork) artwork {
    NSAppleEventDescriptor* event = [script executeAndReturnError: nil];
    NSAppleEventDescriptor* type = [event descriptorAtIndex:1];
    NSAppleEventDescriptor* data = [event descriptorAtIndex:2];
    return {[type typeCodeValue], [data data]};
}

@end

//
//  iTunesGetStateScript.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 09/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import "GetState.h"

static const char* code = R"AS(
tell application "iTunes"
    if running then
        player state as text
    end if
end tell
)AS";

@implementation iTunesGetStateScript {
    NSAppleScript* script;
}

- (instancetype) init {
    self = [super init];

    script = [[NSAppleScript alloc] initWithSource:[[NSString alloc] initWithUTF8String:code]];
    [script compileAndReturnError:nil];

    return self;
}

- (NSString*) state {
    NSAppleEventDescriptor* event = [script executeAndReturnError: nil];
    return [event stringValue];
}

@end

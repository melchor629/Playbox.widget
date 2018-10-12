//
//  GetState.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 09/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import "GetState.h"

static const char* code = R"AS(
tell application "VOX"
    if running then
        player state
    end if
end tell
)AS";

@implementation VOXGetStateScript {
    NSAppleScript* script;
}

- (instancetype) init {
    self = [super init];

    script = [[NSAppleScript alloc] initWithSource:[[NSString alloc] initWithUTF8String:code]];
    [script compileAndReturnError:nil];

    return self;
}

- (int) state {
    NSAppleEventDescriptor* event = [script executeAndReturnError: nil];
    return [event int32Value];
}

@end

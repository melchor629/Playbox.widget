//
//  main.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 2/1/18.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GetCurrentTrackApp.h"

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/event.h>

NSString* getBaseDirectory(NSString* extra) {
    char* cwd = getcwd(NULL, 0);
    NSString* nscwd = [NSString stringWithUTF8String:cwd];
    free(cwd);
    return extra ? [NSString stringWithFormat:@"%@/%@", nscwd, extra] : nscwd;
}

static void interruption(int signo) {
    [NSApp terminate:nil];
}

int main(int argc, const char * argv[]) {
    signal(SIGINT, interruption);
    signal(SIGTERM, interruption);
    @autoreleasepool {
        GetCurrentTrackApp* app = [[GetCurrentTrackApp alloc] initWithArgs:@{}];
        id a = [NSApplication sharedApplication]; (void)a; //Trick to make isRunning() work
        [NSApp run];
        [app cleanup];
    }
    return 0;
}

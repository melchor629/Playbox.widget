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

NSString* getBaseDirectory(NSString* extra) {
    char* cwd = getcwd(NULL, 0);
    NSString* nscwd = [NSString stringWithUTF8String:cwd];
    free(cwd);
    return extra ? [NSString stringWithFormat:@"%@/%@", nscwd, extra] : nscwd;
}

#define checc(v, msg) { \
    if((v) == -1) { \
        NSLog(@"Failed in %s:%d: %s: %s\n", __FILE__, __LINE__, strerror(errno), msg);\
    } \
}

volatile bool notInterrupted = false;
static void interruption(int signo) {
    notInterrupted = true;
}

static void run(bool daemonized) {
    @autoreleasepool {
        signal(SIGINT, interruption);
        signal(SIGTERM, interruption);
        GetCurrentTrackApp* app = [[GetCurrentTrackApp alloc] init];
        NSThread* thread = [[NSThread alloc] initWithTarget:app selector:@selector(loop:) object:daemonized ? app : nil];
        [thread start];
        id a = [NSApplication sharedApplication]; (void)a; //Trick to make isRunning() work
        [NSApp run];
    }
}

int main(int argc, const char * argv[]) {
    run(false);
    return 0;
}

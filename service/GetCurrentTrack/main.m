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

bool isRunning(NSString* bundleId) {
    NSArray* running = [[NSWorkspace sharedWorkspace] runningApplications];
    NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(NSRunningApplication* evaluatedObject, NSDictionary* bindings) {
        return [[evaluatedObject bundleIdentifier] isEqualToString:bundleId];
    }];
    return 0 < [[running filteredArrayUsingPredicate: predicate] count];
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
        id a = [[NSApplication alloc] init]; (void)a; //Trick to make isRunning() work
        [NSApp run];
    }
}

//https://stackoverflow.com/questions/17954432/creating-a-daemon-in-linux/17955149#17955149
static void daemonize(void) {
    pid_t pid = fork();
    if(pid < 0) {
        checc(pid, "Could not create the daemon");
        exit(EXIT_FAILURE);
    } else if(pid > 0) {
        //Parent must exist right now
        exit(EXIT_SUCCESS);
    }

    if(setsid() < 0) exit(EXIT_FAILURE);
    signal(SIGCHLD, SIG_IGN);
    signal(SIGHUP, SIG_IGN);

    //Fork off for the second time
    pid = fork();
    if(pid < 0) {
        checc(pid, "Could not create the daemon (2)");
        exit(EXIT_FAILURE);
    } else if(pid > 0) {
        //Child must exist right now
        exit(EXIT_SUCCESS);
    }
    umask(0);
    for(int x = (int) sysconf(_SC_OPEN_MAX); x >= 0; x--){
        close(x);
    }
}

int main(int argc, const char * argv[]) {
    bool should_daemonize = false;
    if(argc == 2) {
        should_daemonize = !strcmp("-d", argv[1]);
    }

    if(should_daemonize) daemonize();

    run(should_daemonize);

    return 0;
}

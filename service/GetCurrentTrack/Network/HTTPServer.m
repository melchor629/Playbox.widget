//
//  HTTPServer.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 10/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import "HTTPServer.h"
#import "ServerSocket.h"

@implementation HTTPServer {
    NSMutableArray<ServerSocket*>* sockets;
}

@synthesize delegate;

- (instancetype) init {
    self = [super init];
    sockets = [[NSMutableArray alloc] initWithCapacity:2];
    return self;
}

- (BOOL) listenToAddress: (NSString*) address andPort: (uint16_t) port {
    ServerSocket* socket = [[ServerSocket alloc] init];
    [socket setDelegate:self];
    bool ok = [socket listenToAddress:address andPort:port];
    if(ok) {
        [sockets addObject:socket];
    }
    return ok;
}

- (void) newConnection: (ClientSocket*) client {
    NSArray<NSString*>* fields = [[self readLine:client] componentsSeparatedByString:@" "];
    NSString* method = [fields objectAtIndex:0];
    NSString* uri = [fields objectAtIndex:1];
    NSString* version = [fields objectAtIndex:2];

    if(method == nil || uri == nil || version == nil) {
        [client close];
        return;
    }

    NSString* line = [self readLine:client];
    NSMutableDictionary* headers = [[NSMutableDictionary alloc] init];
    while([line length] != 0) {
        NSRange range = [line rangeOfString:@":"];
        if(range.location == NSNotFound) {
            [client close];
            return;
        }

        NSString* key = [line substringToIndex:range.location];
        NSString* value = nil;
        for(NSUInteger i = range.location + 1; i < [line length]; i++) {
            if([line characterAtIndex:i] != ' ') {
                value = [line substringFromIndex:i];
                break;
            }
        }

        [headers setValue:value forKey:key];

        line = [self readLine:client];
    }

    HTTPResponse* res = [[HTTPResponse alloc] initWithClient:client];
    HTTPRequest req = { method, uri, headers };
    if(delegate != nil && [delegate respondsToSelector:@selector(request:withResponse:)]) {
        [delegate performSelector:@selector(request:withResponse:) withObject:(__bridge id) (&req) withObject:res];
    }
    [client close];
}

- (void) close {
    for(ServerSocket* socket in sockets) {
        [socket close];
    }
}

- (NSString*) readLine: (ClientSocket*) client {
    NSMutableData* rawLine = [[NSMutableData alloc] initWithCapacity:30];
    bool carriageReturnDetected = false;
    bool newLineDetected = false;
    while(!newLineDetected) {
        NSData* ch = [client readAll:1];
        char chh = *((const char*) [ch bytes]);

        if(!carriageReturnDetected && chh == '\r') {
            carriageReturnDetected = true;
        } else if(carriageReturnDetected && chh != '\n') {
            carriageReturnDetected = false;
            [rawLine appendData:ch];
        } else if(chh == '\n') {
            newLineDetected = true;
        } else {
            [rawLine appendData:ch];
        }
    }

    return [[NSString alloc] initWithData:rawLine encoding:NSUTF8StringEncoding];
}

@end

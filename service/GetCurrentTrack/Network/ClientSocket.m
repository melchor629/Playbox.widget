//
//  ClientSocket.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 10/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import "ClientSocket.h"

#include <sys/socket.h>

@implementation ClientSocket {
    int sock;
}

- (instancetype) initWithNativeSocket: (int) socket {
    self = [super init];
    sock = socket;
    return self;
}

- (NSData*) read: (NSUInteger) bytes {
    char buff[1024];
    ssize_t bytesRead;
    if(bytes == 0) {
        bytesRead = recv(sock, buff, sizeof(buff), 0);
    } else {
        bytesRead = recv(sock, buff, bytes <= sizeof(buff) ? bytes : sizeof(bytes), 0);
    }

    if(bytesRead < 0) {
        NSLog(@"Failed in %s:%d: %s: Could not read from client\n", __FILE__, __LINE__, strerror(errno));
        return nil;
    }

    return [NSData dataWithBytes:buff length:bytesRead];
}

- (NSUInteger) write: (NSData*) data {
    return [self writeRawData:[data bytes] withLength:[data length]];
}

- (NSUInteger) writeRawData: (const void*) ptr withLength: (size_t) size {
    ssize_t bytesSent = send(sock, ptr, size, 0);
    if(bytesSent < 0) {
        NSLog(@"Failed in %s:%d: %s: Could not write to the client\n", __FILE__, __LINE__, strerror(errno));
        return 0;
    }

    return bytesSent;
}

- (NSData*) readAll: (NSUInteger) bytes {
    NSMutableData* data = [[NSMutableData alloc] initWithCapacity:bytes];
    while([data length] < bytes) {
        NSData* new = [self read:bytes - [data length]];
        if(new == nil) {
            return data;
        } else {
            [data appendData:new];
        }
    }
    return data;
}

- (NSUInteger) writeAll: (NSData*) data {
    return [self writeAllRawData:[data bytes] withLength:[data length]];
}

- (NSUInteger) writeAllRawData: (const void*) ptr withLength: (size_t) size {
    size_t bytesWritten = 0;
    while(bytesWritten < size) {
        ssize_t bw = [self writeRawData:ptr + bytesWritten withLength:size - bytesWritten];
        if(bw == 0) {
            return bytesWritten;
        }
        bytesWritten += bw;
    }

    return bytesWritten;
}

- (void) shutdownRead {
    shutdown(sock, SHUT_RD);
}

- (void) shutdownWrite {
    shutdown(sock, SHUT_WR);
}

- (void) shutdown {
    shutdown(sock, SHUT_RDWR);
}

- (void) close {
    close(sock);
}

@end

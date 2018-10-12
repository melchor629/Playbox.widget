//
//  ServerSocket.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 10/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import "ServerSocket.h"

#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <netdb.h>

#define checc(v, msg) { if((v) == -1) { \
    NSLog(@"Failed in %s:%d: %s: %s\n", __FILE__, __LINE__, strerror(errno), msg); \
    return false; \
}}

@implementation ServerSocket {
    int sock;
    dispatch_source_t acceptEvent;
}

@synthesize delegate;

- (instancetype) init {
    return self = [super init];
}

- (BOOL) listenToAddress: (NSString *) address andPort: (uint16_t) port {
    struct addrinfo* res;

    int err = getaddrinfo(
                          [address cStringUsingEncoding:NSUTF8StringEncoding],
                          NULL,
                          NULL,
                          &res);
    if(err != 0) {
        NSLog(@"Failed in %s:%d: %s: Could not get info about the address %@\n", __FILE__, __LINE__, gai_strerror(err), address);
        return false;
    }

    int family = PF_INET6;
    if(res->ai_family == PF_INET) {
        family = PF_INET;
        sock = socket(PF_INET, SOCK_STREAM, 0);
    } else {
        sock = socket(PF_INET6, SOCK_STREAM, 0);
    }

    int opt = 1; //Avoid "Address already in use" error
    setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, (char*) &opt, sizeof(opt));

    struct sockaddr* sockaddress;
    socklen_t sockaddress_size;
    if(family == PF_INET6) {
        sockaddress_size = sizeof(struct sockaddr_in6);
        struct sockaddr_in6* sockaddr = (struct sockaddr_in6*) calloc(1, sockaddress_size);
        struct sockaddr_in6* ai_addr = (struct sockaddr_in6*) res->ai_addr;
        memcpy(&sockaddr->sin6_addr, &ai_addr->sin6_addr, sizeof(struct in6_addr));

        sockaddr->sin6_family = AF_INET6;
        sockaddr->sin6_port = htons(port);
        sockaddress = (struct sockaddr*) sockaddr;
    } else {
        sockaddress_size = sizeof(struct sockaddr_in);
        struct sockaddr_in* sockaddr = (struct sockaddr_in*) calloc(1, sockaddress_size);
        struct sockaddr_in* ai_addr = (struct sockaddr_in*) res->ai_addr;
        memcpy(&sockaddr->sin_addr, &ai_addr->sin_addr, sizeof(struct in_addr));

        sockaddr->sin_family = AF_INET;
        sockaddr->sin_port = htons(port);
        sockaddress = (struct sockaddr*) sockaddr;
    }
    freeaddrinfo(res);

    id errorstr = [NSString stringWithFormat:@"Cannot bind to http://%@:%u", address, port];
    const char* errstr = [errorstr cStringUsingEncoding:NSUTF8StringEncoding];
    checc(bind(sock, sockaddress, sockaddress_size),
          errstr);

    checc(listen(sock, 10), errstr);

    acceptEvent = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ,
                                         sock,
                                         0,
                                         dispatch_get_main_queue());
    if(acceptEvent == NULL) {
        NSLog(@"Failed in %s:%d: %s: Could not create dispatch source\n", __FILE__, __LINE__, strerror(errno));
        close(sock);
        return false;
    }

    dispatch_source_set_event_handler(acceptEvent, ^{
        ClientSocket* client = [self accept];
        if([self->delegate respondsToSelector:@selector(newConnection:)]) {
            [self->delegate performSelector:@selector(newConnection:) withObject:client];
        } else {
            [client close];
        }
    });
    dispatch_resume(acceptEvent);

    return true;
}

- (ClientSocket*) accept {
    int client;
    checc(client = accept(sock, NULL, NULL), "Cannot accept a client :(");

    return [[ClientSocket alloc] initWithNativeSocket:client];
}

- (void) close {
    dispatch_source_cancel(acceptEvent);
    close(sock);
}

@end

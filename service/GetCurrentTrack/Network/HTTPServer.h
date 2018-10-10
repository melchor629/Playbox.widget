//
//  HTTPServer.h
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 10/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClientSocket.h"
#import "HTTPResponse.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct _HTTPRequest {
    NSString* method;
    NSString* path;
    NSDictionary* headers;
} HTTPRequest;

@protocol HTTPServerDelegate <NSObject>

- (void) request: (HTTPRequest*) req withResponse: (HTTPResponse*) res;

@end

@interface HTTPServer : NSObject

@property (atomic) id delegate;

- (BOOL) listenToAddress: (NSString*) address andPort: (uint16_t) port;
- (void) close;

@end

NS_ASSUME_NONNULL_END

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

/*!
 @brief HTTP server delegate for new requests.
 */
@protocol HTTPServerDelegate <NSObject>

/*!
 @brief New request has been received and should be attended with a response.
 @discussion
 The method will be called when a new request is received, with some information
 about the request and a response object. The response is where the result and body
 should be placed. The response is buffered in memory and when ended, it will be
 flushed to the client. Optimized for light-sized bodies.

 @param req Request information.
 @param res Response object where the response must be placed.
 */
- (void) request: (HTTPRequest*) req withResponse: (HTTPResponse*) res;

@end

/*!
 @brief A simple HTTP server.
 @discussion
 Simple HTTP 1.1 server that can receive requests and send back valid responses
 easily. New requests will be delivered to the delegate to handle it. If the delegate
 don't handle them, it will be closed without any response.
 */
@interface HTTPServer : NSObject

//! Delegate object for the requests to be handled, implemeting protocol HTTPServerDelegate
@property (atomic) id delegate;

/*!
 @brief Listens for new requests at desired address and port.
 @param address IPv4 or IPv6 address to listen for requests.
 @param port Port to listen for requests.
 @return true if everything gone well, false otherwise.
 @see ServerSocket#listenToAddress:andPort:
 */
- (BOOL) listenToAddress: (NSString*) address andPort: (uint16_t) port;

/*!
 @brief Stops listening for new requests.
 */
- (void) close;

@end

NS_ASSUME_NONNULL_END

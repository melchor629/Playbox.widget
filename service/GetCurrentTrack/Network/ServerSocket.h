//
//  ServerSocket.h
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 10/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClientSocket.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 Protocol for delegates that want to know when a client has connected to the server.
 */
@protocol ServerSocketDelegate <NSObject>

/*!
 Method called when a client has connected to the server.

 @param client A socket to the new client
 */
- (void) newConnection: (ClientSocket*) client;

@end

/*!
 @brief An easy TCP server socket

 @discussion
 Creates a TCP server socket that listens for coonections and calls the delegate.
 If there's no delegate, or the delegate doesn't implement the ServerSocketDelegate,
 the server will close the client socket.

 Uses GCD to avoid blocking the main thread. The delegate will run in any thread.
 */
@interface ServerSocket : NSObject

//! Property for the delegate of the ServerSocketDelegate.
@property (atomic) id delegate;

- (instancetype) init;

/*!
 @brief Starts listening at the desired address and port.
 @discussion
 The server will listen at address and it can be an IPv4 or IPv6 address.
 Every new connection will be transfered to the delegate, if any.

 If any error occurrs, it will show the error in the log and return false.

 @param address IPv4 or IPv6 address to listen to (`::1` or `127.0.0.1` are good options).
 @param port Port to listen to.
 */
- (BOOL) listenToAddress: (NSString* _Nonnull) address andPort: (uint16_t) port;

/*!
 @brief Closes the server socket.
 @discussion
 Stops listening for new clients and closes the server socket.
 */
- (void) close;

@end

NS_ASSUME_NONNULL_END

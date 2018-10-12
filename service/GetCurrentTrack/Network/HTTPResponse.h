//
//  HTTPResponse.h
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 10/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClientSocket.h"

NS_ASSUME_NONNULL_BEGIN

//! Response for an HTTP request.
@interface HTTPResponse : NSObject

//! Status code to be returned in the request at end.
@property NSUInteger statusCode;

/*!
 @brief Initializes the request with a ClientSocket.
 @param client A ClientSocket
 */
- (instancetype) initWithClient: (ClientSocket* _Nonnull) client;

/*!
 @brief Sets or modifies a header value.
 @discussion
 Changes the value of a header or sets the value of it (if doesn't exist).
 The keys are case insensitive, so `content-type` will be the same as
 `Content-Type`.
 @param value New value for the header
 @param key Key name of the header
 */
- (void) setValue: (NSString* _Nonnull) value forHeader: (NSString* _Nonnull) key;

/*!
 @brief Gets the value of a header if exists.
 @discussion
 The key for the headers are case insensitive, so `content-type` will be the
 same as `Content-Type`. If a value for that header doesn't exist, will return
 nil.
 @param key Key name of the header
 @return The value for the header or nil
 */
- (NSString* _Nullable) valueForHeader: (NSString* _Nonnull) key;

/*!
 @brief Sends some string to the client.
 @discussion
 Writes some string to the client. The data is stored in-memory to be sent when the
 request has ended.
 @param data String to send to the the client.
 */
- (void) write: (NSString* _Nonnull) data;

/*!
 @brief Sends some data to the client.
 @discussion
 Writes some data to the client. The data is stored in-memory to be sent when the
 request has ended.
 @param data Data to send to the client.
 */
- (void) writeData: (NSData* _Nonnull) data;

/*!
 @brief Sends some data (in form of C pointer) to the client.
 @discussion
 Writes some data to the client. The data is copied to an internal memory which will
 be sent when the request ends.
 @param ptr Pointer to the data.
 @param length Length of the data (in bytes).
 */
- (void) writeRawData: (const void*) ptr withLength: (NSUInteger) length;

/*!
 @brief Sends a dictionary as JSON to the client.
 @discussion
 Converts the dictionary into JSON string, and sends it directly to the client.
 It also sets the `Content-Type` header to JSON. With that, the request will be ended.
 @param dict Dictionary to send to the client as JSON.
 */
- (void) writeJsonAndEnd: (NSDictionary* _Nonnull) dict;

/*!
 @brief Sends a dictionary as JSON to the client and changes the status code.
 @discussion
 Converts the dictionary into JSON string, and sends it directly to the client.
 It also sets the `Content-Type` header to JSON, and changes the status code by
 the one specified as paramter. With that call, the request will be ended.
 @param dict Dictionary to send to the client as JSON.
 @param statusCode New HTTP status code to send to the client.
 */
- (void) writeJsonAndEnd: (NSDictionary* _Nonnull) dict withStatus: (NSUInteger) statusCode;

/*!
 @brief Ends the request, sending everything to the client.
 */
- (void) end;

@end

NS_ASSUME_NONNULL_END

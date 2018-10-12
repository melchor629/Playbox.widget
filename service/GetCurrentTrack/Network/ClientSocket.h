//
//  ClientSocket.h
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 10/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 @brief An easy client socket.
 @discussion
 A client socket that can send and receive data (synchronously only) from another endpoint.
 Currently you can only use this class if you created a BSD socket or from a ServerSocket.
 */
@interface ClientSocket : NSObject

/*!
 @brief Creates the client socket with the native/BSD socket.
 @param socket The BSD socket file descriptor
 */
- (instancetype) initWithNativeSocket: (int) socket;

/*!
 @brief Reads some data from the socket
 @discussion
 It will try to read some bytes, but not exactly what you requested.

 If the data is nil, then an error occurred, and it will be shown in the log.
 @param bytes Number of bytes that will read as maximum
 @return The read data
 */
- (NSData*) read: (NSUInteger) bytes;

/*!
 @brief Writes data to the socket
 @discussion
 It will try to write as much as the operative system can. It is possible to write
 less data than you desired.

 If the bytes written is 0, then an error occurred, and it will be shown in the log.
 @param data The data to write to the socket.
 @return The number of bytes written effectively.
 */
- (NSUInteger) write: (NSData*) data;

/*!
 @brief Writes a C data pointer to the socket
 @discussion
 It will try to write as much as the operative system can. It is possible to write
 less data than you desired.

 If the bytes written is 0, then an error occurred, and it will be shown in the log.
 @param ptr C pointer in which the data is located.
 @param size The size of the data (in bytes).
 @return The number of bytes written effectively.
 */
- (NSUInteger) writeRawData: (const void*) ptr withLength: (size_t) size;

/*!
 @brief Reads all the requested bytes from the socket.
 @discussion
 It will read as much as you requested. If there's an error, it will read less
 than you specified.

 If the data is nil or contains less data than you desired, then an error has occurred,
 and it will be shown in the log.
 @param bytes Number of bytes to read
 @return Read data from the socket
 */
- (NSData*) readAll: (NSUInteger) bytes;

/*!
 @brief Writes all the data to the socket.
 @discussion
 It will write all the data.

 If the bytes written is less than requested, then an error occurred, and it will
 be shown in the log.
 @param data The data to write to the socket.
 @return The number of written bytes.
 */
- (NSUInteger) writeAll: (NSData*) data;

/*!
 @brief Writes all the data to the socket.
 @discussion
 It will write all the data.

 If the bytes written is less than requested, then an error occurred, and it will
 be shown in the log.
 @param ptr C pointer in which the data is located.
 @param size The size of the data (in bytes).
 @return The number of written bytes.
 */
- (NSUInteger) writeAllRawData: (const void*) ptr withLength: (size_t) size;

/*!
 @brief Notifies that you won't read anymore.
 */
- (void) shutdownRead;

/*!
 @brief Notifies that you won't write anymore.
 */
- (void) shutdownWrite;

/*!
 @brief Notifies that you won't read nor write anymore.
 */
- (void) shutdown;

/*!
 @brief Closes the socket.
 @note It is recommended to shutdown the socket before.
 */
- (void) close;

@end

NS_ASSUME_NONNULL_END

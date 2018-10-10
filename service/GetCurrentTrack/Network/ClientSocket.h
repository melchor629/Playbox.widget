//
//  ClientSocket.h
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 10/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ClientSocket : NSObject

- (instancetype) initWithNativeSocket: (int) socket;
- (NSData*) read: (NSUInteger) bytes;
- (NSUInteger) write: (NSData*) data;
- (NSUInteger) writeRawData: (const void*) ptr withLength: (size_t) size;
- (NSData*) readAll: (NSUInteger) bytes;
- (NSUInteger) writeAll: (NSData*) data;
- (NSUInteger) writeAllRawData: (const void*) ptr withLength: (size_t) size;
- (void) shutdownRead;
- (void) shutdownWrite;
- (void) shutdown;
- (void) close;

@end

NS_ASSUME_NONNULL_END

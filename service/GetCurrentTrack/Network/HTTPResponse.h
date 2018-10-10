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

@interface HTTPResponse : NSObject

@property NSUInteger statusCode;

- (instancetype) initWithClient: (ClientSocket*) client;
- (void) setValue: (NSString*) value forHeader: (NSString*) key;
- (NSString*) valueForHeader: (NSString*) key;
- (void) write: (NSString*) data;
- (void) writeData: (NSData*) data;
- (void) writeRawData: (const void*) ptr withLength: (NSUInteger) length;
- (void) end;

@end

NS_ASSUME_NONNULL_END

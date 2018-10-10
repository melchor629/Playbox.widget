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

@protocol ServerSocketDelegate <NSObject>

- (void) newConnection: (ClientSocket*) client;

@end

@interface ServerSocket : NSObject

@property (atomic) id delegate;

- (instancetype) init;
- (BOOL) listenToAddress: (NSString*) address andPort: (uint16_t) port;
- (void) close;

@end

NS_ASSUME_NONNULL_END

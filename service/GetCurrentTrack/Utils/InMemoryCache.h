//
//  InMemoryCache.h
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 12/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//! Simple in-memory cache with expiration for items,
//! implemented with Foundation elements.
@interface InMemoryCache : NSObject

- (id _Nullable) valueForKey: (NSString* _Nonnull) key;
- (void) setValue: (id _Nullable) value forKey: (NSString* _Nonnull) key;
//! Sets the property of the receiver specified by
//! a given key to a given value with an expiration in seconds.
- (void) setValue: (id _Nullable) value forKey: (NSString* _Nonnull) key withExpiration: (NSTimeInterval) exp;
//! Sets the expiration (in seconds) for a key.
- (void) setExpiration: (NSTimeInterval) exp forKey: (NSString* _Nonnull) key;
//! Removes the expiration time for a key.
- (void) clearExpirationForKey: (NSString* _Nonnull) key;
//! Removes the value for the a key.
- (void) removeObjectForKey: (NSString* _Nonnull) key;

@end

NS_ASSUME_NONNULL_END

//
//  NSDictionary+CaseInsensitive.h
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 10/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//Based on https://stackoverflow.com/questions/13607343/nsdictionary-case-insensitive-objectforkey#13607604
@interface NSDictionary (CaseInsensitive)

- (id) objectForCaseInsensitiveKey: (NSString* _Nonnull) key;
- (void) setValue: (id _Nonnull) value forKeyCaseInsensitive: (NSString* _Nonnull) rkey;

@end

NS_ASSUME_NONNULL_END

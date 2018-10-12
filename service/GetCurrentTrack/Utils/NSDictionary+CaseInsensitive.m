//
//  NSDictionary+CaseInsensitive.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 10/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import "NSDictionary+CaseInsensitive.h"

@implementation NSDictionary (NSDictionaryCaseInsensitive)

- (NSString* _Nullable) lookForRealKey: (NSString* _Nonnull) rkey {
    NSSet<NSString*>* keyOrNot = [self keysOfEntriesPassingTest:^BOOL(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        return [key caseInsensitiveCompare:rkey] == NSOrderedSame;
    }];

    if([keyOrNot count] == 1) {
        return [keyOrNot anyObject];
    }

    return nil;
}

- (id) objectForCaseInsensitiveKey: (NSString* _Nonnull) lkey {
    NSString* key = [self lookForRealKey:lkey];

    if(key != nil) {
        return [self objectForKey:key];
    }

    return nil;
}

- (void) setValue: (id _Nonnull) value forKeyCaseInsensitive: (NSString* _Nonnull) rkey {
    NSString* key = [self lookForRealKey:rkey];

    if(key != nil) {
        [self setValue: value forKey:key];
    } else {
        [self setValue: value forKey:rkey];
    }
}

@end

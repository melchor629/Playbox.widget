//
//  NSDictionary+CaseInsensitive.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 10/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import "NSDictionary+CaseInsensitive.h"

@implementation NSDictionary (NSDictionaryCaseInsensitive)

- (id) objectForCaseInsensitiveKey: (NSString *) lkey {
    NSSet<NSString*>* keyOrNot = [self keysOfEntriesPassingTest:^BOOL(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        return [key caseInsensitiveCompare:lkey] == NSOrderedSame;
    }];

    if([keyOrNot count] == 1) {
        return [self objectForKey:[keyOrNot anyObject]];
    }

    return nil;
}

@end

//
//  InMemoryCache.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 12/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import "InMemoryCache.h"

@interface CacheEntry : NSObject
@property (readonly) BOOL expired;
@property id value;
@property (nonatomic) NSTimeInterval expiration;
@end

@implementation CacheEntry {
    NSDate* expirationTime;
}

@synthesize value;

+ (CacheEntry*) entryWithValue: (id _Nonnull) value {
    CacheEntry* entry = [[CacheEntry alloc] init];

    entry.value = value;
    entry->expirationTime = nil;

    return entry;
}

+ (CacheEntry*) entryWithValue: (id _Nonnull) value andExpiration: (NSTimeInterval) exp {
    CacheEntry* entry = [[CacheEntry alloc] init];

    entry.value = value;
    entry->expirationTime = [NSDate dateWithTimeIntervalSinceNow:exp];

    return entry;
}

- (BOOL) expired {
    if(self->expirationTime != nil) {
        return [expirationTime compare:[NSDate date]] == NSOrderedAscending;
    }
    return NO;
}

- (NSTimeInterval) expiration {
    if(expirationTime != nil) {
        return [expirationTime timeIntervalSinceNow];
    }
    return NAN;
}

- (void) setExpiration: (NSTimeInterval) expiration {
    if(isnan(expiration)) {
        expirationTime = nil;
    } else {
        expirationTime = [NSDate dateWithTimeIntervalSinceNow:expiration];
    }
}

@end



@implementation InMemoryCache {
    NSMutableDictionary<NSString*, CacheEntry*>* cache;
}

- (instancetype) init {
    self = [super init];
    self->cache = [[NSMutableDictionary alloc] init];
    return self;
}

- (id _Nullable) valueForKey: (NSString* _Nonnull) key {
    [self check];
    CacheEntry* entry = [cache valueForKey:key];
    if(entry != nil) {
        return entry.value;
    }
    return nil;
}

- (void) setValue: (id _Nullable) value forKey: (NSString* _Nonnull) key {
    [self check];
    CacheEntry* entry = [cache valueForKey:key];
    if(entry == nil) {
        entry = [CacheEntry entryWithValue:value];
        [cache setValue:entry forKey:key];
    } else {
        entry.value = value;
        entry.expiration = NAN;
    }
}

- (void) setValue: (id _Nullable) value forKey: (NSString* _Nonnull) key withExpiration: (NSTimeInterval) exp {
    [self check];
    CacheEntry* entry = [cache valueForKey:key];
    if(entry == nil) {
        entry = [CacheEntry entryWithValue:value andExpiration:exp];
        [cache setValue:entry forKey:key];
    } else {
        entry.value = value;
        entry.expiration = exp;
    }
}

- (void) setExpiration: (NSTimeInterval) exp forKey: (NSString* _Nonnull) key {
    [self check];
    CacheEntry* entry = [cache valueForKey:key];
    if(entry != nil) {
        entry.expiration = exp;
    }
}

- (void) clearExpirationForKey: (NSString* _Nonnull) key {
    [self check];
    CacheEntry* entry = [cache valueForKey:key];
    if(entry != nil) {
        entry.expiration = NAN;
    }
}

- (void) removeObjectForKey: (NSString* _Nonnull) key {
    [self check];
    [cache removeObjectForKey:key];
}

- (void) check {
    NSMutableArray<NSString*>* keysToRemove = [[NSMutableArray alloc] init];
    for(NSString* key in cache) {
        CacheEntry* cacheEntry = [cache valueForKey:key];
        if([cacheEntry expired]) {
            [keysToRemove addObject:key];
        }
    }

    [cache removeObjectsForKeys:keysToRemove];
}

@end

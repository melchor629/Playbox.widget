//
//  GetCurrentTrackCache.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 13/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import "GetCurrentTrackCache.h"
#import "Utils/InMemoryCache.h"

@implementation GetCurrentTrackCache {
    InMemoryCache* cache;
    SongMetadata* last;
}

- (instancetype) init {
    self = [super init];
    cache = [[InMemoryCache alloc] init];
    return self;
}

- (SongMetadata* _Nullable) songMetadataForPlayer: (Player*) player {
    NSString* key = [self cacheKeyForMetadata:player];
    SongMetadata* metadata = [cache valueForKey:key];
    if(metadata == nil) {
        metadata = [player getMetadata];
        [self checkForChanges:player metadata:metadata];
        [cache setValue:metadata
                 forKey:key
         withExpiration:1];
    }
    return metadata;
}

- (SongCover* _Nullable) songCoverForPlayer: (Player*) player {
    SongMetadata* metadata = [self songMetadataForPlayer:player];
    if(metadata != nil) {
        SongCover* cover = [cache valueForKey:[self cacheKeyForCoverArt:metadata]];
        if(cover == nil) {
            cover = [player getCover];
            [cache setValue:cover
                     forKey:[self cacheKeyForCoverArt:metadata]
             withExpiration:metadata.duration * 2];
        }
        return cover;
    }
    return nil;
}

- (SongCover* _Nullable) songCoverForMetadata: (SongMetadata*) metadata {
    return [cache valueForKey:[self cacheKeyForCoverArt:metadata]];
}



- (NSString*) cacheKeyForCoverArt: (SongMetadata*) song {
    return [NSString stringWithFormat:@"cover|%@|%@",
            song.albumArtist ? song.albumArtist : (song.artist ? song.artist : @"unknown"),
            song.album ? song.album : @"unknown"];
}

- (NSString*) cacheKeyForMetadata: (Player*) player {
    return [NSString stringWithFormat:@"metadata|%@",
            [[player name] lowercaseString]];
}



static bool areEqualsWithNil(NSString* a, NSString* b) {
    if(a == nil && b != nil) return false;
    if(a != nil && b == nil) return false;
    if(a == nil && b == nil) return true;
    return [a isEqualToString:b];
}

- (bool) didSongChange: (SongMetadata*) current {
    return !(
             areEqualsWithNil(current.artist, last.artist) &&
             areEqualsWithNil(current.name, last.name) &&
             areEqualsWithNil(current.album, last.album)
             );
}

- (bool) didCoverChange: (SongMetadata*) current {
    if(current.album != nil) {
        if(current.albumArtist != nil) {
            return !(areEqualsWithNil(current.albumArtist, last.albumArtist) && areEqualsWithNil(current.album, last.album));
        }
        return !(areEqualsWithNil(current.artist, last.artist) && areEqualsWithNil(current.album, last.album));
    } else {
        return true;
    }
}

- (void) checkForChanges: (Player*) player metadata: (SongMetadata* _Nullable) current {
    if(current == nil) return;

    if([self didSongChange:current]) {
        if([self didCoverChange:current]) {
            [cache setValue:[player getCover]
                     forKey:[self cacheKeyForCoverArt:current]
             withExpiration:current.duration * 2];
        } else {
            [cache setExpiration:current.duration * 2
                          forKey:[self cacheKeyForCoverArt:current]];
        }
    }
    last = current;
}

@end

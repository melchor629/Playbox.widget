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
        SongCover* cover = [cache valueForKey:[self cacheKeyForCoverArt:metadata andPlayer:player]];
        if(cover == nil) {
            cover = [player getCover];
            [cache setValue:cover
                     forKey:[self cacheKeyForCoverArt:metadata andPlayer:player]
             withExpiration:metadata.duration * 2];
        }
        return cover;
    }
    return nil;
}

- (bool) songChangedForPlayer: (Player*) player {
    return [[cache valueForKey:[self cacheKeyForSongChanged:player]] boolValue];
}



- (NSString*) cacheKeyForCoverArt: (SongMetadata*) song andPlayer: (Player*) player {
    return [NSString stringWithFormat:@"cover|%@|%@|%@",
            [player name],
            song.albumArtist ? song.albumArtist : song.artist,
            song.album];
}

- (NSString*) cacheKeyForMetadata: (Player*) player {
    return [NSString stringWithFormat:@"metadata|%@",
            [[player name] lowercaseString]];
}

- (NSString*) cacheKeyForSongChanged: (Player*) player {
    return [NSString stringWithFormat:@"metadata|changed|%@",
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

- (void) checkForChanges: (Player*) player metadata: (SongMetadata*) current {
    if([self didSongChange:current]) {
        if([self didCoverChange:current]) {
            [cache setValue:[player getCover]
                     forKey:[self cacheKeyForCoverArt:current andPlayer:player]
             withExpiration:current.duration * 2];
        } else {
            [cache setExpiration:current.duration * 2
                          forKey:[self cacheKeyForCoverArt:current
                                                 andPlayer:player]];
        }

        [cache setValue:@true forKey:[self cacheKeyForSongChanged:player]];
    } else {
        [cache setValue:@false forKey:[self cacheKeyForSongChanged:player]];
    }
    last = current;
}

@end

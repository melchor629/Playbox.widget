//
//  iTunesPlayer.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 3/1/18.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import "iTunesPlayer.h"
#import "../Scripts/iTunes/GetArtwork.h"
#import "../Scripts/iTunes/GetCurrentTrack.h"
#import "../Scripts/iTunes/GetState.h"

NSString* getBaseDirectory(NSString* extra);

@implementation iTunesPlayer {
    iTunesGetArtworkScript* getArtworkScript;
    iTunesGetCurrentTrackScript* getCurrentTrackScript;
    iTunesGetStateScript* getStateScript;
}

- (instancetype) init {
    id _self = [super init];
    getArtworkScript = [[iTunesGetArtworkScript alloc] init];
    getCurrentTrackScript = [[iTunesGetCurrentTrackScript alloc] init];
    getStateScript = [[iTunesGetStateScript alloc] init];
    return _self;
}

- (bool) isPlaying {
    return isRunning(@"com.apple.iTunes") && [[getStateScript state] isEqualToString:@"playing"];
}

- (SongMetadata*) getMetadata {
    SongMetadata* metadata = [[SongMetadata alloc] init];
    iTunesCurrentTrack* currentTrack = [getCurrentTrackScript currentTrack];
    metadata.artist = [currentTrack albumArtist];
    if(metadata.artist == nil || [metadata.artist length] == 0) {
        metadata.artist = [currentTrack artist];
    }
    metadata.name = [currentTrack name];
    metadata.album = [currentTrack album];
    metadata.duration = [currentTrack duration];
    metadata.loved = [currentTrack loved];
    metadata.playerPosition = [currentTrack position];
    return metadata;
}

- (NSString*) getCover: (NSString*) basePath {
    iTunesArtwork artwork = [getArtworkScript artwork];
    if(artwork.data != nil) {
        iTunesCurrentTrack* currentTrack = [getCurrentTrackScript currentTrack];
        const char* ext = "bin";
        if(artwork.type == 'JPEG') {
            ext = "jpg";
        } else if(artwork.type == 'PNG ') {
            ext = "png";
        } else if(artwork.type == 'TIFF') {
            ext = "tiff";
        }

        NSUInteger hash;
        if([currentTrack album] != nil) {
            hash = [[currentTrack album] hash];
        } else {
            hash = [[NSString stringWithFormat:@"%@::%@", [currentTrack artist], [currentTrack name]] hash];
        }
        NSString* path = [NSString stringWithFormat:@"%@/i%lx.%s", basePath, hash, ext];
        FILE* file = fopen([path cStringUsingEncoding:NSUTF8StringEncoding], "w");
        fwrite([artwork.data bytes], [artwork.data length], 1, file);
        fclose(file);
        return path;
    } else {
        return nil;
    }
}

- (NSString*) name { return @"iTunes"; }

@end

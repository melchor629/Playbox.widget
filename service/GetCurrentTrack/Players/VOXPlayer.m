//
//  VOXPlayer.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 3/1/18.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import "VOXPlayer.h"
#import "../Scripts/VOX/GetArtwork.h"
#import "../Scripts/VOX/GetCurrentTrack.h"
#import "../Scripts/VOX/GetState.h"

NSString* getBaseDirectory(NSString* extra);

@implementation VOXPlayer {
    VOXGetArtworkScript* getArtworkScript;
    VOXGetCurrentTrackScript* getCurrentTrackScript;
    VOXGetStateScript* getStateScript;
}

- (instancetype) init {
    id _self = [super init];
    getArtworkScript = [[VOXGetArtworkScript alloc] init];
    getCurrentTrackScript = [[VOXGetCurrentTrackScript alloc] init];
    getStateScript = [[VOXGetStateScript alloc] init];
    return _self;
}

- (bool) isPlaying {
    return isRunning(@"com.coppertino.Vox") && [getStateScript state] == 1;
}

- (SongMetadata*) getMetadata {
    return [getCurrentTrackScript currentTrack];
}

- (NSString*) getCover: (NSString*) basePath {
    VOXArtwork artwork = [getArtworkScript artwork];
    if(artwork.data != nil) {
        SongMetadata* metadata = [self getMetadata];
        NSUInteger hash;
        if([metadata album] != nil) {
            hash = [[metadata album] hash];
        } else {
            hash = [[NSString stringWithFormat:@"%@::%@", [metadata artist], [metadata name]] hash];
        }
        NSString* path = [NSString stringWithFormat:@"%@/v%lx.tiff", basePath, hash];
        FILE* file = fopen([path cStringUsingEncoding:NSUTF8StringEncoding], "w");
        fwrite([artwork.data bytes], [artwork.data length], 1, file);
        fclose(file);
        return path;
    } else {
        return nil;
    }
}

- (NSString*) name { return @"VOX"; }

@end

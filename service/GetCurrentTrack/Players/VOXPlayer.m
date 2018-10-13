//
//  VOXPlayer.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 3/1/18.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import "VOXPlayer.h"
#import <Cocoa/Cocoa.h>
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

- (PlayerStatus) status {
    if(isRunning(@"com.coppertino.Vox")) {
        if([getStateScript state] == 1) {
            return PlayerStatusPlaying;
        } else {
            //We will suppose that VOX is stopped
            return PlayerStatusStopped;
        }
    }

    return PlayerStatusClosed;
}

- (SongMetadata*) getMetadata {
    return [getCurrentTrackScript currentTrack];
}

- (SongCover*) getCover {
    VOXArtwork artwork = [getArtworkScript artwork];
    if(artwork.data != nil) {
        return [SongCover coverWithData:(NSData*) artwork.data
                                andType:@"image/tiff"];
    } else {
        return nil;
    }
}

- (NSString*) name { return @"VOX"; }

@end

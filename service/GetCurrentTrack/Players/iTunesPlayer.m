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

- (PlayerStatus) status {
    if(isRunning(@"com.apple.iTunes")) {
        NSString* state = [getStateScript state];
        if([state isEqualToString:@"playing"]) {
            return PlayerStatusPlaying;
        } else if([state isEqualToString:@"stopped"]) {
            return PlayerStatusStopped;
        } else {
            return PlayerStatusPaused;
        }
    }

    return PlayerStatusClosed;
}

- (SongMetadata*) getMetadata {
    return [getCurrentTrackScript currentTrack];
}

- (SongCover*) getCover; {
    iTunesArtwork artwork = [getArtworkScript artwork];
    if(artwork.data != nil) {
        NSString* type = @"application/octet-stream";
        if(artwork.type == 'JPEG') {
            type = @"image/jpeg";
        } else if(artwork.type == 'PNG ') {
            type = @"image/png";
        } else if(artwork.type == 'TIFF') {
            type = @"image/tiff";
        }
        return [SongCover coverWithData:(NSData*) artwork.data
                                andType:type];
    } else {
        return nil;
    }
}

- (NSString*) name { return @"iTunes"; }

@end

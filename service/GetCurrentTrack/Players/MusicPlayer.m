//
//  MusicPlayer.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 09/10/2019.
//  Copyright © 2019 Melchor Garau Madrigal. All rights reserved.
//

#import "MusicPlayer.h"
#import "../Scripts/Music/GetArtwork.h"
#import "../Scripts/Music/GetCurrentTrack.h"
#import "../Scripts/Music/GetState.h"

NSString* getBaseDirectory(NSString* extra);

@implementation MusicPlayer {
    MusicGetArtworkScript* getArtworkScript;
    MusicGetCurrentTrackScript* getCurrentTrackScript;
    MusicGetStateScript* getStateScript;
}

- (instancetype) init {
    id _self = [super init];
    getArtworkScript = [[MusicGetArtworkScript alloc] init];
    getCurrentTrackScript = [[MusicGetCurrentTrackScript alloc] init];
    getStateScript = [[MusicGetStateScript alloc] init];
    return _self;
}

- (PlayerStatus) status {
    if(isRunning(@"com.apple.Music")) {
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
    MusicArtwork artwork = [getArtworkScript artwork];
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

- (NSString*) name { return @"Music"; }

@end

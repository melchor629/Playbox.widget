//
//  SpotifyPlayer.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 2/1/18.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import "SpotifyPlayer.h"
#import "../Scripts/Spotify/GetArtwork.h"
#import "../Scripts/Spotify/GetCurrentTrack.h"
#import "../Scripts/Spotify/GetState.h"

@implementation SpotifyPlayer {
    SpotifyGetArtworkScript* getArtworkScript;
    SpotifyGetCurrentTrackScript* getCurrentTrackScript;
    SpotifyGetStateScript* getStateScript;
}

- (instancetype) init {
    id _self = [super init];
    getArtworkScript = [[SpotifyGetArtworkScript alloc] init];
    getCurrentTrackScript = [[SpotifyGetCurrentTrackScript alloc] init];
    getStateScript = [[SpotifyGetStateScript alloc] init];
    return _self;
}

- (bool) isPlaying {
    return isRunning(@"com.spotify.client") && [[getStateScript state] isEqualToString:@"playing"];
}

- (SongMetadata*) getMetadata {
    return [getCurrentTrackScript currentTrack];
}

- (NSString*) getCover: (NSString*) basePath {
    return [getArtworkScript artwork];
}

- (NSString*) name { return @"Spotify"; }

@end

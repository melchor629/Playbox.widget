//
//  SpotifyPlayer.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 2/1/18.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import "SpotifyPlayer.h"
#import "../ScriptingBridgeHeaders/Spotify.h"

@implementation SpotifyPlayer {
    SpotifyApplication* app;
}

- (instancetype) init {
    id _self = [super init];
    app = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    return _self;
}

- (bool) isPlaying {
    return isRunning(@"com.spotify.client") && [app isRunning] && [app playerState] == SpotifyEPlSPlaying;
}

- (SongMetadata*) getMetadata {
    SongMetadata* metadata = [[SongMetadata alloc] init];
    SpotifyTrack* currentTrack = [app currentTrack];
    metadata.artistName = [currentTrack albumArtist];
    if(metadata.artistName == nil || [metadata.artistName length] == 0) {
        metadata.artistName = [currentTrack artist];
    }
    metadata.songName = [currentTrack name];
    metadata.albumName = [currentTrack album];
    metadata.songDuration = [currentTrack duration] / 1000;
    metadata.isLoved = NO;
    metadata.currentPosition = [app playerPosition];
    return metadata;
}

- (NSString*) getCover {
    return [[app currentTrack] artworkUrl];
}

- (NSString*) name { return @"Spotify"; }

@end

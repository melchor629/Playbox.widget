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
    metadata.artist = [currentTrack albumArtist];
    if(metadata.artist == nil || [metadata.artist length] == 0) {
        metadata.artist = [currentTrack artist];
    }
    metadata.name = [currentTrack name];
    metadata.album = [currentTrack album];
    metadata.duration = [currentTrack duration] / 1000;
    metadata.loved = NO;
    metadata.playerPosition = [app playerPosition];
    return metadata;
}

- (NSString*) getCover: (NSString*) basePath {
    return [[app currentTrack] artworkUrl];
}

- (NSString*) name { return @"Spotify"; }

@end

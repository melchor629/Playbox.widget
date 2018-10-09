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
    SpotifyTrack* currentTrack = [app currentTrack];
    id dict = @{
                @"artist": [currentTrack artist],
                @"albumArtist": [currentTrack albumArtist],
                @"name": [currentTrack name],
                @"album": [currentTrack album],
                @"duration": [NSNumber numberWithDouble:[currentTrack duration] / 1000.0],
                @"loved": @NO,
                @"position": [NSNumber numberWithDouble:[app playerPosition]]
                };
    return [[SongMetadata alloc] initWithDict:dict];
}

- (NSString*) getCover: (NSString*) basePath {
    return [[app currentTrack] artworkUrl];
}

- (NSString*) name { return @"Spotify"; }

@end

//
//  VOXPlayer.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 3/1/18.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import "VOXPlayer.h"
#import "../ScriptingBridgeHeaders/VOX.h"

NSString* getBaseDirectory(NSString* extra);

@implementation VOXPlayer {
    VOXApplication* app;
}

- (instancetype) init {
    id _self = [super init];
    app = [SBApplication applicationWithBundleIdentifier:@"com.coppertino.Vox"];
    return _self;
}

- (bool) isPlaying {
    return [app isRunning] && [app playerState] == 1;
}

- (SongMetadata*) getMetadata {
    SongMetadata* metadata = [[SongMetadata alloc] init];
    metadata.artistName = [app albumArtist];
    if(metadata.artistName == nil || [metadata.artistName length] == 0) {
        metadata.artistName = [app artist];
    }
    metadata.songName = [app track];
    metadata.albumName = [app album];
    metadata.songDuration = [app totalTime];
    metadata.isLoved = NO;
    metadata.currentPosition = [app currentTime];
    return metadata;
}

- (NSString*) getCover {
    NSData* rawData = [[app artworkImage] TIFFRepresentation];
    if(rawData != nil) {
        NSUInteger hash = [[app album] hash];
        NSString* path = [NSString stringWithFormat:@"%@/Playbox.widget/lib/cover%lx.tiff", getBaseDirectory(nil), hash];
        FILE* file = fopen([path cStringUsingEncoding:NSUTF8StringEncoding], "w");
        fwrite([rawData bytes], [rawData length], 1, file);
        fclose(file);
        return path;
    } else {
        return nil;
    }
}

- (NSString*) name { return @"VOX"; }

@end

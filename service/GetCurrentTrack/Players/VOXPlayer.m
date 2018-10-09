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
    return isRunning(@"com.coppertino.Vox") && [app isRunning] && [app playerState] == 1;
}

- (SongMetadata*) getMetadata {
    id dict = @{
                @"artist": [app artist],
                @"albumArtist": [app albumArtist],
                @"name": [app name],
                @"album": [app album],
                @"duration": [NSNumber numberWithDouble:[app totalTime]],
                @"loved": @NO,
                @"position": [NSNumber numberWithDouble:[app currentTime]]
                };
    return [[SongMetadata alloc] initWithDict:dict];
}

- (NSString*) getCover: (NSString*) basePath {
    NSData* rawData = [[app artworkImage] TIFFRepresentation];
    if(rawData != nil) {
        NSUInteger hash;
        if([app album] != nil) {
            hash = [[app album] hash];
        } else {
            hash = [[NSString stringWithFormat:@"%@::%@", [app artist], [app name]] hash];
        }
        NSString* path = [NSString stringWithFormat:@"%@/v%lx.tiff", basePath, hash];
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

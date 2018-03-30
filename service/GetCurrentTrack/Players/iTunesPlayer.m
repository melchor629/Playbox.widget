//
//  iTunesPlayer.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 3/1/18.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import "iTunesPlayer.h"
#import "../ScriptingBridgeHeaders/iTunes.h"

NSString* getBaseDirectory(NSString* extra);

@implementation iTunesPlayer {
    iTunesApplication* app;
}

- (instancetype) init {
    id _self = [super init];
    app = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    return _self;
}

- (bool) isPlaying {
    return isRunning(@"com.apple.iTunes") && [app isRunning] && [app playerState] == iTunesEPlSPlaying;
}

- (SongMetadata*) getMetadata {
    SongMetadata* metadata = [[SongMetadata alloc] init];
    iTunesTrack* currentTrack = [app currentTrack];
    metadata.artistName = [currentTrack albumArtist];
    if(metadata.artistName == nil || [metadata.artistName length] == 0) {
        metadata.artistName = [currentTrack artist];
    }
    metadata.songName = [currentTrack name];
    metadata.albumName = [currentTrack album];
    metadata.songDuration = [currentTrack duration];
    metadata.isLoved = NO;
    metadata.currentPosition = [app playerPosition];
    return metadata;
}

- (NSString*) getCover {
    iTunesTrack* currentTrack = [app currentTrack];
    SBElementArray<iTunesArtwork*>* artworks = [currentTrack artworks];
    if([artworks count] > 0) {
        iTunesArtwork* artwork = [artworks objectAtIndex:0];
        const char* ext = "bin";
        const void* extData = [[((NSAppleEventDescriptor*)[artwork format]) data] bytes];
        if(!strcmp("GEPJ", extData)) ext = "jpg";
        else if(!strcmp("GNP", extData)) ext = "png";
        else if(!strcmp("FFIT", extData)) ext = "tiff";
        NSData* rawData = [artwork rawData];
        NSUInteger hash;
        if([currentTrack album] != nil) {
            hash = [[currentTrack album] hash];
        } else {
            hash = [[NSString stringWithFormat:@"%@::%@", [currentTrack artist], [currentTrack name]] hash];
        }
        NSString* path = [NSString stringWithFormat:@"%@/Playbox.widget/lib/cover%lx.%s", getBaseDirectory(nil), hash, ext];
        FILE* file = fopen([path cStringUsingEncoding:NSUTF8StringEncoding], "w");
        fwrite([rawData bytes], [rawData length], 1, file);
        fclose(file);
        return path;
    } else {
        return nil;
    }
}

- (NSString*) name { return @"iTunes"; }

@end

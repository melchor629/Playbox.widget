//
//  iTunesGetCurrentTrackScript.h
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 09/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface iTunesCurrentTrack : NSObject
@property (readonly) NSString* artist;
@property (readonly) NSString* albumArtist;
@property (readonly) NSString* album;
@property (readonly) NSNumber* discCount;
@property (readonly) NSNumber* discNumber;
@property (readonly) double duration;
@property (readonly) NSString* genre;
@property (readonly) bool loved;
@property (readonly) NSString* name;
@property (readonly) NSNumber* trackCount;
@property (readonly) NSNumber* trackNumber;
@property (readonly) NSNumber* year;
@property (readonly) double position;
@end

@interface iTunesGetCurrentTrackScript : NSObject
- (iTunesCurrentTrack*) currentTrack;
@end

NS_ASSUME_NONNULL_END

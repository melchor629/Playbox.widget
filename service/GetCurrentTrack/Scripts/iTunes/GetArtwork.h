//
//  iTunesGetArtworkScript.h
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 09/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct _iTunesArtwork {
    const DescType type;
    const NSData* data;
} iTunesArtwork;

@interface iTunesGetArtworkScript : NSObject
- (iTunesArtwork) artwork;
@end

NS_ASSUME_NONNULL_END

//
//  GetArtwork.h
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 09/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct _VOXArtwork {
    const DescType type;
    const NSData* data;
} VOXArtwork;

@interface VOXGetArtworkScript : NSObject
- (VOXArtwork) artwork;
@end

NS_ASSUME_NONNULL_END

//
//  iTunesGetCurrentTrackScript.h
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 09/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "../../Players/Player.h"

NS_ASSUME_NONNULL_BEGIN

@interface iTunesGetCurrentTrackScript : NSObject
- (SongMetadata*) currentTrack;
@end

NS_ASSUME_NONNULL_END

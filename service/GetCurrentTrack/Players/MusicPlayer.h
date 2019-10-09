//
//  MusicPlayer.h
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 09/10/2019.
//  Copyright © 2019 Melchor Garau Madrigal. All rights reserved.
//

#import "Player.h"

NS_ASSUME_NONNULL_BEGIN

@interface MusicPlayer : Player

- (PlayerStatus) status;
- (SongMetadata*) getMetadata;
- (SongCover*) getCover;
- (NSString*) name;

@end

NS_ASSUME_NONNULL_END

//
//  iTunesPlayer.h
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 3/1/18.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"

@interface iTunesPlayer : Player

- (PlayerStatus) status;
- (SongMetadata*) getMetadata;
- (SongCover*) getCover;
- (NSString*) name;

@end

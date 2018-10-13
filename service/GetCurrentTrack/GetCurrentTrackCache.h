//
//  GetCurrentTrackCache.h
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 13/10/2018.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Players/Player.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 @brief Caching and logic component of the app.
 @discussion
 Holds the logic of the caching system and keeps updated the data
 inside the cache.

 Uses a simple in-memory cache for the storage of the elements, with
 a expiration time, that marks the life-time of the items stored.

 This class simplifies the access to the cache and storage of expired
 items.
 */
@interface GetCurrentTrackCache : NSObject

/*!
 @brief Gets the metadata for the playing song in that player.
 @discussion
 The metadata can come from the in-memory cache or directly from the
 AppleScript IPC.

 It keeps updated the cover and the song changed boolean.
 @note
 Supposes that the player is playing or is paused.
 @param player Player from where the metadata is going to be obtained.
 @return The metadata for the player, if it is playing something.
 */
- (SongMetadata* _Nullable) songMetadataForPlayer: (Player*) player;

/*!
 @brief Gets the cover for the playing song in that player.
 @discussion
 Gets the cover, if it has one, for the current song. Gets the cover
 from the in-memory cache or directly from the AppleScript IPC.
 Calls to @link #songMetadataForPlayer: to get the metadata for
 the current song, so it keeps everything updated too.
 @note
 Supposes that the player is playing or is paused.
 @param player Player from where the cover art is going to be obtained.
 @return The song cover for the current song, if any.
 */
- (SongCover* _Nullable) songCoverForPlayer: (Player*) player;

/*!
 @brief Tells if within the last second, the song has changed.
 @return true if the song has changed recently, false otherwise.
 */
- (bool) songChangedForPlayer: (Player*) player;

@end

NS_ASSUME_NONNULL_END

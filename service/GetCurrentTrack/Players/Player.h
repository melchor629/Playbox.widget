//
//  Player.h
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 2/1/18.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#ifndef Player_h
#define Player_h

#import <Foundation/Foundation.h>

/*!
 * Class that holds metadata information about a song
 **/
@interface SongMetadata : NSObject
//! The album artist of the song
@property (readonly, nullable) NSString* albumArtist;
/*! @brief The album name of the song. */
@property (readonly, nullable) NSString* album;
/*! @brief The album artist or artist of the song. */
@property (readonly, nullable) NSString* artist;
//! The number of discs of the album (0 for unknown)
@property (readonly) NSUInteger discCount;
//! The number of the disct of the song (0 for unknown)
@property (readonly) NSUInteger discNumber;
/*! @brief The duration of the song in seconds. */
@property (readonly) double duration;
//! The genre of the song (if known)
@property (readonly, nullable) NSString* genre;
/*! @brief `true` if the song is loved/liked. */
@property (readonly) bool loved;
//! The number of tracks of the disc (0 for unknown)
@property (readonly) NSUInteger trackCount;
//! The track number of the song in the disct (0 for unknown)
@property (readonly) NSUInteger trackNumber;
//! The year when the song was released (0 for unknown)
@property (readonly) NSUInteger year;
/*! @brief The song/track name. */
@property (readonly, nonnull) NSString* name;
/*! @brief The current playing position in seconds. */
@property (readonly) NSInteger playerPosition;

- (instancetype _Nonnull) init;
- (instancetype _Nonnull) initWithDict: (NSDictionary* _Nonnull) dict;
- (instancetype _Nonnull) initWithAlbum: (NSString* _Nonnull) album andArtist: (NSString* _Nonnull) artist;
- (NSDictionary* _Nonnull) asDict;
@end

/*!
 * Checks whether if an app with bundle identifier <pre>bundleId</pre>
 * is running.
 * @return <pre>true</pre> if it is running
 **/
bool isRunning(NSString* _Nonnull bundleId);

typedef enum _PlayerStatus {
    PlayerStatusPlaying,
    PlayerStatusPaused,
    PlayerStatusStopped,
    PlayerStatusClosed
} PlayerStatus;

extern const char* _Nonnull const PlayerStatusString[];
extern const NSString* _Nonnull PlayerStatusNSString[];

@interface SongCover : NSObject
@property (readonly, nullable) NSData* data;
@property (readonly, nullable) NSString* type;

+ (instancetype _Nonnull) coverWithData: (NSData* _Nonnull) data andType: (NSString* _Nonnull) type;
+ (instancetype _Nonnull) coverWithUrl: (NSString* _Nonnull) url;

@end

/*!
 * Base class for a Player interface. Allows the service to
 * ask the needed information to a player.
 **/
@interface Player: NSObject

/*!
 * @return the player status
 **/
- (PlayerStatus) status;
/*!
 * @brief Gets the metadata of the current song in that player.
 * @return A SongMetadata object filled with information about the current track.
 * @remark It suposes that the player is playing a song.
 **/
- (SongMetadata* _Nonnull) getMetadata;
/*!
 * @brief Gets a artwork cover.
 * If the album name is not <code>nil</code>, this method will return an image or an URL to it.
 * @discussion If this method returns a path to a file, the file will be deleted in the future.
 * @return An image or an URL to an image
 **/
- (SongCover* _Nullable) getCover;
/*!
 * @brief Gets the name of the player.
 * @return The name of the player.
 **/
- (NSString* _Nonnull) name;

@end

#endif /* Player_h */

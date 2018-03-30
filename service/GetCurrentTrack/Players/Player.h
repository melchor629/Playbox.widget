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
    /*! @brief The album artist or artist of the song. Should not be `nil`. */
    @property NSString* artistName;
    /*! @brief The song/track name. Should not be `nil`. */
    @property NSString* songName;
    /*! @brief The album name of the song. Can be `nil`. */
    @property NSString* albumName;
    /*! @brief The duration of the song in seconds. */
    @property NSInteger songDuration;
    /*! @brief `true` if the song is loved/liked. */
    @property bool isLoved;
    /*! @brief The current playing position in seconds. */
    @property NSInteger currentPosition;
@end

/*!
 * Checks whether if an app with bundle identifier <pre>bundleId</pre>
 * is running.
 * @return <pre>true</pre> if it is running
 **/
bool isRunning(NSString* bundleId);

/*!
 * Base class for a Player interface. Allows the service to
 * ask the needed information to a player.
 **/
@interface Player: NSObject

/*!
 * @return <pre>true</pre> if the player is running and playing a song, <pre>false</pre> otherwise
 **/
- (bool) isPlaying;
/*!
 * @brief Gets the metadata of the current song in that player.
 * @return A SongMetadata object filled with information about the current track.
 * @remark It suposes that the player is playing a song.
 **/
- (SongMetadata*) getMetadata;
/*!
 * @brief Gets a URL/path to the artwork cover.
 * If the album name is not <code>nil</code>, this method will return a path to a image absolute
 * with its current working directory (gained from <code>NSString* getBaseDirectory(NSString* extra);</code>
 * in it, or return a URL to an image.
 * @discussion If this method returns a path to a file, the file will be deleted in the future.
 * @return A path or an URL to an image
 **/
- (NSString*) getCover;
/*!
 * @brief Gets the name of the player.
 * @return The name of the player.
 **/
- (NSString*) name;

@end

#endif /* Player_h */

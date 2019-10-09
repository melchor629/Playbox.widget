//
//  GetCurrentTrackApp.m
//  GetCurrentTrack
//
//  Created by Melchor Garau Madrigal on 4/1/18.
//  Copyright © 2018 Melchor Garau Madrigal. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GetCurrentTrackApp.h"
#import "GetCurrentTrackCache.h"
#import "Network/HTTPServer.h"
#import "Utils/PathRouter.h"
#import "Players/Player.h"
#import "Players/SpotifyPlayer.h"
#import "Players/iTunesPlayer.h"
#import "Players/VOXPlayer.h"
#import "Players/MusicPlayer.h"


NSString* getBaseDirectory(NSString* extra);

#define PORT 45987


@implementation GetCurrentTrackApp {
    NSArray* players;
    NSString* pidFilePath;
    HTTPServer* server;
    PathRouter* router;
    GetCurrentTrackCache* cache;
}

- (instancetype) initWithArgs: (NSDictionary*) args {
    id _self = [super init];
    NSLog(@"Current working directory: %@", getBaseDirectory(nil));

    //Put here new player implementations
    players = @[
               [[SpotifyPlayer alloc] init],
               [[iTunesPlayer alloc] init],
               [[VOXPlayer alloc] init],
               [[MusicPlayer alloc] init],
               ];

    pidFilePath = getBaseDirectory(@"Playbox.widget/lib/pidfile");
    pid_t pid = getpid();
    FILE* pidFile = fopen([pidFilePath cStringUsingEncoding:NSUTF8StringEncoding], "w");
    fprintf(pidFile, "%d", pid);
    fclose(pidFile);

    server = [[HTTPServer alloc] init];
    [server setDelegate:self];
    if(![server listenToAddress:@"::1" andPort:PORT]) {
        [NSApp terminate:self];
        exit(1);
    }
    NSLog(@"Server listening at http://%@:%u", @"[::1]", PORT);
    if(![server listenToAddress:@"127.0.0.1" andPort:PORT]) {
        [NSApp terminate:self];
        exit(1);
    }
    NSLog(@"Server listening at http://%@:%u", @"127.0.0.1", PORT);

    router = [PathRouter pathRouterWithPaths:@[
                                               @"/",
                                               @"/artwork/?",
                                               @"/player/(\\w+)/?",
                                               @"/player/(\\w+)/artwork/?",
                                               @"/players/?",
                                               @"/quit/?",
                                               @"/artwork/([^/]+)/([^/]+)/?"
                                               ]
                                andSelectors:@[
                                               @"requestAllPlayers:withResponse:",
                                               @"requestAllPlayersArtwork:withResponse:",
                                               @"requestPlayer:withResponse:",
                                               @"requestPlayerArtwork:withResponse:",
                                               @"requestListPlayers:withResponse:",
                                               @"requestQuit:withResponse:",
                                               @"requestArtwork:withResponse:"
                                               ]];
    router.delegate = self;

    cache = [[GetCurrentTrackCache alloc] init];

    return _self;
}

//! Returns the first playing player available, or the first
//! paused player if there's no other playing.
- (Player*) getPlayingPlayer {
    Player* pausedPlayer = nil;
    for(NSUInteger i = 0; i < [players count]; i++) {
        Player* player = [players objectAtIndex:i];
        PlayerStatus status = [player status];
        if(status == PlayerStatusPlaying) {
            return player;
        } else if(status == PlayerStatusPaused) {
            pausedPlayer = player;
        }
    }
    return pausedPlayer;
}

- (void) request: (HTTPRequest*) req withResponse: (HTTPResponse*) res {
    if(![router performSelectorForRequest:req andResponse:res]) {
        [res writeJsonAndEnd:@{ @"error": @"Unknown request", @"what": req->path } withStatus:404];
    }
}

- (void) requestAllPlayers: (HTTPRequest*) req withResponse: (HTTPResponse*) res {
    NSUInteger status = 200;
    Player* player = [self getPlayingPlayer];
    NSDictionary* dict = nil;
    if(player != nil) {
        SongMetadata* metadata = [cache songMetadataForPlayer:player];
        if(metadata != nil) {
            id cover = [cache songCoverForPlayer:player];
            NSString* host = [req->headers valueForKey:@"X-Forwarded-Host"];
            if(host == nil) { host = [req->headers valueForKey:@"Host"]; }
            NSString* prefix = [req->headers valueForKey:@"X-Forwarded-Prefix"];
            dict = @{
                     @"metadata": [metadata asDict],
                     @"coverUrl": cover ? [self coverUrlFor: metadata withHost: host andPrefix: prefix] : [NSNull null],
                     @"status": PlayerStatusNSString[[player status]],
                     @"player": [player name]
                     };
        } else {
            dict = @{
                     @"error": @true,
                     @"reason": [NSString stringWithFormat:@"Could not get metadata for player %@", [player name]]
                     };
            status = 500;
        }
    } else {
        dict = @{ @"status": @"stopped" };
    }

    [res setValue:@"application/json; encoding=utf-8" forHeader:@"Content-Type"];
    [res setValue:@"*" forHeader:@"Access-Control-Allow-Origin"];

    [res writeJsonAndEnd:dict withStatus: status];
}

- (void) requestAllPlayersArtwork: (HTTPRequest*) req withResponse: (HTTPResponse*) res {
    Player* player = [self getPlayingPlayer];
    if(player != nil) {
        PlayerStatus status = [player status];
        if(status == PlayerStatusClosed || status == PlayerStatusStopped) {
            res.statusCode = 400;
            [res end];
        } else {
            SongMetadata* metadata = [cache songMetadataForPlayer:player];
            if(metadata != nil) {
                NSString* host = [req->headers valueForKey:@"X-Forwarded-Host"];
                if(host == nil) { host = [req->headers valueForKey:@"Host"]; }
                NSString* prefix = [req->headers valueForKey:@"X-Forwarded-Prefix"];
                res.statusCode = 307;
                [res setValue:[self coverUrlFor:metadata withHost:host andPrefix:prefix]
                    forHeader:@"Location"];
                [res end];
            } else {
                [res writeJsonAndEnd:@{
                                       @"error": @true,
                                       @"reason": [NSString stringWithFormat:@"Could not get metadata for player %@", [player name]]
                                       }
                          withStatus:500];
            }
        }
    } else {
        res.statusCode = 404;
        [res end];
    }
}

- (void) requestPlayer: (PathRequest*) req withResponse: (HTTPResponse*) res {
    NSString* playerName = [req->params objectAtIndex:0];
    NSPredicate* pred = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary<NSString*, id>* bindings) {
        return [[evaluatedObject name] caseInsensitiveCompare: playerName] == NSOrderedSame;
    }];
    NSArray<Player*>* playersFiltered = [players filteredArrayUsingPredicate:pred];

    if([playersFiltered count] == 0) {
        [res writeJsonAndEnd:@{ @"error": @"Player not found", @"what": playerName } withStatus:404];
        return;
    }

    Player* player = [playersFiltered objectAtIndex:0];
    PlayerStatus status = [player status];
    if(status != PlayerStatusClosed && status != PlayerStatusStopped) {
        SongMetadata* metadata = [cache songMetadataForPlayer:player];
        if(metadata != nil) {
            id cover = [cache songCoverForPlayer:player];
            NSString* host = [req->req.headers valueForKey:@"X-Forwarded-Host"];
            if(host == nil) { host = [req->req.headers valueForKey:@"Host"]; }
            NSString* prefix = [req->req.headers valueForKey:@"X-Forwarded-Prefix"];
            [res writeJsonAndEnd:@{
                                   @"metadata": [metadata asDict],
                                   @"coverUrl": cover ? [self coverUrlFor: metadata withHost: host andPrefix: prefix] : [NSNull null],
                                   @"status": PlayerStatusNSString[status],
                                   @"player": [player name]
                                   }];
        } else {
            [res writeJsonAndEnd:@{
                                   @"error": @true,
                                   @"reason": [NSString stringWithFormat:@"Could not get metadata for player %@", [player name]]
                                   }
                      withStatus:500];
        }
    } else {
        [res writeJsonAndEnd:@{ @"status": PlayerStatusNSString[status], @"player": [player name] }];
    }
}

- (void) requestPlayerArtwork: (PathRequest*) req withResponse: (HTTPResponse*) res {
    NSString* playerName = [req->params objectAtIndex:0];
    NSPredicate* pred = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary<NSString*, id>* bindings) {
        return [[evaluatedObject name] caseInsensitiveCompare: playerName] == NSOrderedSame;
    }];
    NSArray<Player*>* playersFiltered = [players filteredArrayUsingPredicate:pred];

    if([playersFiltered count] == 0) {
        [res writeJsonAndEnd:@{ @"error": @"Player not found", @"what": playerName } withStatus:404];
        return;
    }

    Player* player = [playersFiltered objectAtIndex:0];
    PlayerStatus status = [player status];
    if(status == PlayerStatusClosed || status == PlayerStatusStopped) {
        res.statusCode = 400;
        [res end];
    } else {
        SongMetadata* metadata = [cache songMetadataForPlayer:player];
        if(metadata != nil) {
            NSString* host = [req->req.headers valueForKey:@"X-Forwarded-Host"];
            if(host == nil) { host = [req->req.headers valueForKey:@"Host"]; }
            NSString* prefix = [req->req.headers valueForKey:@"X-Forwarded-Prefix"];
            res.statusCode = 307;
            [res setValue:[self coverUrlFor:metadata withHost:host andPrefix:prefix]
                forHeader:@"Location"];
            [res end];
        } else {
            [res writeJsonAndEnd:@{
                                   @"error": @true,
                                   @"reason": [NSString stringWithFormat:@"Could not get metadata for player %@", [player name]]
                                   }
                      withStatus:500];
        }
    }
}

- (void) requestArtwork: (PathRequest*) req withResponse: (HTTPResponse*) res {
    NSString* album = [req->params objectAtIndex:0];
    NSString* artist = [req->params objectAtIndex:1];

    SongMetadata* metadata = [[SongMetadata alloc] initWithAlbum: album andArtist: artist];
    SongCover* cover = [cache songCoverForMetadata: metadata];
    if(cover == nil) {
        res.statusCode = 400;
        [res end];
    } else if([[cover type] isEqualToString:@"url"]) {
        res.statusCode = 307;
        [res setValue:[[NSString alloc] initWithData:cover.data encoding:NSUTF8StringEncoding]
            forHeader:@"Location"];
        [res end];
    } else {
        [res setValue:@"no-store, must-revalidate" forHeader:@"Cache-Control"];
        [res setValue:@"0" forHeader:@"Expires"];
        [res setValue:cover.type forHeader:@"Content-Type"];
        [res writeDataAndEnd:cover.data];
    }
}

- (void) requestListPlayers: (HTTPRequest*) req withResponse: (HTTPResponse*) res {
    NSMutableArray* playerObjects = [[NSMutableArray alloc] init];
    for(Player* player in players) {
        [playerObjects addObject:@{
                                   @"name": [player name],
                                   @"status": PlayerStatusNSString[[player status]]
                                   }];
    }

    [res writeJsonAndEnd:@{ @"players": playerObjects }];
}

- (void) requestQuit: (HTTPRequest*) req withResponse: (HTTPResponse*) res {
    if([req->method caseInsensitiveCompare:@"POST"] == NSOrderedSame) {
        NSLog(@"Requesting quit of daemon");
        [res write:@"OK"];
        [res end];
        [self performSelector:@selector(cleanup) withObject:nil afterDelay:0.5];
        [NSApp performSelector:@selector(terminate:) withObject:self afterDelay:0.5];
    } else {
        [res writeJsonAndEnd:@{ @"error": @"Unknown request", @"what": req->path } withStatus:404];
    }
}

- (void) cleanup {
    [[NSFileManager defaultManager] removeItemAtPath:pidFilePath error:nil];
    [server close];
    NSLog(@"Closing daemon...");
}

- (NSString*) coverUrlFor: (SongMetadata*) metadata withHost: (NSString* __nullable) host andPrefix: (NSString* __nullable) prefix {
    NSMutableString* coverUrl = [[NSMutableString alloc] initWithString:@"http://"];
    if(host != nil) {
        [coverUrl appendString:host];
    } else {
        [coverUrl appendFormat:@"localhost:%u", PORT];
    }
    if(prefix != nil) {
        [coverUrl appendString:prefix];
    }
    NSString* album = metadata.album != nil ? metadata.album : @"unknown";
    NSString* artist = metadata.albumArtist != nil ? metadata.albumArtist : (metadata.artist ? metadata.artist : @"unknown");
    album = [self appUrlEncode: album];
    artist = [self appUrlEncode: artist];
    [coverUrl appendFormat: @"/artwork/%@/%@", album, artist];
    return coverUrl;
}

- (NSString*) appUrlEncode: (NSString*) string {
    return [[string stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLPathAllowedCharacterSet] stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
}

@end

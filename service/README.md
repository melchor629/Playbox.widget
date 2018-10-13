# GetCurrentTrack

Background service that waits for a request and returns the metadata of the song that is currently playing in a player.
Supports iTunes, Spotify and VOX.

## How does it works?

Creates a simple HTTP server at port `45987`. When a request is received in the server, will query information from the
players (if there are changes) and return a JSON with the results.

The program doesn't run in background by default, must use the argument `-d` to make it run as a service/daemon.

An example of request/response can be:

```
 $ curl localhost:45987
{"metadata":{"discNumber":null,"album":"Tumult","trackNumber":1,"position":5,"trackCount":null,"loved":false,"discCount":null,"year":null,"duration":498.827,"albumArtist":"MEUTE","artist":"MEUTE","genre":null,"name":"The Man with the Red Face"},"coverUrl":"http:\/\/i.scdn.co\/image\/e169b75e54b68dbe2957581272b4cbd97e31d4e8","status":"playing","songChanged":false,"player":"Spotify"}
```

The artwork has different meanings depending of the player. In Spotify is the URL to the artwork, from the internet. In
iTunes and VOX is a relative path (relative from `~/Library/Application Support/Übersicht/widgets`) to the artwork placed
there as a temporary file. These files are erased when some time passes (and are not used) or when the service is closed.

This service is ready to be installed as a _Launch Daemon_ with the easy script `install_service.command`. This will copy, configure and load the daemon. And it will run at the start. To disable the daemon, run `launchctl unload -w ~/Library/LaunchAgents/me.melchor9000.getcurrenttrack.plist`. To enable again, the same command but with `load` instead of `unload`.

## Why a background service for the widget?

Originally, when I downloaded the widget, I saw that a system service called _System Events_ was using about 10% (of 400%)
of CPU, that's quite a bit for a script like that. Also, when my HDD is busy, I noticed the widget was updating strangely.

So I ended up by doing the same the [original AppleScript][1] was doing, but in Objective-C and as a background service.

## Want to add another player in the background service?

To add a new player, you can [fill an issue][2] or make a [pull request][3].

To add (in code) a new player you must create a new class extending from `Player` inside `GetCurrentTrack/Players` and
adding an instance of it in the array of [GetCurrentTrackApp.m:38][4].

## API

 - `/`: Gets the current playing song of any of the players
 - `/artwork`: Gets the artwork of the playing song or HTTP status 404 if there's no one
 - `/player/:playerName`: Gets the current playing song for the desired player (name case insensitive).
 - `/player/:playerName/artwork`: Gets the artwork of the desired player or HTTP status 404 if there's no one.
 - `/players`: Gets a list of available players and their status.
 - `/quit`: After 0.5s, the server/daemon will close.


  [1]: https://github.com/Pe8er/Playbox.widget/blob/master/Playbox.widget/lib/Get%20Current%20Track.applescript
  [2]: https://github.com/melchor629/Playbox.widget/issues/new
  [3]: https://github.com/melchor629/Playbox.widget/compare
  [4]: https://github.com/melchor629/Playbox.widget/blob/master/service/GetCurrentTrack/GetCurrentTrackApp.m#38

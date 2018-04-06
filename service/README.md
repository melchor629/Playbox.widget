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
{"isPlaying":true,"player":"iTunes","albumName":"What Went Down","isLoved":false,"artistName":"Foals","songName":"Mountain at My Gates","songDuration":244,"currentPosition":1,"coverUrl":"\/Playbox.widget\/lib\/covere58d3f4f97afdb18.jpg","songChanged":false}
```

The artwork has different meanings depending of the player. In Spotify is the URL to the artwork, from the internet. In
iTunes and VOX is a relative path (relative from `~/Library/Application Support/Übersicht/widgets`) to the artwork placed
there as a temporary file. These files are erased when some time passes (and are not used) or when the service is closed.

To close the service, search for `GetCurrentTrack` in _System Monitor_ and close it. You can also use `pkill GetCurrentTrack`.
Well, I think is not necessary to close the service as its goal is to optimize the widget.

## Why a background service for the widget?

Originally, when I downloaded the widget, I saw that a system service called _System Events_ was using about 10% (of 400%)
of CPU, that's quite a bit for a script like that. Also, when my HDD is busy, I noticed the widget was updating strangely.

So I ended up by doing the same the [original AppleScript][1] was doing, but in Objective-C and as a background service.

## Want to add another player in the background service?

To add a new player, you can [fill an issue][2] or make a [pull request][3].

To add (in code) a new player you must create a new class extending from `Player` inside `GetCurrentTrack/Players` and
adding an instance of it in the array of [GetCurrentTrackApp.m:51][4].

  [1]: https://github.com/Pe8er/Playbox.widget/blob/master/Playbox.widget/lib/Get%20Current%20Track.applescript
  [2]: https://github.com/melchor629/Playbox.widget/issues/new
  [3]: https://github.com/melchor629/Playbox.widget/compare
  [4]: https://github.com/melchor629/Playbox.widget/blob/master/service/GetCurrentTrack/GetCurrentTrackApp.m#L51

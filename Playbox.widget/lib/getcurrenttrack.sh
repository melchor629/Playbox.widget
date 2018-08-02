#!/bin/bash

if ! curl localhost:45987 2>/dev/null; then
    echo '{'
    echo '"isPlaying": true,'
    echo '"songName": "Daemon is not running",'
    echo '"artistName": "Check README.md for more info",'
    echo '"albumName": null,'
    echo '"songDuration": 1,'
    echo '"currentPosition": 1,'
    echo '"coverUrl": "\/Playbox.widget\/lib\/default.png",'
    echo '"player": "Nothing",'
    echo '"songChanged": true'
    echo '}'
fi
#!/bin/bash

lib=$(pwd)/Playbox.widget/lib
GetCurrentTrack="$lib/GetCurrentTrack"
if [[ ! -f "$lib/pidfile" ]]; then
    "$GetCurrentTrack" -d
elif ps -p $(cat "$lib/pidfile") > /dev/null; then
    echo -n " " #Is running
else
    rm "$lib/pidfile"
    "$GetCurrentTrack" -d
fi

echo > /tmp/get_current_track
cat < /tmp/get_current_track
#!/bin/bash

lib=$(pwd)/Playbox.widget/lib
GetCurrentTrack="$lib/GetCurrentTrack"

function wait_daemon {
    #Wait untile the pidfile is created
    while [ ! -f "$lib/pidfile"]; do
        python -c "import time; time.sleep(0.1)"
    done
    #When is created, wait a bit, just in case
    python -c "import time; time.sleep(0.1)"
}

if [[ ! -f "$lib/pidfile" ]]; then
    #Wait until the daemon is running
    "$GetCurrentTrack" -d
    wait_daemon
elif ps -p $(cat "$lib/pidfile") > /dev/null; then
    echo -n " "
else
    #Wait until the daemon is running
    rm "$lib/pidfile"
    "$GetCurrentTrack" -d
    wait_daemon
fi

curl localhost:45987 2>/dev/null


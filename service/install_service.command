#!/bin/bash

function error {
    echo "$1"
    exit 1
}

PLIST=~/Library/LaunchAgents/me.melchor9000.getcurrenttrack.plist
PLAYBOX_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

echo "Installing launch daemon"
cp "$PLAYBOX_PATH/me.melchor9000.getcurrenttrack.plist" ~/Library/LaunchAgents || error "Could not copy plist file"
sed -i '' s/\$USER/$USER/g $PLIST || error "Could not configure plist file"

echo "Enabling launch daemon"
launchctl load -w $PLIST || error "Could not enable daemon"

echo "Done :)"
echo "To disable the daemon, run \`launchctl unload -w $PLIST\`"

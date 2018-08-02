#!/bin/bash

[[ -d dist ]] && rm -r dist
mkdir -p dist

cp -r Playbox.widget dist
cp service/install_service.command service/me.melchor9000.getcurrenttrack.plist dist/Playbox.widget
cp service/Build/Products/Debug/GetCurrentTrack dist/Playbox.widget/lib

cd dist
zip -r -9 ../Playbox.zip Playbox.widget -x .DS_Store Playbox.widget/.DS_Store Playbox.widget/lib/.DS_Store
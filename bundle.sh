#!/bin/bash

[[ -d dist ]] && rm -r dist
mkdir -p dist

cd service
echo " > Building service"
xcodebuild -configuration Debug > /dev/null || exit $?
cd ..

echo " > Preparing zip"
cp -r Playbox.widget dist || exit $?
cp service/install_service.command service/me.melchor9000.getcurrenttrack.plist dist/Playbox.widget || exit $?
cp service/Build/Products/Debug/GetCurrentTrack dist/Playbox.widget/lib || exit $?

cd dist
echo " > Zipping folder"
zip -r -9 ../Playbox.zip Playbox.widget -x .DS_Store Playbox.widget/.DS_Store Playbox.widget/lib/.DS_Store || exit $?

echo "✔️ Done :)"
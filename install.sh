#!/bin/zsh

# fixed version
fixedVersion=21-internal+0-2025-02-04-102810

#
# install faulty version
#

# build dmg
mvn clean install jpackage:jpackage -Djfx-graphics.version=21

# install dmg
pkill OpenUriFxApp
hdiutil attach ./target/dist/OpenUriFxApp-1.0.dmg
sudo cp -R /Volumes/OpenUriFxApp/OpenUriFxApp.app /Applications
hdiutil unmount /Volumes/OpenUriFxApp

# open app
open /Applications/OpenUriFxApp.app

echo Waiting 10 seconds for execution of fixed version...
sleep 10

#
# install fixed version
#

# build dmg
mvn clean install jpackage:jpackage -Djfx-graphics.version=$fixedVersion

# install dmg
pkill OpenUriFxApp
hdiutil attach ./target/dist/OpenUriFxApp-1.0.dmg
sudo cp -R /Volumes/OpenUriFxApp/OpenUriFxApp.app /Applications
hdiutil unmount /Volumes/OpenUriFxApp

# open app
open /Applications/OpenUriFxApp.app


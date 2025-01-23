#!/bin/zsh

#
# install faulty version
#

# build dmg
mvn clean install jpackage:jpackage -Djfx-graphics.version=24-ea+19

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

# copy fixed javafx-graphics jar to ~/.m2/repository
mkdir -p ~/.m2/repository/org/openjfx/javafx-graphics/24-internal+0-2025-01-20-190918/
cp -R ./javafx-graphics/* ~/.m2/repository/org/openjfx/javafx-graphics/24-internal+0-2025-01-20-190918/

# build dmg
mvn clean install jpackage:jpackage

# install dmg
pkill OpenUriFxApp
hdiutil attach ./target/dist/OpenUriFxApp-1.0.dmg
sudo cp -R /Volumes/OpenUriFxApp/OpenUriFxApp.app /Applications
hdiutil unmount /Volumes/OpenUriFxApp

# open app
open /Applications/OpenUriFxApp.app


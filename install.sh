#!/bin/zsh

# fixed version
fixedVersion=21-internal+0-2025-02-04-102810

# functions
function check_result {
  result=$(cat "/tmp/openurifx-output.txt")
  if [[ $result == "1" ]]; then
    echo Success
  else
    echo Failure
  fi

  echo "(Expected: 1, Actual: $result)"
}

#
# install faulty version
#

# build dmg
echo "Building and installing faulty version (this may take a view seconds)..."
mvn clean install jpackage:jpackage -Djfx-graphics.version=21 > /dev/null

# install dmg
pkill OpenUriFxApp
hdiutil attach ./target/dist/OpenUriFxApp-1.0.dmg > /dev/null
sudo cp -R /Volumes/OpenUriFxApp/OpenUriFxApp.app /Applications
hdiutil unmount /Volumes/OpenUriFxApp > /dev/null

# open app
open /Applications/OpenUriFxApp.app

echo "Waiting 10 seconds for execution of faulty version..."
sleep 10

echo "Faulty version result:"
check_result

#
# install fixed version
#

# build dmg
echo "Building and installing fixed version (this may take a view seconds)..."
mvn clean install jpackage:jpackage -Djfx-graphics.version=$fixedVersion > /dev/null

# install dmg
pkill OpenUriFxApp
hdiutil attach ./target/dist/OpenUriFxApp-1.0.dmg > /dev/null
sudo cp -R /Volumes/OpenUriFxApp/OpenUriFxApp.app /Applications
hdiutil unmount /Volumes/OpenUriFxApp > /dev/null

# open app
open /Applications/OpenUriFxApp.app

echo "Waiting 10 seconds for execution of fixed version..."
sleep 10

echo "Fixed version result:"
check_result
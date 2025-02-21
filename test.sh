#!/bin/zsh

# fixed version
fixedVersion=21-internal+0-2025-02-04-102810
# time to wait for results
waitTime=12

# functions
function check_result {
  result=$(cat "/tmp/openurifx-output.txt")
  if [[ $result == "uri-receive-count: 1, native-menu-bar: true" ]]; then
    echo Success
  else
    echo Failure
    echo "Expected: [uri-receive-count: 1, native-menu-bar: true], Actual: [$result]"
  fi
}

function install_app {
  #
  # install faulty version
  #

  pkill OpenUriFxApp

  # build dmg
  # echo "Building and installing faulty version (this may take some time)..."
  mvn clean install jpackage:jpackage -Djfx-graphics.version=21 > /dev/null

  # install dmg
  hdiutil attach ./target/dist/OpenUriFxApp-1.0.dmg > /dev/null
  sudo cp -R /Volumes/OpenUriFxApp/OpenUriFxApp.app /Applications
  hdiutil unmount /Volumes/OpenUriFxApp > /dev/null

  # open app
  open /Applications/OpenUriFxApp.app

  sleep $waitTime
  pkill OpenUriFxApp

  echo ""
  echo "Faulty version result:"
  check_result

  #
  # install fixed version
  #

  # build dmg
  # echo "Building and installing fixed version (this may take some time)..."
  mvn clean install jpackage:jpackage -Djfx-graphics.version=$fixedVersion > /dev/null

  # install dmg
  hdiutil attach ./target/dist/OpenUriFxApp-1.0.dmg > /dev/null
  sudo cp -R /Volumes/OpenUriFxApp/OpenUriFxApp.app /Applications
  hdiutil unmount /Volumes/OpenUriFxApp > /dev/null

  # open app
  open /Applications/OpenUriFxApp.app

  sleep $waitTime
  pkill OpenUriFxApp

  echo ""
  echo "Fixed version result:"
  check_result
}

echo "Running test, this may take some time..."

echo "swing-first" > /tmp/openurifx-order.txt
echo ""
echo "Testing with initializing swing first"
install_app

echo "before-show" > /tmp/openurifx-order.txt
echo ""
echo "Testing with initializing swing before show"
install_app

echo "after-show" > /tmp/openurifx-order.txt
echo ""
echo "Testing with initializing swing after show"
install_app

echo ""
echo "Finished!"
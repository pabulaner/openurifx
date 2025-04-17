#!/bin/zsh

############################
# variables
############################

# main version
jdk_main=./jdk/main
# fixed version
jdk_fix=./jdk/fix

# main version
jfx_main=main
# fixed version
jfx_fix=fix

# start awt before jfx
mode_before=before
# start awt after jfx
mode_after=after

# name of the app
app_name=OpenUriFxApp
# url prefix the app handles
url_prefix=openurifx
# file for the app output
output_file=/tmp/"$app_name"-output.txt
# file for the results
result_file=./results.txt
# time to sleep after killing the app
kill_sleep_time=12
# time to sleep after opening the app
open_sleep_time=12
# time to sleep after opening the url
url_sleep_time=4

############################
# functions
############################

# install the app
install_app () {
  # kill app, if already running
  pkill "$app_name"

  # set java version
  export JAVA_HOME="$1"

  # build dmg
  mvn clean install jpackage:jpackage -Djfx.version="$2" > /dev/null

  # install dmg
  hdiutil attach ./target/dist/"$app_name".dmg > /dev/null
  sudo cp -R /Volumes/"$app_name"/"$app_name".app /Applications
  hdiutil unmount /Volumes/"$app_name" > /dev/null
}

# open the app
open_app () {
  # kill app, if already running
  pkill "$app_name"
  sleep "$kill_sleep_time"

  # set the mode env variable
  export APP_MODE="$1"

  # open the app with the mode argument
  open /Applications/OpenUriFxApp.app

  # wait, so app is really open
  sleep "$open_sleep_time"
}

# test the app
test_app () {
  # trigger the open url event
  open "$url_prefix"://test

  # wait, so app has received the url and written the output
  sleep "$url_sleep_time"

  # print result
  {
    echo "Result for [jdk: '$1', jfx: '$2', mode: '$3']:";
    cat "$output_file";
    echo "";
  } >> "$result_file"
}

############################
# execution
############################

jdk_versions=("$jdk_main" "$jdk_fix")
jfx_versions=("$jfx_main" "$jfx_fix")
modes=("$mode_before" "$mode_after")

rm "$result_file"

for jdk_version in "${jdk_versions[@]}"; do
  for jfx_version in "${jfx_versions[@]}"; do
    echo "Installing app..."
    install_app "$jdk_version" "$jfx_version"

    for mode in "${modes[@]}"; do
      echo "Opening app..."
      open_app "$mode"

      echo "Testing app..."
      test_app "$jdk_version" "$jfx_version" "$mode"
    done
  done
done
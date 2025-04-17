#!/bin/zsh

############################
#
# info: You need to have java version 17 and 24 installed or
#       change those exported versions at the end of the file
#
############################

check_fail () {
  if [ "$?" -ne 0 ]; then
    echo "Setup failed!"
    exit 1
  fi
}

print_info () {
  echo ""
  echo "|----------------------------"
  echo "| [Setup Info]: $1"
  echo "|----------------------------"
  echo ""
}

project_dir=$(pwd)

############################
# setup
############################

print_info "Setup..."

# folder for jdk and jfx repositories
mkdir pabulaner
# folder for build jdk
mkdir jdk
# folder for build jfx
mkdir repository

############################
# get sources
############################

print_info "Cloning repos..."

git clone https://github.com/pabulaner/jdk.git ./pabulaner/jdk
git clone https://github.com/pabulaner/jfx.git ./pabulaner/jfx

print_info "Finished cloning repos"

############################
# build jdk
############################

build_jdk () {
  print_info "Building jdk from branch '$1' with name '$2'..."

  cd ./pabulaner/jdk
  git checkout "$1"

  bash configure
  check_fail
  make images
  check_fail
  mv ./build/*/images/jdk ../../jdk/"$2"

  cd ./../..

  print_info "Finished building jdk"
}

############################
# build jfx
############################

build_jfx () {
  print_info "Building jfx from branch '$1' with name '$2'..."

  cd ./pabulaner/jfx
  git checkout "$1"

  sh gradlew clean
  check_fail
  sh gradlew
  check_fail
  sh gradlew -PMAVEN_PUBLISH=true -PRELEASE_VERSION_LONG="$2" -Dmaven.repo.local="$project_dir"/repository publishToMavenLocal
  check_fail

  cd ./../..

  print_info "Finished building jfx"
}

############################
# build
############################

export JAVA_HOME=$(/usr/libexec/java_home -v 24)
export JDK_HOME=$(/usr/libexec/java_home -v 24)

build_jdk master main
build_jdk embedded-event fix

export JAVA_HOME=$(/usr/libexec/java_home -v 17)
export JDK_HOME=$(/usr/libexec/java_home -v 24)

build_jfx master main
build_jfx embedded-event fix


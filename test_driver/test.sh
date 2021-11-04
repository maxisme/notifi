#!/bin/bash
device=$1
branch=$2
if [ -n "$2" ]; then
  if [[ "$branch" == "master" ]]; then
    echo "$3" | base64 --decode >.env
  else
    echo "$4" | base64 --decode >.env
  fi
fi

if [[ $device == *"iPhone"* ]]; then
  if ! xcrun simctl boot "$device"; then
    exit 1
  fi
elif [[ $device == *"macos"* ]]; then
    flutter config --enable-macos-desktop
elif [[ $device == *"linux"* ]]; then
    flutter config --enable-linux-desktop
fi

flutter doctor

flutter drive --target=test_driver/app.dart -d "$device"

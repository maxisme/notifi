#!/bin/bash
cd "$(dirname "$0")"
flutter upgrade

# format
if ! flutter format lib --set-exit-if-changed; then
  exit 1
fi
if ! flutter format test --set-exit-if-changed; then
  exit 1
fi

# run lint
if ! flutter analyze; then
  exit 1
fi

# don't run tests if linux device
if [[ $(uname -s) == "Linux" ]]
then
  echo "skipping tests"
  exit 0
fi

# run tests
flutter test
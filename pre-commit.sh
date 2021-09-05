#!/bin/bash

flutter channel stable
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

# run tests
flutter test test/
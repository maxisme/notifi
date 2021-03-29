#!/bin/bash

if ! flutter format lib --set-exit-if-changed; then
  exit 1
fi

if ! flutter format test --set-exit-if-changed; then
  exit 1
fi

if ! flutter analyze; then
  exit 1
fi

flutter test
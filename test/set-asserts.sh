#!/bin/bash
# shellcheck disable=SC2164
cd "$(dirname "$0")"

rm -rf failures golden-asserts
flutter test --update-goldens
out=$(shasum golden-asserts/**/** | cut -d " " -f1 | uniq -d | sed '/^$/d')
if [ -n "$out" ]; then
  echo "DUPLICATES"
  echo "$out - run $ shasum golden-asserts/**/**"
  exit 1
fi

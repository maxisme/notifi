#!/bin/bash
# shellcheck disable=SC2164
cd "$(dirname "$0")"

# convert -list font | grep Font:

convert "template.png" \
  \( ../ios/1.png -resize x1245 \) -geometry +1203+80 -composite \
  "macos.png"

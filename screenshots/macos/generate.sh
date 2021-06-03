#!/bin/bash
# convert -list font | grep Font:

convert "template.png" \
  \( ../ios/1.png -resize x1245 \) -geometry +1203+80 -composite \
  "macos.png"

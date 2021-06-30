#!/bin/bash

convert "utils/Nexus 6P.png" \
  1.png -geometry +59+330 -composite \
  "1_framed.png"

convert "utils/Nexus 6P.png" \
  2.png -geometry +59+330 -composite \
  "2_framed.png"

height=2109
width=1080
font_size=120

for filename in *_framed.png; do
  out=$(basename "$filename" | sed 's/_framed.png//g')
  bash ../../test_driver/add-text.sh "../screenshots/android/$filename" "../android/fastlane/metadata/android/en-GB/images/phoneScreenshots/${out}_en-GB.png" $font_size $height $width
done
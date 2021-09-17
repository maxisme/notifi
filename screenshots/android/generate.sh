#!/bin/bash
height=2109
width=1080
font_size=120

for filename in *.png; do
  out=$(basename "$filename" | sed 's/.png//g')
  framed="framed/${out}.png"
  convert "utils/Nexus 6P.png" \
    "$filename" -geometry +59+330 -composite -strip \
    "$framed"

  bash ../../test_driver/add-text.sh "../screenshots/android/$framed" "../android/fastlane/metadata/android/en-GB/images/phoneScreenshots/${out}_en-GB.png" $font_size $height $width
done
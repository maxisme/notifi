#!/bin/bash
# shellcheck disable=SC2164
cd "$(dirname "$0")"

# convert -list font | grep Font:

for filename in *.png; do
  out=$(basename "$filename" | sed 's/.png//g')
  convert "utils/template.png" \
    \( "$filename" -resize x1245 \) -geometry +1203+80 -composite -strip \
    "framed/${out}.png"
done

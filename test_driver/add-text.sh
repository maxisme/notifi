#!/bin/bash
cd "$(dirname "$0")"

height_red=0.8
padding=40

# args
filename=$1
out=$2
font_size=$3
height=$4
width=$5

font_size2=$(echo "$font_size-50" | bc)
height=$(echo "$height-($padding*2)" | bc)
width=$(echo "$width-($padding*2)" | bc)
resize_h=$(echo "$height"*$height_red | bc)
logo_h=$(echo "$resize_h+300" | bc)
desc_h=$(echo "$logo_h-120" | bc)
desc_h2=$(echo "$desc_h-80" | bc)

convert "$filename" \
  -background "#bc2122" \
  -gravity South \
  -resize "x$resize_h" -extent "${width}x${height}" \
  -font "../fonts/Inconsolata-Bold.ttf" -pointsize $font_size -fill "#fff" -annotate "+0+$logo_h" 'notifi' \
  -font "../fonts/Inconsolata.ttf" -pointsize "$font_size2" -fill "#fff" -annotate "+0+$desc_h" 'Receive push notifications' \
  -font "../fonts/Inconsolata.ttf" -pointsize "$font_size2" -fill "#fff" -annotate "+0+$desc_h2" 'over HTTP.' \
  -bordercolor "#bc2122" -border "${padding}x${padding}" -strip \
  "$out"

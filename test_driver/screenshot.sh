#!/bin/bash
# shellcheck disable=SC2164
cd "$(dirname "$0")"
SS_PATH="../screenshots/"

###########
# android #
###########

(cd ../ && flutter drive --target=test_driver/app.dart -d "emulator-5554")
mv ${SS_PATH}*.png "${SS_PATH}android/"

########
## iOS #
########
IOS_SS_PATH="../ios/fastlane/screenshots/en-GB/"

IOS_DEVICES=("iPhone 11 Pro Max" "iPad Pro (12.9-inch) (4th generation)" "iPhone 8 Plus")
IOS_DEVICE_PATHS=("IPHONE_65" "IPAD_PRO_129,IPAD_PRO_3GEN_129" "IPHONE_55")

# print simulator IOS_DEVICES
xcrun simctl list

for i in "${!IOS_DEVICES[@]}"; do
  device="${IOS_DEVICES[$i]}"
  device_path="${IOS_DEVICE_PATHS[$i]}"

  # start simulator
  if ! xcrun simctl boot "$device"; then
    exit 1
  fi

  # run integration test with screenshots
  (cd ../ && flutter drive --target=test_driver/app.dart -d "$device")
  mv ${SS_PATH}*.png "${SS_PATH}ios/"

  # stop simulator
  xcrun simctl shutdown "$device"

  # convert screenshots to appstore file names
  for path in $(echo "$device_path" | tr "," "\n"); do
    cnt=0
    for filename in "${SS_PATH}ios/"*.png; do
      cp "$filename" "${IOS_SS_PATH}${cnt}_APP_${path}_${cnt}.png"
      ((cnt = cnt + 1))
    done
  done
done

# put device frames round screenshots
(cd ../ios/ && fastlane frameit)

# wrap screenshot frames with text
for filename in "${IOS_SS_PATH}"*_framed.png; do

  height_red=0.8
  padding=40

  # calc positions
  height=2732
  width=2048
  font_size=120
  if [[ "$filename" == *"IPHONE_65"* ]]; then
    width=1242
    height=2688
    font_size=110
  elif [[ "$filename" == *"IPHONE_55"* ]]; then
    width=1125
    height=2436
    font_size=100
  fi

  font_size2=$(echo "$font_size-50" | bc)

  height=$(echo "$height-($padding*2)" | bc)
  width=$(echo "$width-($padding*2)" | bc)

  resize_h=$(echo "$height"*$height_red | bc)
  logo_h=$(echo "$resize_h+250" | bc)
  desc_h=$(echo "$logo_h-120" | bc)
  desc_h2=$(echo "$desc_h-80" | bc)

  out=$(basename "$filename" | sed 's/_framed//g')

  convert "$filename" \
    -background "#bc2122" \
    -gravity South \
    -resize "x$resize_h" -extent "${width}x${height}" \
    -font "../fonts/Inconsolata-Bold.ttf" -pointsize $font_size -fill "#fff" -annotate "+0+$logo_h" 'notifi' \
    -font "../fonts/Inconsolata.ttf" -pointsize "$font_size2" -fill "#fff" -annotate "+0+$desc_h" 'Receive push notifications' \
    -font "../fonts/Inconsolata.ttf" -pointsize "$font_size2" -fill "#fff" -annotate "+0+$desc_h2" 'over HTTP(s).' \
    -bordercolor "#bc2122" -border "${padding}x${padding}" \
    "${IOS_SS_PATH}${out}"
done

# delete framed images
rm "$IOS_SS_PATH"*"framed.png"

# run macos screenshot setup
bash ../screenshots/macos/generate.sh

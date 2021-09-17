#!/bin/bash
# shellcheck disable=SC2164
cd "$(dirname "$0")"
SS_DIR="../screenshots/"

ls -n /Applications/ | grep Xcode

############
## android #
############
#(cd ../ && flutter drive --target=test_driver/app.dart -d "emulator-5554")
#if [ $? -eq 1 ]; then
#  exit 1
#fi
#mv ${SS_DIR}*.png "${SS_DIR}android/"
#
## put device frames round screenshots
#(cd "${SS_DIR}android/" && bash generate.sh)
#
#########
### iOS #
#########
#IOS_SS_DIR="../ios/fastlane/screenshots/en-GB/"
#IOS_DEVICES=("iPhone 12 Pro Max" "iPad Pro (12.9-inch) (4th generation)" "iPhone 8 Plus")
#IOS_DEVICE_PATHS=("IPHONE_65" "IPAD_PRO_129,ipadPro129-3rd-gen" "IPHONE_55")
#
## print simulator IOS_DEVICES
#xcrun simctl list
#
#for i in "${!IOS_DEVICES[@]}"; do
#  device="${IOS_DEVICES[$i]}"
#  device_path="${IOS_DEVICE_PATHS[$i]}"
#
#  # start simulator
#  if ! xcrun simctl boot "$device"; then
#    exit 1
#  fi
#
#  # run integration test with screenshots
#  (cd ../ && flutter drive --target=test_driver/app.dart -d "$device")
#  mv ${SS_DIR}*.png "${SS_DIR}ios/"
#
#  # stop simulator
#  xcrun simctl shutdown "$device"
#
#  # convert screenshots to appstore file names
#  for path in $(echo "$device_path" | tr "," "\n"); do
#    cnt=0
#    for filename in "${SS_DIR}ios/"*.png; do
#      cp "$filename" "${IOS_SS_DIR}${cnt}_APP_${path}_${cnt}.png"
#      ((cnt = cnt + 1))
#    done
#  done
#done
#
## put device frames round screenshots
#(cd "${IOS_SS_DIR}" && fastlane frameit)
#
## wrap screenshot frames with text
#for filename in "${IOS_SS_DIR}"*_framed.png; do
#
#  out=$(basename "$filename" | sed 's/_framed//g')
#  out="${IOS_SS_DIR}${out}"
#
#  # calc positions
#  height=2732
#  width=2048
#  font_size=120
#  if [[ "$filename" == *"IPHONE_65"* ]]; then
#    width=1284
#    height=2778
#    font_size=110
#  elif [[ "$filename" == *"IPHONE_55"* ]]; then
#    width=1242
#    height=2208
#    font_size=100
#  fi
#
#  bash add-text.sh "$filename" "$out" $font_size $height $width
#  mv "$out" ../screenshots/ios/
#done

# run macos screenshot setup
(cd ../ && flutter drive --target=test_driver/app.dart -d "macos")
mv ${SS_DIR}*.png "${SS_DIR}macos/"
(cd "${SS_DIR}macos/" && bash generate.sh)

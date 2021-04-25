#!/bin/bash
npm install --global create-dmg

mkdir dmg/
create-dmg build/macos/Build/Products/Release/notifi.app dmg/
mv dmg/* notifi.dmg

dmg_path="notifi.dmg"

/usr/bin/codesign --force --deep --strict --options runtime -s "Z28DW76Y3W" "$dmg_path"

echo "notarizing..."
notarize=$(xcrun altool -t osx --primary-bundle-id it.notifi.notifi --output-format json --notarize-app -f "$dmg_path" --username "$APPLE_USERNAME" --password "$APPLE_PASSWORD")
uuid=$(echo "$notarize" | python3 -c "import sys, json; print(json.load(sys.stdin)['notarization-upload']['RequestUUID'])")
echo "$uuid"

# wait for apple to notarize
sleep 60

while true; do
  check=$(xcrun altool --notarization-info "$uuid" --output-format json --username "$APPLE_USERNAME" --password "$APPLE_PASSWORD")
  echo $check
  status=$(echo "$check" | python3 -c "import sys, json; print(json.load(sys.stdin)['notarization-info']['Status'])")
  echo $status
  if [ "$status" != "in progress" ]; then
    echo "staple dmg..."
    xcrun stapler staple -v "$dmg_path"
    exit
  fi
done

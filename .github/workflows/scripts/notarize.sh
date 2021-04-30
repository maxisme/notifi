#!/bin/bash

/usr/bin/codesign --force --deep --strict --options runtime -s "Developer ID Application: Max Mitchell (Z28DW76Y3W)" "$DMG_PATH"

echo "verify..."
spctl -a -vv build/macos/Build/Products/Release/notifi.app
spctl -a -vv "$DMG_PATH"

echo "notarizing..."
notarize=$(xcrun altool -t osx --primary-bundle-id it.notifi.notifi --output-format json --notarize-app -f "$DMG_PATH" --username "$APPLE_USERNAME" --password "$APPLE_PASSWORD")
uuid=$(echo "$notarize" | python3 -c "import sys, json; print(json.load(sys.stdin)['notarization-upload']['RequestUUID'])")
echo "$uuid"

sleep 60

check=$(xcrun altool --notarization-info "$uuid" --output-format json --username "$APPLE_USERNAME" --password "$APPLE_PASSWORD")
echo $check
status=$(echo "$check" | python3 -c "import sys, json; print(json.load(sys.stdin)['Status'])")
echo $status

echo "staple..."
xcrun stapler staple -v "$DMG_PATH"
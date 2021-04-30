#!/bin/bash

/usr/bin/codesign --force --deep --strict --options runtime -s "Developer ID Application: Max Mitchell (Z28DW76Y3W)" "$DMG_PATH"

echo "verify..."
spctl -a -vv build/macos/Build/Products/Release/notifi.app
spctl -a -vv -vvvv "$DMG_PATH"

echo "notarizing..."
xcrun altool -t osx --primary-bundle-id it.notifi.notifi --output-format json --notarize-app -f "$DMG_PATH" --username "$APPLE_USERNAME" --password "$APPLE_PASSWORD"

echo "verify again ..."
spctl -a -vv -vvvv "$DMG_PATH"

echo "staple..."
xcrun stapler staple -v "$DMG_PATH"

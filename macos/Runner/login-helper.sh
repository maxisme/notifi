#!/bin/bash

SCRIPTPATH="$(dirname "$0")"
origin_helper_path="$SCRIPTPATH/LaunchAtLoginHelper/LaunchAtLoginHelper.app"
helper_dir="$BUILT_PRODUCTS_DIR/$CONTENTS_FOLDER_PATH/Library/LoginItems"
helper_path="$helper_dir/LaunchAtLoginHelper.app"

echo "$origin_helper_path $helper_dir $helper_dir" > /tmp/file.txt

rm -rf "$helper_path"
mkdir -p "$helper_dir"
cp -rf "$origin_helper_path" "$helper_dir/"

defaults write "$helper_path/Contents/Info" CFBundleIdentifier -string "$PRODUCT_BUNDLE_IDENTIFIER-LaunchAtLoginHelper"

if [[ -n $CODE_SIGN_ENTITLEMENTS ]]; then
	codesign --force --entitlements="$(dirname "$origin_helper_path")/LaunchAtLoginHelper.entitlements" --options=runtime --sign="$EXPANDED_CODE_SIGN_IDENTITY_NAME" "$helper_path"
else
	codesign --force --options=runtime --sign="$EXPANDED_CODE_SIGN_IDENTITY_NAME" "$helper_path"
fi
#!/bin/bash
echo "$DEV_P12_CERT" | base64 --decode > devcert.p12 # ios
echo "$DIST_P12_CERT" | base64 --decode > distcert.p12
security create-keychain -p p4ssword build.keychain
security default-keychain -s build.keychain
security unlock-keychain -p p4ssword build.keychain
security import devcert.p12 -k build.keychain -P "$DEV_P12_PASS" -T /usr/bin/codesign
security import distcert.p12 -k build.keychain -P "$DIST_P12_PASS" -T /usr/bin/codesign
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k p4ssword build.keychain

mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
echo "$IOS_PROVISION" | base64 --decode > ~/Library/MobileDevice/Provisioning\ Profiles/profile.mobileprovision
echo "$MAC_PROVISION" | base64 --decode > ~/Library/MobileDevice/Provisioning\ Profiles/mac.provisionprofile

<p align="center"><img height="150px" src="https://github.com/maxisme/notifi/raw/master/images/bell.png"></p>

# [notifi.it](https://notifi.it/)

## App | [Website](https://github.com/maxisme/notifi.it) | [Backend](https://github.com/maxisme/notifi-backend)

[![style: lint](https://img.shields.io/badge/lint-flutter-4BC0F5)](https://pub.dev/packages/lint)
[![MacOS](https://github.com/maxisme/notifi/actions/workflows/ci.yml/badge.svg?branch=master
)](https://github.com/maxisme/notifi/actions/workflows/push.yml)

# Install Flutter

https://flutter.dev/docs/get-started/install
```bash
flutter channel dev
flutter upgrade
```

# Run locally

## create .env with the content
```
SERVER_KEY=Hu2J7b7xA8MndeNS
KEY_STORE=notifi-local
DEV=true
TLS=false
HOST=127.0.0.1:9081
```

## run the backend
[Install docker](https://docs.docker.com/get-docker/)
```
git clone https://github.com/maxisme/notifi-backend
cd notifi-backend
docker-compose up --build app
```

## MacOS build & run

```bash
flutter config --enable-macos-desktop
flutter run -d macos
```

# Tests

## Lint & Test

```bash
bash ./pre-commit.sh
```

## Set screenshot asserts

```
bash ./test/set-asserts.sh
```

# Extras

latest version iOS:
http://itunes.apple.com/lookup?bundleId=it.notifi.notifi

## Add pre-commit hook

```bash
ln -s $(pwd)/pre-commit.sh $(pwd)/.git/hooks/pre-commit
chmod +x $(pwd)/.git/hooks/pre-commit
```

## screenshot on MacOS for iOS

find simulator UUIDs:
```
$ xcrun simctl list devices
```

You want to find the UUIDs of:
 - 6.5", iPhone 11 Pro Max, iPhone Xs Max
 - 5.5", iPhone 8 Plus, iPhone 7 Plus, iPhone 6s Plus
 - 12.9" iPad Pro

1. In a new tab run each of the following (you will need to give permissions for command+t [open new tab])
```bash
$ osascript screenshots/OpenSimulators.scpt
```

Press `cmd+s` to save screen shots in emulators


## Jetbrains flutter plugin:

https://plugins.jetbrains.com/plugin/9212-flutter/versions

## Db path

~/Library/Containers/uk.me.max.notifi/Data/Documents/notifications.db

## GH .env secret to base64 string

cat .env | openssl base64


## Create android icons
Follow [Run Image Asset Studio](https://developer.android.com/studio/write/image-asset-studio#access). With the icon from `ios/Runner/Assets.xcassets/AppIcon.appiconset/1024.png`


### [Splash screen](https://pub.dev/packages/flutter_native_splash)

```bash
$ flutter pub run flutter_native_splash:create
```

### Add new icons

https://github.com/artcoholic/akar-icons-app/tree/main/src/svg

#### inkscape

```
    Select all
    Path -> Stroke to path
    Object -> Ungroup
    Path -> Union
    Path -> Combine
    File -> Vacuum Defs (or Clean up document)
    Save as -> Plain SVG
```

#### generate
Import `flutter-icons-*.zip` into:
https://www.fluttericon.com/ 




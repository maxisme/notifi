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

## Add pre-commit hook

```bash
ln -s $(pwd)/pre-commit.sh $(pwd)/.git/hooks/pre-commit
chmod +x $(pwd)/.git/hooks/pre-commit
```

### screenshot on MacOS for iOS

find simulator UUIDs:
```
$ xcrun simctl list devices
```

You want to find the UUIDs of:
 - 6.5", iPhone 11 Pro Max, iPhone Xs Max
 - 5.5", iPhone 8 Plus, iPhone 7 Plus, iPhone 6s Plus
 - 12.9" iPad Pro

1. In a new tab run each of the following
```
$ xcrun simctl boot "iPhone 11 Pro Max"; flutter run -d "iPhone 11 Pro Max" --dart-define=LOAD_TEMPLATE_DB=1

$ xcrun simctl boot "iPhone 8 Plus"; flutter run -d "iPhone 8 Plus" --dart-define=LOAD_TEMPLATE_DB=1

$ xcrun simctl boot "iPad Pro (12.9-inch) (5th generation)" && flutter run -d "iPad Pro (12.9-inch) (5th generation)" --dart-define=LOAD_TEMPLATE_DB=1

$ open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app/
```

Press `s` to take screen shots on each tab


### Jetbrains flutter plugin:

https://plugins.jetbrains.com/plugin/9212-flutter/versions

### Db path

~/Library/Containers/uk.me.max.notifi/Data/Documents/notifications.db

### GH .env secret to base64 string

cat .env | openssl base64


### Add new icons

https://www.fluttericon.com/



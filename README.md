<p align="center"><img height="150px" src="https://github.com/maxisme/notifi/raw/master/images/bell.png"></p>

# [notifi.it](https://notifi.it/)

## App | [Website](https://github.com/maxisme/notifi.it) | [Backend](https://github.com/maxisme/notifi-backend)

[![style: lint](https://img.shields.io/badge/lint-flutter-4BC0F5)](https://pub.dev/packages/lint)
[![MacOS](https://github.com/maxisme/notifi/actions/workflows/push.yml/badge.svg?branch=master)](https://github.com/maxisme/notifi/actions/workflows/push.yml)

# Install Flutter

https://flutter.dev/docs/get-started/install

## MacOS build & run

```bash
flutter channel master
flutter upgrade
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
flutter doctor
flutter build macos
flutter run -d macos
```

## Tests

### Lint & Test

```bash
bash ./pre-commit.sh
```

### Set screenshot asserts

```
bash ./test/set-asserts.sh
```

## Extras

### Add pre-commit hook

```bash
ln -s $(pwd)/pre-commit.sh $(pwd)/.git/hooks/pre-commit
chmod +x $(pwd)/.git/hooks/pre-commit
```

### Jetbrains flutter plugin:

https://plugins.jetbrains.com/plugin/9212-flutter/versions

### Db path

~/Library/Containers/uk.me.max.notifi/Data/Documents/notifications.db

### GH .env secret to base64 string

cat .env | openssl base64


### Add new icons

https://www.fluttericon.com/



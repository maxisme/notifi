<p align="center"><img height="150px" src="https://github.com/maxisme/notifi/raw/master/images/bell.png"></p>

# [notifi.it](https://notifi.it/)

## App | [Website](https://github.com/maxisme/notifi.it) | [Backend](https://github.com/maxisme/notifi-backend)
[![style: lint](https://img.shields.io/badge/lint-flutter-4BC0F5)](https://pub.dev/packages/lint)
[![MacOS](https://github.com/maxisme/notifi/actions/workflows/push.yml/badge.svg?branch=master)](https://github.com/maxisme/notifi/actions/workflows/push.yml)
# install
```
flutter channel master
flutter upgrade
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
flutter doctor
```
## mac
```
flutter build macos
flutter run -d macos
```

## [install flutter](https://flutter.dev/docs/get-started/install)

## creating sqlite.so
```
gcc -c -Wall -Werror -fpic sqlite3.c
gcc -shared -o sqlite3.so sqlite3.o
```

### Jetbrains flutter plugin:
https://plugins.jetbrains.com/plugin/9212-flutter/versions

## db path 
~/Library/Containers/uk.me.max.notifi/Data/Documents/notifications.db

## gh .env secrets
cat .env | openssl base64

## set screenshot asserts
```
flutter test --update-goldens
```

## pre-commit hook
```bash
cp pre-commit.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

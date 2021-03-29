<p align="center"><img height="150px" src="https://github.com/maxisme/notifi/raw/master/notifi/images/bell.png"></p>

# [notifi.it](https://notifi.it/)

## App | [Website](https://github.com/maxisme/notifi.it) | [Backend](https://github.com/maxisme/notifi-backend)
[![style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lint)
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

## pre-commit (.git/hooks/pre-commit)
```bash
echo "#!/bin/bash
flutter format lib
flutter format test
if flutter analyze; then
  flutter test
  exit $?
else
  exit 1
fi
" > .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

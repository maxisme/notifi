<p align="center"><img height="150px" src="https://github.com/maxisme/notifi/raw/master/notifi/images/bell.png"></p>

# [notifi.it](https://notifi.it/)

## App | [Website](https://github.com/maxisme/notifi.it) | [Backend](https://github.com/maxisme/notifi-backend)

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

# TODO
- [ ] show UI even when network connection fails on creating user
- [ ] add about view
- [ ] log to view
- [ ] fix open notifi at login
- [ ] show HTTP error code when failing to connect to server
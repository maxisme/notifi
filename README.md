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

## db path 
~/Library/Containers/uk.me.max.notifi/Data/Documents/notifications.db

# TODO
- [ ] fix open notifi at login
- [ ] show HTTP error code when failing to connect to server
- [ ] show UI even when network connection fails on creating user
- [ ] add ability to find out whether notification can be expanded or not
- [ ] add log view
- [x] add about view
- [x] interactions not working after delete
- [x] fix local notifications - need to make sure it is turned on
- [x] add unread notification count
- [x] fix mark all as read
- [x] notifications not showing when adding first.
- [x] fix notifications appearing as all unread on startup
- [x] fix menu bar icon
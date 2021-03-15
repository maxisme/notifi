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

## gh .env secrets
cat .env | openssl base64

# TODO
- [ ] check for updates (https://api.github.com/repos/maxisme/notifi/releases/latest)
- [ ] fix number of unread notifications when adding new notifications
- [ ] fix number of unread notifications on startup
- [ ] add copyright stuff to bottom of settings page
- [ ] handle create new credentials not working when network is down (show error)
- [ ] show UI even when network connection fails on creating user
- [ ] add log view and logging
- [ ] add ability to toggle sticky notifications
- [ ] fix showing can be expanded message even when can't on three row message
- [ ] when clicking off menu bar app make it disappear
- [ ] when opening app delete current notifications
- [ ] stop network error from flashing
- [ ] only allow one running version of notifi
- [x] remove window still showing up when opening app
- [x] fix grey square when no unread notifications
- [x] add version to bottom of settings page
- [x] copy on click no notifications credentials
- [x] make "HTTP REQUESTS" a link to -> how to send credentials
- [x] show HTTP error when failing to connect to server
- [x] fix text at two bottom panel buttons
- [x] add about view
- [x] interactions not working after delete
- [x] fix local notifications - need to make sure it is turned on
- [x] add unread notification count
- [x] fix mark all as read
- [x] notifications not showing when adding first.
- [x] fix notifications appearing as all unread on startup
- [x] fix menu bar icon
- [x] fix open notifi at login
- [x] redesign unread notification count
- [x] add link
- [x] add ability to find out whether notification can be expanded or not
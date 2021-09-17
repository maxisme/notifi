<p align="center"><img height="150px" src="https://github.com/maxisme/notifi/raw/master/images/bell.png"></p>

# [notifi.it](https://notifi.it/)

## App | [Website](https://github.com/maxisme/notifi.it) | [Backend](https://github.com/maxisme/notifi-backend)

[![style: lint](https://img.shields.io/badge/lint-flutter-4BC0F5)](https://pub.dev/packages/lint)
[![CI](https://github.com/maxisme/notifi/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/maxisme/notifi/actions/workflows/ci.yml)

# Run locally

## create an .env with the example content
```
SERVER_KEY=Hu2J7b7xA8MndeNS
KEY_STORE=notifi-local
DEV=true
TLS=false
HOST=127.0.0.1:9081
```

## run the backend
 - [Install docker](https://docs.docker.com/get-docker/)
 - use a matching `SERVER_KEY`
```
git clone https://github.com/maxisme/notifi-backend
cd notifi-backend
docker-compose up --build app
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

## linux setup
install (e.g `apt get`) the `build-packages` and `stage-packages` from [snapcraft.yaml](https://github.com/maxisme/notifi/blob/master/snap/snapcraft.yaml#L30-L38)

Get SNAPCRAFT_TOKEN for ci
```bash
snapcraft export-login --snaps notifi --channels stable,candidate -
```

## Jetbrains flutter plugin:

https://plugins.jetbrains.com/plugin/9212-flutter/versions

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
 - Import `flutter-icons-*.zip` into: https://www.fluttericon.com/
 - Add SVG from above
 - Export





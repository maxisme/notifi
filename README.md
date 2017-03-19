<p align="center"><img height="150px" src="https://github.com/maxisme/notifi/blob/master/bell.png"></p>

# [Notifi](https://notifi.it/)

## Usage
- Install the Notifi [Mac client application](https://notifi.it/download)
- Create a HTTP request using your chosen method, with the following params:
  - `credentials` (your credentials given to you by the client-side app) - **Required**
  - `title` (notification title) - **Required**
  - `message` (notification body) - _Optional_
  - `image` (image to send with the notification) - _Optional_
  - `link` (url to send with the notification) - _Optional_
- Requests are sent to `https://notifi.it/api`

## HTTP Request Examples

#### Curl
```
curl -d "credentials=<credentials>" \
-d "title=New download" \
-d "message=Lorem Ipsum" \
-d "link=https://google.com" \
-d "image=https://imgur.com/someimage.png" \
https://notifi.it/api
```

#### Python
```python
import requests

data = {
  'credentials': '<credentials>',
  'title': 'New download',
  'message': 'Lorem Ipsum',
  'link': 'https://google.com',
  'img': 'https://imgur.com/someimage.png'
}

r = requests.post(('https://notifi.it/api', data=data))
```

#### PHP
```
curl_setopt_array(
  $chpush = curl_init(),
  array(
    CURLOPT_URL => "https://notifi.it/api",
    CURLOPT_POSTFIELDS => array(
      "credentials" => '<credentials>',
      "title" => 'New download',
      "message" => 'Lorem Ipsum',
      "link" => 'https://google.com',
      "img" => 'https://imgur.com/someimage.png',
    )
  )
);
curl_exec($chpush);
curl_close($chpush);
```

## Screen Shots
#### Menu
<img width='300' src="https://github.com/maxisme/notifi/raw/master/Screen%20Shots/Menubar.png">

#### Window
<img width='300' src="https://github.com/maxisme/notifi/raw/master/Screen%20Shots/Window.png">

#### Notification
<img width='300' src="https://github.com/maxisme/notifi/raw/master/Screen%20Shots/Notification.png">

#### Right Click
<img width='300' src="https://github.com/maxisme/notifi/raw/master/Screen%20Shots/RightClick.png">

#### Read message
<img width='300' src="https://github.com/maxisme/notifi/raw/master/Screen%20Shots/Read.png">

____

## TODO

- [x] More efficient way to sort notification views in window.
- [ ] When clicking on notification popup does not always open notifi Mac app.
- [x] Links not clickable
- [x] Fix icon to show error even when has notifications.
- [ ] For some reason after deleting notifications in the window if you follow the mouse around you can see the cursor for text and links and also if you right click it throws an error because of it thinking there is an object there. I believe this may have something todo with wantsLayer
- [x] time not updating automatically.
- [ ] fix horizontal scrolling in window

- [ ] Getting weird `Uncommitted CATransaction` errors.

____

## Setup - Ubuntu 14.04

```
apt-get install nginx
```

```
sudo apt-get install python-software-properties software-properties-common
sudo LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
sudo apt-get update
sudo apt-get install php7.1 php7.1-fpm php7.1-mysql
```

```
apt-get install mysql-server
```

```
apt-get install build-essential libtool autoconf uuid-dev pkg-config git libsodium-dev
```

```
wget https://archive.org/download/zeromq_4.1.4/zeromq-4.1.4.tar.gz # Latest tarball on 07/08/2016
tar -xvzf zeromq-4.1.4.tar.gz
cd zeromq-4.1.4
./configure
make
sudo make install
sudo ldconfig
```

```
git clone git://github.com/mkoppanen/php-zmq.git
cd php-zmq
phpize && ./configure
make
sudo make install
```

Then add the line `extension=zmq.so` to your php `.ini`

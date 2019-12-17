<p align="center"><img height="150px" src="https://github.com/maxisme/notifi/raw/master/notifi/images/bell.png"></p>

# [notifi.it](https://notifi.it/)

## [Mac App](https://github.com/maxisme/notifi) | [Website](https://github.com/maxisme/notifi.it) | [Backend](https://github.com/maxisme/notifi-backend)

## Usage
- First download [notifi](https://notifi.it/download)
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
  'image': 'https://imgur.com/someimage.png'
}

requests.post(('https://notifi.it/api', data=data))
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
      "image" => 'https://imgur.com/someimage.png',
    )
  )
);
curl_exec($chpush);
curl_close($chpush);
```


[notifi-backend](https://github.com/maxisme/notifi-backend)

## TODO

- [x] More efficient way to sort notification views in window.
- [x] When clicking on notification popup does not always open notifi Mac app.
- [x] Links not clickable
- [x] Fix icon to show error even when has notifications.
- [x] For some reason after deleting notifications in the window if you follow the mouse around you can see the cursor for text and links and also if you right click it throws an error because of it thinking there is an object there. I believe this may have something todo with wantsLayer
- [x] time not updating automatically.
- [x] fix horizontal scrolling in window
- [x] Getting weird `Uncommitted CATransaction` errors.
- [ ] Fix bug where date text appears at top of notification.

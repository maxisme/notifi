<p align="center"><img height="150px" src="https://github.com/maxisme/notifi/blob/master/bell.png"></p>
# [Notifi](https://notifi.it/)

## Usage
- Install the Notifi [OSX client application](https://notifi.it/download)
- Create a HTTP request using your chosen method, with the following params:
  - `credentials` (your credentials given to you by the client-side app)
  - `title` (notification title) - **Required**
  - `message` (notification body) - _Optional_
  - `image` (image to send with the notification) - _Optional_
  - `link` (url to send with the notification) - _Optional_
- Requests are sent to `https://notifi.it/api`

## HTTP Request Examples

### Curl
```
curl -d "credentials=<credentials>" \
-d "title=New download" \
-d "message=Lorem Ipsum" \
-d "link=https://google.com" \
-d "image=https://imgur.com/someimage.png" \
https://notifi.it/api
```

### Python
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

### PHP
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

### Screen Shots
#### Menu
<img width='100' src="https://github.com/maxisme/notifi/raw/master/Screen%20Shots/Menubar.png">
#### Window
<img width='100' src="https://github.com/maxisme/notifi/raw/master/Screen%20Shots/Window.png">
#### Notification
<img width='100' src="https://github.com/maxisme/notifi/raw/master/Screen%20Shots/Notification.png">
#### Right Click
<img width='100' src="https://github.com/maxisme/notifi/raw/master/Screen%20Shots/RightClick.png">
#### Read message
<img width='100' src="https://github.com/maxisme/notifi/raw/master/Screen%20Shots/Read.png">
____

#### TODO

- [x] More efficient way to sort notification views in window.
- [ ] When clicking on notification popup does not always open notifi OSX app.
- [x] Links not clickable
- [x] Fix icon to show error even when has notifications.
- [ ] For some reason after deleting notifications in the window if you follow the mouse arround you can see the cursor for text and links and also if you right click it throws an error because of it thinking there is an object there. I believe this may have something todo with wantsLayer
- [ ] time not updating automatically.
- [ ] fix horizontal scrolling in window

<p align="center"><img height="150px" src="https://github.com/maxisme/notifi/blob/master/bell.png"></p>
# [Notifi](https://notifi.it/)

## Usage
1. Install the Notifi [OSX client application](https://notifi.it/download)
2. Create an HTTP request using your chosen method, with the following params:
- `credentials` (your credentials given to you by the client-side app)
- `title` (notification title) - **Required**
- `message` (notification body) - _Optional_
- `image` (image to send with the notification) - _Optional_
- `link` (url to send with the notification) - _Optional_
3. Requests are sent to `https://notifi.it/api`

## CURL Examples

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

#### TODO

- [ ] When clicking on notification popup does not always open notifi OSX app

-

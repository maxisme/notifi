<img height="150px" src="https://github.com/maxisme/notifi/blob/master/bell.png">
# Notifi
### A PHP-based push notification API

## Usage
1. Install the [OSX client application](https://noti.ga/download)
2. Create an HTTP request using your chosen method, with the following params:
- `credentials` (your credentials given to you by the client-side app)
- `title` (notification title) - **Required**
- `message` (notification body) - _Optional_
- `image` (image to send with the notification) - _Optional_
- `link` (url to send with the notification) - _Optional_
3. Requests are sent to `https://noti.ga/api`

### CURL Example
```
curl -d "credentials=<credentials>" \
-d "title=New download" \
-d "message=Lorem Ipsum" \
-d "link=https://google.com" \
-d "image=https://imgur.com/someimage.png" \
https://noti.ga/api
```

### Python requests example
```python
import requests

data = {
  'credentials': <credentials>,
  'title': 'New download',
  'message': 'Lorem Ipsum',
  'link': 'https://google.com',
  'img': 'https://imgur.com/someimage.png'
}

r = requests.post(('https://noti.ga/api', data=data))
```

-

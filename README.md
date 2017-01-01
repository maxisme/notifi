# Notify
### A PHP-based push notification API

## Usage
1. Install the OSX client application and generate a new credential code
2. Create an HTTP request using your chosen method, with the following params:
- `credentials` (your credentials generated by the client-side app)
- `title` (notification title)
- `message` (notification body)
- `imageURL` (image to send with the notification)
- `url` (url to send with the notification)
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



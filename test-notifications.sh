#!/bin/bash
CREDENTIALS=$1
# no expand message
# Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur egestas ac velit suscipit efficitur. Nam laoreet ornare velit ut v Lorem ipsum dolor sit amet, consectetur fffff
# add another 'f' to cause expand
LOREM="Lorem%20ipsum%20dolor%20sit%20amet,%20consectetur%20adipiscing%20elit.%20Curabitur%20egestas%20ac%20velit%20suscipit%20efficitur.%20Nam%20laoreet%20ornare%20velit%20ut%20vulputate.%20Aliquam%20quam%20erat,%20volutpat%20ac%20metus%20id,%20hendrerit%20consectetur%20nislLorem%20ipsum%20dolor%20sit%20amet,%20consectetur%20adipiscing%20elit.%20Curabitur%20egestas%20ac%20velit%20suscipit%20efficitur.%20Nam%20laoreet%20ornare%20velit%20ut%20vulputate.%20Aliquam%20quam%20erat,%20volutpat%20ac%20metus%20id,%20hendrerit%20consectetur%20nisl"
#LOREM="Lorem%20ipsum%20dolor%20sit%20amet,%20consectetur%20adipiscing%20elit.%20Curabitur%20egestas%20ac%20velit"

#curl "https:/dev.notifi.it/api?credentials=${CREDENTIALS}&title=${LOREM}&message=${LOREM}"
curl -i "https:/dev.notifi.it/api?credentials=${CREDENTIALS}&title=$(date +%s)&message=${LOREM}"
#curl "https:/dev.notifi.it/api?credentials=${CREDENTIALS}&title=hey&message=${LOREM}"
#curl "https:/dev.notifi.it/api?credentials=${CREDENTIALS}&title=hey&message=hey"
#curl "https:/dev.notifi.it/api?credentials=${CREDENTIALS}&title=1"
curl "https:/dev.notifi.it/api?credentials=${CREDENTIALS}&title=${LOREM}&image=https://notifi.it/images/logo.png"
curl "https:/dev.notifi.it/api?credentials=${CREDENTIALS}&title=hi&message=hi&image=https://notifi.it/images/logo.png"
curl "https:/dev.notifi.it/api?credentials=${CREDENTIALS}&title=${LOREM}&message=${LOREM}&image=https://notifi.it/images/logo.png"
curl "https:/dev.notifi.it/api?credentials=${CREDENTIALS}&title=hi&image=https://notifi.it/images/logo.png"
curl "https:/dev.notifi.it/api?credentials=${CREDENTIALS}&title=hey&link=https://google.com"
curl "https:/dev.notifi.it/api?credentials=${CREDENTIALS}&title=${LOREM}&link=https://google.com"
curl "https:/dev.notifi.it/api?credentials=${CREDENTIALS}&title=hi&message=hi&image=https://notifi.it/images/logo.png"
curl "https:/dev.notifi.it/api?credentials=${CREDENTIALS}&title=hi&image=https://notifi.it/images/logo.png"
curl "https:/dev.notifi.it/api?credentials=${CREDENTIALS}&title=${LOREM}&message=${LOREM}&image=https://notifi.it/images/logo.png"
curl "https:/dev.notifi.it/api?credentials=${CREDENTIALS}&title=${LOREM}&image=https://notifi.it/images/logo.png"
curl "https:/dev.notifi.it/api?credentials=${CREDENTIALS}&title=${LOREM}&message=hi&image=https://notifi.it/images/logo.png&link=https://google.com"
curl "https:/dev.notifi.it/api?credentials=${CREDENTIALS}&title=${LOREM}&message=${LOREM}&link=https://google.com"
curl "https:/dev.notifi.it/api?credentials=${CREDENTIALS}&title=${LOREM}&message=${LOREM}&link=https://google.com"

#for i in {1..3}
#do
#    curl "https:/dev.notifi.it/api?credentials=${CREDENTIALS}&title=$i%20${LOREM}&message=$i%20${LOREM}&link=https://google.com"
#done

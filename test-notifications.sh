#!/bin/bash
CREDENTIALS=aUT0oUNyURqGOkvAjEuT8fSzE

LOREM="Lorem%20ipsum%20dolor%20sit%20amet,%20consectetur%20adipiscing%20elit.%20Curabitur%20egestas%20ac%20velit%20suscipit%20efficitur.%20Nam%20laoreet%20ornare%20velit%20ut%20vulputate.%20Aliquam%20quam%20erat,%20volutpat%20ac%20metus%20id,%20hendrerit%20consectetur%20nisl.%20Integer%20egestas%20est%20et%20ex%20tempus,%20nec%20fringilla%20elit%20gravida.%20Cras%20tincidunt,%20lacus%20id%20finibus%20viverra,%20risus%20metus%20imperdiet%20lacus,%20sed%20maximus%20mauris%20velit%20sed%20nunc.%20Nunc%20gravida%20turpis%20vitae%20tortor%20fringilla%20tristique%20eu%20sit%20amet%20augue.%20Phasellus%20pulvinar%20ultrices%20pulvinar.%20Proin%20molestie%20eros%20ac%20est%20tincidunt,%20et%20sagittis%20velit%20blandit.%20Lorem%20ipsum%20dolor%20sit%20amet,%20consectetur%20adipiscing%20elit.%20Vivamus%20vulputate%20lorem%20eros,%20eget%20elementum%20orci%20porta%20viverra.%20Nunc%20tempus%20mollis%20neque%20et%20efficitur.%20Integer%20metus%20neque,%20aliquet%20nec%20sollicitudin%20vitae,%20elementum%20in%20urna.%20Duis%20ac%20condimentum%20est,%20a%20suscipit%20diam.%20Curabitur%20rhoncus%20augue%20at%20elit%20molestie%20ultricies.%20Curabitur%20ut%20mauris%20enim.%20Aliquam%20erat%20volutpat."


#curl "http://127.0.0.1:8080/api?credentials=${CREDENTIALS}&title=${LOREM}&message=${LOREM}"
#curl "http://127.0.0.1:8080/api?credentials=${CREDENTIALS}&title=${LOREM}"
#curl "http://127.0.0.1:8080/api?credentials=${CREDENTIALS}&title=hey&message=${LOREM}"
#curl "http://127.0.0.1:8080/api?credentials=${CREDENTIALS}&title=hey&message=hey"
#curl "http://127.0.0.1:8080/api?credentials=${CREDENTIALS}&title=1"
#curl "http://127.0.0.1:8080/api?credentials=${CREDENTIALS}&title=${LOREM}&image=https://notifi.it/images/logo.png"
#curl "http://127.0.0.1:8080/api?credentials=${CREDENTIALS}&title=hi&message=hi&image=https://notifi.it/images/logo.png"
#curl "http://127.0.0.1:8080/api?credentials=${CREDENTIALS}&title=${LOREM}&message=${LOREM}&image=https://notifi.it/images/logo.png"
#curl "http://127.0.0.1:8080/api?credentials=${CREDENTIALS}&title=hi&image=https://notifi.it/images/logo.png"
curl "http://127.0.0.1:8080/api?credentials=${CREDENTIALS}&title=hey&link=https://google.com"
#curl "http://127.0.0.1:8080/api?credentials=${CREDENTIALS}&title=${LOREM}&link=https://google.com"
#curl "http://127.0.0.1:8080/api?credentials=${CREDENTIALS}&title=hi&message=hi&image=https://notifi.it/images/logo.png"
#curl "http://127.0.0.1:8080/api?credentials=${CREDENTIALS}&title=hi&image=https://notifi.it/images/logo.png"
#curl "http://127.0.0.1:8080/api?credentials=${CREDENTIALS}&title=${LOREM}&message=${LOREM}&image=https://notifi.it/images/logo.png"
#curl "http://127.0.0.1:8080/api?credentials=${CREDENTIALS}&title=${LOREM}&image=https://notifi.it/images/logo.png"
#curl "http://127.0.0.1:8080/api?credentials=${CREDENTIALS}&title=${LOREM}&message=hi&image=https://notifi.it/images/logo.png&link=https://google.com"
#curl "http://127.0.0.1:8080/api?credentials=${CREDENTIALS}&title=${LOREM}&message=${LOREM}&link=https://google.com"

for i in {1..1000}
do
    curl "http://127.0.0.1:8080/api?credentials=${CREDENTIALS}&title=${LOREM}&message=$i%20${LOREM}&link=https://google.com"
done

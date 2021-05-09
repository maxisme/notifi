#!/bin/bash
CREDENTIALS=$1
URL=https://dev.notifi.it/api
# no expand message
# Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur egestas ac velit suscipit efficitur. Nam laoreet ornare velit ut v Lorem ipsum dolor sit amet, consectetur fffff
# add another 'f' to cause expand
LOREM="Lorem%20ipsum%20dolor%20sit%20amet,%20consectetur%20adipiscing%20elit.%20Curabitur%20egestas%20ac%20velit%20suscipit%20efficitur.%20Nam%20laoreet%20ornare%20velit%20ut%20vulputate.%20Aliquam%20quam%20erat,%20volutpat%20ac%20metus%20id,%20hendrerit%20consectetur%20nislLorem%20ipsum%20dolor%20sit%20amet,%20consectetur%20adipiscing%20elit.%20Curabitur%20egestas%20ac%20velit%20suscipit%20efficitur.%20Nam%20laoreet%20ornare%20velit%20ut%20vulputate.%20Aliquam%20quam%20erat,%20volutpat%20ac%20metus%20id,%20hendrerit%20consectetur%20nisl"
#LOREM="Lorem%20ipsum%20dolor%20sit%20amet,%20consectetur%20adipiscing%20elit.%20Curabitur%20egestas%20ac%20velit"

#curl -i "$URL?credentials=${CREDENTIALS}&title=$(date +%s)&message=${LOREM}"
#curl -i "http://127.0.0.1:9081/api?credentials=${CREDENTIALS}&title=$(date +%s)&message=${LOREM}"
#curl "$URL?credentials=${CREDENTIALS}&title=hey&message=${LOREM}"
#curl "$URL?credentials=${CREDENTIALS}&title=hey&message=hey"
#curl "$URL?credentials=${CREDENTIALS}&title=1"
curl "$URL?credentials=${CREDENTIALS}&title=Hacker%20News:%20Machine%20Learning%20101%20slidedeck:%202%20years%20of%20headbanging,%20so%20you%20don't%20have%20to%20&link=https://news.ycombinator.com/"s
curl "$URL?credentials=${CREDENTIALS}&title=BTC%20@%20£50,000"
sleep 0.1
curl "$URL?credentials=${CREDENTIALS}&title=Server%20Login&message=IP:%2035.177.218.15%20(London)"
curl "$URL?credentials=${CREDENTIALS}&title=RTX%20back%20in%20stock&message=£719.99&link=https://www.currys.co.uk/"
curl "$URL?credentials=${CREDENTIALS}&title=Daily%20Image%20Inspiration&message=Abandoned%20car%20park&image=https://i.imgur.com/n0GhyPT.png"
#curl "$URL?credentials=${CREDENTIALS}&title=Finished%20notifi%20CI&message=Took%205%20minutes%20and%2032%20seconds&link=https://github.com/maxisme/notifi/actions"
sleep 0.1
curl "$URL?credentials=${CREDENTIALS}&title=${LOREM}&message=${LOREM}"
curl "$URL?credentials=${CREDENTIALS}&title=Sensor%20Alert!%20&message=Activity%20By%20The%20Front%20🚪"
#curl "$URL?credentials=${CREDENTIALS}&title=Hacker%20News:%20The%20Unix%20Magic%20poster&message=I%20understand%20the%20classic%20UNIX%20Magic%20poster%20by%20Gary%20Overacre%20was%20distributed%20at%20past%20USENIX%20conferences,%20and%20I’ve%20known%20of%20it%20for%20years%20but%20now%20in%20confinement,%20I’ve%20decided%20I%20want%20one%20to%20hang%20in%20my%20office.&link=https://news.ycombinator.com/"
curl "$URL?credentials=${CREDENTIALS}&title=Backup%20Finished&message=Took%20512%20seconds"

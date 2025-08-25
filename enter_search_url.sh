echo "enter your search URL:"
read url

node source4.js $url | sed '/^sh sc1v1.sh /!{s/^/sh sc1v1_bulk.sh /;a\
node source4.js $url | sed '/^sh sc1v1.sh /!{s/^/sh sc1v1.sh /;a\
sleep 10
}'

echo "enter your search URL:"
read url

node source4.js $url | sed '/^sh sc1v1_bulk_bulk.sh /!{s/^/sh sc1v1_bulk_bulk.sh /;a\
sleep 5
}'

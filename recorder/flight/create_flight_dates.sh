main=/home/manish/puppeteer-scraper/flipkart_urls/recorder/flight/main
echo "enter your url"
read url
date_from=$(echo "$url" | grep -o '[0-9]\{8\}')
mkdir /home/manish/puppeteer-scraper/flipkart_urls/recorder/flight/$date_from
path=/home/manish/puppeteer-scraper/flipkart_urls/recorder/flight/$date_from
cp $main/scrolllink.js $main/price10.py $main/parse_flights_v2.sh $main/command $path/

touch $path/runme.sh
#echo "date" >>$path/runme.sh

echo "">$path/old_price.txt
echo "cd $path" >>$path/runme.sh
echo "/usr/bin/node $path/scrolllink.js '$url' | grep -oP '₹[0-9,]+|[0-9]{2}:[0-9]{2}|[A-Z0-9]{2}-\d{3,4}|(?:Air India|Akasa Air|IndiGo)|\d+h \d+m'  >$path/dump2 && /usr/bin/bash $path/parse_flights_v2.sh  >$path/latest_price.txt" >>$path/runme.sh
echo "/usr/bin/python3 $path/price10.py" >>$path/runme.sh

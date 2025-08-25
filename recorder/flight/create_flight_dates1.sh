#!/bin/bash

main=/home/manish/puppeteer-scraper/flipkart_urls/recorder/flight/main

echo "enter your url"
read url
date_from=$(echo "$url" | grep -oP '(?<=trips=).*?(?=&travellers)')
mkdir /home/manish/puppeteer-scraper/flipkart_urls/recorder/flight/$date_from
path=/home/manish/puppeteer-scraper/flipkart_urls/recorder/flight/$date_from
cp $main/scrolllink.js $main/price10.py $main/parse_flights_v2.sh $main/command $path/

touch $path/runme.sh
#echo "date" >>$path/runme.sh

echo "">$path/old_price.txt
echo "cd $path" >>$path/runme.sh
echo "/usr/bin/node $path/scrolllink.js '$url' | grep -oP '₹[0-9,]+|[0-9]{2}:[0-9]{2}|[A-Z0-9]{2}-\d{3,4}|(?:Air India|Akasa Air|IndiGo)|\d+h \d+m'  >$path/dump2 && /usr/bin/bash $path/parse_flights_v2.sh  >$path/latest_price.txt" >>$path/runme.sh
echo "/usr/bin/python3 $path/price10.py" >>$path/runme.sh
sh $path/runme.sh
cp $path/latest_price.txt $path/initial_price_$date_from
echo "add in crontab"
echo ""
echo "7 * * * * sh  /home/manish/puppeteer-scraper/flipkart_urls/recorder/flight/$date_from/runme.sh >>/tmp/flight_$date_from.txt 2>&1"


prefix=${date_from:0:8}                  # "BHJ-BOM-"
datepart=${date_from:8:8}                # "06052025"
formatted_date="${datepart:0:2}-${datepart:2:2}-${datepart:4:4}"
result="${prefix}${formatted_date}"

echo "$result"   # Outputs: BHJ-BOM-06-05-2025



sed -i "s/needdate/$result/g" $path/price10.py

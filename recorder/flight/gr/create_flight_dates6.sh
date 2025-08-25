#!/bin/bash

main=/home/manish/puppeteer-scraper/flipkart_urls/recorder/flight/gr/main
base=/home/manish/puppeteer-scraper/flipkart_urls/recorder/flight/gr

echo "Enter the Flipkart flight search URL:"
read url

date_from=$(echo "$url" | grep -oP '(?<=trips=).*?(?=&travellers)')
prefix=${date_from:0:8}
datepart=${date_from:8:8}
formatted_date="${datepart:0:2}-${datepart:2:2}-${datepart:4:4}"
result="${prefix}${formatted_date}"

echo "🛫 Creating project for: $result"

mkdir -p $base/$result
path=$base/$result

cp $main/scrolllink.js $main/parse_flights_v2.sh $main/price10.py $main/command $path/

# Create runme.sh
touch $path/runme.sh
echo "cd $path" > $path/runme.sh
echo "/usr/bin/node $path/scrolllink.js '$url' | grep -oP '₹[0-9,]+|[0-9]{2}:[0-9]{2}|[A-Z0-9]{2}-\\d{3,4}|(?:Air India|Akasa Air|IndiGo)|\\d+h \\d+m' > $path/dump2 && /usr/bin/bash $path/parse_flights_v2.sh > $path/latest_price.txt" >> $path/runme.sh
echo "/usr/bin/python3 $path/price10.py" >> $path/runme.sh

# Initial run
sh $path/runme.sh

# Cron job suggestion
echo ""
echo "🕓 Add this to crontab:"
echo "7 * * * * bash $path/runme.sh >> /tmp/flight_$result.txt 2>&1"

# shflight helper
echo "cd $path" >> $base/shflight.sh
echo "sh $path/runme.sh" >> $base/shflight.sh

# Replace 'needdate' in price10.py with result
sed -i "s/needdate/$result/g" $path/price10.py

cd $path

echo `date`
cd /home/manish/puppeteer-scraper/flipkart_urls/recorder/flight/29-04-2025
path=/home/manish/puppeteer-scraper/flipkart_urls/recorder/flight/29-04-2025
/usr/bin/node $path/scrolllink.js 'https://www.flipkart.com/travel/flights/search?trips=BLR-BOM-29042025&travellers=1-0-0&class=e&tripType=ONE_WAY&isIntl=false&source=Search+Modify+Form&filters.BLR-BOM.stops=0' | grep -oP '₹[0-9,]+|[0-9]{2}:[0-9]{2}|[A-Z0-9]{2}-\d{3,4}|(?:Air India|Akasa Air|IndiGo)|\d+h \d+m'  >$path/dump2 && /usr/bin/bash $path/parse_flights_v2.sh  >$path/latest_price.txt
/usr/bin/python3 $path/price10.py

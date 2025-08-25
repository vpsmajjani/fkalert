echo "enter your url"
read url
date_from=$(echo "$url" | grep -o '[0-9]\{8\}')
mkdir /home/manish/puppeteer-scraper/flipkart_urls/recorder/flight/$date_from

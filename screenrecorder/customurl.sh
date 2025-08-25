echo "enter name:"
read url
mkdir -p /home/manish/puppeteer-scraper/flipkart_urls/recorder/$url
cd /home/manish/puppeteer-scraper/flipkart_urls/recorder/$url
cp /home/manish/puppeteer-scraper/flipkart_urls/recorder/record5working.js /home/manish/puppeteer-scraper/flipkart_urls/recorder/$url/
node record5working.js https://superchatlive.com/$url
rm /home/manish/puppeteer-scraper/flipkart_urls/recorder/$url/frames/*

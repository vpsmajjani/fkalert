for i in $(cat collectedurlfor.txt); do
sh /home/manish/puppeteer-scraper/flipkart_urls/sc1v1_bulk.sh "$i"
done

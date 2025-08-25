#echo "enter your product name: "

#read product

mkdir /home/manish/puppeteer-scraper/flipkart_urls/$1\_fk

cp /home/manish/puppeteer-scraper/flipkart_urls/link.js /home/manish/puppeteer-scraper/flipkart_urls/$1\_fk/link.js

cp /home/manish/puppeteer-scraper/flipkart_urls/areal.sh /home/manish/puppeteer-scraper/flipkart_urls/$1\_fk/

mv /home/manish/puppeteer-scraper/flipkart_urls/$1\_fk/areal.sh /home/manish/puppeteer-scraper/flipkart_urls/$1\_fk/$1\_fk.sh

#echo "1" >> /home/manish/puppeteer-scraper/flipkart/$product\_fk/$product\_fk.txt

#enter link
#echo "Enter your link :"
#read product_url

sed -i "s|http|$2|g" /home/manish/puppeteer-scraper/flipkart_urls/$1\_fk/$1\_fk.sh
echo $2 >> /home/manish/puppeteer-scraper/flipkart_urls/$1\_fk/url
node link.js $2 | grep -oP '"price":\s*\K\d+' | head -n 1 >> /home/manish/puppeteer-scraper/flipkart_urls/$1\_fk/$1\_fk.txt

cd  /home/manish/puppeteer-scraper/flipkart_urls/$1\_fk
nohup sh $1\_fk.sh &

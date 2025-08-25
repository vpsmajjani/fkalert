echo "enter your product name: "

read product
#mkdir /home/manish/puppeteer-scraper/flipkart/$product\_fk

cp /home/manish/puppeteer-scraper/flipkart/link.js /home/manish/puppeteer-scraper/flipkart/$product\_fk/link.js

cp /home/manish/puppeteer-scraper/flipkart/areal.sh /home/manish/puppeteer-scraper/flipkart/$product\_fk/

mv /home/manish/puppeteer-scraper/flipkart/$product\_fk/areal.sh /home/manish/puppeteer-scraper/flipkart/$product\_fk/$product\_fk.sh

#echo "1" >> /home/manish/puppeteer-scraper/flipkart/$product\_fk/$product\_fk.txt

#enter link
#echo "Enter your link :"
product_url=`cat /home/manish/puppeteer-scraper/flipkart/$product\_fk/url`

sed -i "s|http|$product_url|g" /home/manish/puppeteer-scraper/flipkart/$product\_fk/$product\_fk.sh
#echo $product_url >> /home/manish/puppeteer-scraper/flipkart/$product\_fk/url
#node link.js $product_url | grep -oP '"price":\s*\K\d+' | head -n 1 >> /home/manish/puppeteer-scraper/flipkart/$product\_fk/$product\_fk.txt

cd  /home/manish/puppeteer-scraper/flipkart/$product\_fk
nohup sh $product\_fk.sh &

echo "enter your product name: "

read product
mkdir /home/manish/puppeteer-scraper/$product

cp /home/manish/puppeteer-scraper/foldertoother/link.js /home/manish/puppeteer-scraper/$product/link.js

cp /home/manish/puppeteer-scraper/foldertoother/amazon_areal.sh /home/manish/puppeteer-scraper/$product/

mv /home/manish/puppeteer-scraper/$product/amazon_areal.sh /home/manish/puppeteer-scraper/$product/$product.sh

#echo "1" >> /home/manish/puppeteer-scraper/$product/$product.txt

#enter link
echo "Enter your link :"
read product_url

sed -i "s|http|$product_url|g" /home/manish/puppeteer-scraper/$product/$product.sh
echo "1" >> /home/manish/puppeteer-scraper/$product/$product.txt

#echo "enter your product name: "

#read product
#proudct= $1 | grep -oP '(?<=\.com/)[^/]+'
#product=$(echo $1 | grep -oP '(?<=\.com/)[^/]+')

product=`echo "$1" | grep -oP '(?<=\.com/)[^/]+'`

#product=`echo "$1" | grep -oP '(?<=\.com/)[^/]+'`
second=`echo $(date +%s) | tail -c 4`

mkdir /home/manish/puppeteer-scraper/flipkart_urls/products/$product\_fk_$second

cp /home/manish/puppeteer-scraper/flipkart_urls/link.js /home/manish/puppeteer-scraper/flipkart_urls/products/$product\_fk_$second/link.js

cp /home/manish/puppeteer-scraper/flipkart_urls/imp/oldmain.sh /home/manish/puppeteer-scraper/flipkart_urls/products/$product\_fk_$second/

mv /home/manish/puppeteer-scraper/flipkart_urls/products/$product\_fk_$second/oldmain.sh /home/manish/puppeteer-scraper/flipkart_urls/products/$product\_fk_$second/$product\_fk_$second.sh

#echo "1" >> /home/manish/puppeteer-scraper/flipkart/$product\_fk/$product\_fk.txt

#enter link
#echo "Enter your link :"
#read product_url


full_url="$1"

# Use awk to cut the URL before "&lid"
cut_url=$(echo "$full_url" | awk -F "&lid" '{print $1}')

sed -i "s|http|$cut_url|g" /home/manish/puppeteer-scraper/flipkart_urls/products/$product\_fk_$second/$product\_fk_$second.sh




echo "\nThis is cropped URL"
echo "$cut_url \n"
echo "\nThis is folder"
echo $cut_url >> /home/manish/puppeteer-scraper/flipkart_urls/products/$product\_fk_$second/url
node link.js $cut_url | grep -oP '"price":\s*\K\d+' | head -n 1 >> /home/manish/puppeteer-scraper/flipkart_urls/products//$product\_fk_$second/price_$product\_fk_$second.txt
c_date=$(date "+%Y-%m-%d_%H:%M:%S")

price=`cat /home/manish/puppeteer-scraper/flipkart_urls/products/$product\_fk_$second/price_$product\_fk_$second.txt`
if [ -n "$price" ]; then
echo $product\_fk_$second, $c_date, $price >> /home/manish/puppeteer-scraper/flipkart_urls/allpricehistory.txt
echo $product\_fk_$second, $c_date, $price >> /home/manish/puppeteer-scraper/flipkart_urls/products/allpricehistory.txt
fi

cd  /home/manish/puppeteer-scraper/flipkart_urls/products/$product\_fk_$second
echo  /home/manish/puppeteer-scraper/flipkart_urls/products/$product\_fk_$second/
echo "\nPrice detected $price \n"
echo "\nenter in crontab"
echo "7 * * * * sh  /home/manish/puppeteer-scraper/flipkart_urls/products/$product\_fk_$second/$product\_fk_$second.sh >>/tmp/$product\_fk_$second.txt 2>&1"
echo "cd /home/manish/puppeteer-scraper/flipkart_urls/products/$product\_fk_$second/" >> /home/manish/puppeteer-scraper/flipkart_urls/bulkshscripts.sh
echo "sh /home/manish/puppeteer-scraper/flipkart_urls/products/$product\_fk_$second/$product\_fk_$second.sh" >> /home/manish/puppeteer-scraper/flipkart_urls/bulkshscripts.sh
echo "\n"
#nohup sh $product\_fk_$second.sh &
>/home/manish/puppeteer-scraper/flipkart_urls/products/$product\_fk_$second/price_$product\_fk_$second.txt



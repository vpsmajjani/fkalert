#echo "enter your product name: "

#read product
#proudct= $1 | grep -oP '(?<=\.com/)[^/]+'
#product=$(echo $1 | grep -oP '(?<=\.com/)[^/]+')

product=`echo "$1" | grep -oP '(?<=\.com/)[^/]+'`
full_url="$1"

# Use awk to cut the URL before "&lid"
cut_url=$(echo "$1" | awk -F "&lid" '{print $1}')
#product=`echo "$1" | grep -oP '(?<=\.com/)[^/]+'`
#second=`echo $(date +%s) | tail -c 4`
product=`echo "$cut_url" | sed -E 's:.*/([^/]+)/p/([^?]+)\?pid=([^&]+):\1_\3:'`





#exists=$(sqlite3 /home/manish/puppeteer-scraper/flipkart_urls/products/limited_product_prices.db "SELECT url FROM limited_product_price_history WHERE url='$cut_url';")
exists=$(ls -1 /home/manish/puppeteer-scraper/flipkart_urls/products/|grep "$product")
if [ -n "$exists" ]; then
    echo "URL already exists in the database. Skipping..."
#rm -rf /home/manish/puppeteer-scraper/flipkart_urls/products/$product\_fk_$second
   exit 
fi



mkdir /home/manish/puppeteer-scraper/flipkart_urls/products/$product

cp /home/manish/puppeteer-scraper/flipkart_urls/link.js /home/manish/puppeteer-scraper/flipkart_urls/products/$product/link.js

cp /home/manish/puppeteer-scraper/flipkart_urls/imp/oldmain.sh /home/manish/puppeteer-scraper/flipkart_urls/products/$product/

mv /home/manish/puppeteer-scraper/flipkart_urls/products/$product/oldmain.sh /home/manish/puppeteer-scraper/flipkart_urls/products/$product/$product.sh

#echo "1" >> /home/manish/puppeteer-scraper/flipkart/$product\_fk/$product\_fk.txt

#enter link
#echo "Enter your link :"
#read product_url


#full_url="$1"

# Use awk to cut the URL before "&lid"
#cut_url=$(echo "$full_url" | awk -F "&lid" '{print $1}')

#exists=$(sqlite3 /home/manish/puppeteer-scraper/flipkart_urls/products/limited_product_prices.db "SELECT url FROM limited_product_price_history WHERE url='$cut_url';")

#if [ -n "$exists" ]; then
#    echo "URL already exists in the database. Skipping..."
#rm -rf /home/manish/puppeteer-scraper/flipkart_urls/products/$product\_fk_$second
#   exit 0
#fi


sed -i "s|http|$cut_url|g" /home/manish/puppeteer-scraper/flipkart_urls/products/$product/$product.sh




echo "\nThis is cropped URL"
echo "$cut_url \n"
echo "\nThis is folder"
echo $cut_url > /home/manish/puppeteer-scraper/flipkart_urls/products/$product/url
node link.js $cut_url | grep -oP '"price":\s*\K\d+' | head -n 1 >> /home/manish/puppeteer-scraper/flipkart_urls/products/$product/price_$product.txt
> /home/manish/puppeteer-scraper/flipkart_urls/products/$product/price_$product.txt
c_date=$(date "+%Y-%m-%d_%H:%M:%S")

price=`cat /home/manish/puppeteer-scraper/flipkart_urls/products/$product/price_$product.txt`
if [ -n "$price" ]; then
echo $product, $c_date, $price >> /home/manish/puppeteer-scraper/flipkart_urls/allpricehistory.txt
echo $product, $c_date, $price >> /home/manish/puppeteer-scraper/flipkart_urls/products/allpricehistory.txt
fi

cd  /home/manish/puppeteer-scraper/flipkart_urls/products/$product
echo  /home/manish/puppeteer-scraper/flipkart_urls/products/$product/
echo "\nPrice detected $price \n"
echo "\nenter in crontab"
echo "7 * * * * sh  /home/manish/puppeteer-scraper/flipkart_urls/products/$product/$product.sh >>/tmp/$product.txt 2>&1"
echo "cd /home/manish/puppeteer-scraper/flipkart_urls/products/$product/" >> /home/manish/puppeteer-scraper/flipkart_urls/bulkshscripts.sh
echo "sh /home/manish/puppeteer-scraper/flipkart_urls/products/$product/$product.sh" >> /home/manish/puppeteer-scraper/flipkart_urls/bulkshscripts.sh
echo "\n"
#nohup sh $product\_fk_$second.sh &
cp /home/manish/puppeteer-scraper/flipkart_urls/products/maindatabase.sh  /home/manish/puppeteer-scraper/flipkart_urls/products/$product/$product.sh
sh /home/manish/puppeteer-scraper/flipkart_urls/products/$product/$product.sh
>>/home/manish/puppeteer-scraper/flipkart_urls/products/$product/price_$product.txt

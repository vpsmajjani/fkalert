#echo "enter your product name: "

#read product
#proudct= $1 | grep -oP '(?<=\.com/)[^/]+'
#product=$(echo $1 | grep -oP '(?<=\.com/)[^/]+')

product=`echo "$1" | grep -oP '(?<=\.com/)[^/]+'`


second=`echo $(date +%s) | tail -c 4`

mkdir /home/manish/puppeteer-scraper/flipkart_urls/products/$product\_fk_$second

cp /home/manish/puppeteer-scraper/flipkart_urls/link.js /home/manish/puppeteer-scraper/flipkart_urls/products/$product\_fk_$second/link.js

cp /home/manish/puppeteer-scraper/flipkart_urls/areal.sh /home/manish/puppeteer-scraper/flipkart_urls/products/$product\_fk_$second/

mv /home/manish/puppeteer-scraper/flipkart_urls/products/$product\_fk_$second/areal.sh /home/manish/puppeteer-scraper/flipkart_urls/products/$product\_fk_$second/$product\_fk_$second.sh

#echo "1" >> /home/manish/puppeteer-scraper/flipkart/$product\_fk/$product\_fk.txt

#enter link
#echo "Enter your link :"
#read product_url

sed -i "s|http|$1|g" /home/manish/puppeteer-scraper/flipkart_urls/products/$product\_fk_$second/$product\_fk_$second.sh
echo $1 >> /home/manish/puppeteer-scraper/flipkart_urls/products/$product\_fk_$second/url
node link.js $1 | grep -oP '"price":\s*\K\d+' | head -n 1 >> /home/manish/puppeteer-scraper/flipkart_urls/products//$product\_fk_$second/price_$product\_fk_$second.txt
c_date=$(date "+%Y-%m-%d_%H:%M:%S")

price=`cat /home/manish/puppeteer-scraper/flipkart_urls/products/$product\_fk_$second/price_$product\_fk_$second.txt`
<<<<<<< HEAD


if [ -n "$price" ]; then
echo $product\_fk_$second, $c_date, $price >> /home/manish/puppeteer-scraper/flipkart_urls/allpricehistory.txt
fi

=======
echo $product\_fk_$second, $c_date, $price >> /home/manish/puppeteer-scraper/flipkart_urls/allpricehistory.txt
>>>>>>> 32954ce (Initial backup files upload)

cd  /home/manish/puppeteer-scraper/flipkart_urls/products/$product\_fk_$second
echo  /home/manish/puppeteer-scraper/flipkart_urls/products/$product\_fk_$second/

echo "7 * * * * sh  /home/manish/puppeteer-scraper/flipkart_urls/products/$product\_fk_$second/$product\_fk_$second.sh >>/tmp/$product\_fk_$second.txt 2>&1"
<<<<<<< HEAD
echo "cd /home/manish/puppeteer-scraper/flipkart_urls/products/$product\_fk_$second/" >> /home/manish/puppeteer-scraper/flipkart_urls/shscripts.sh
echo "sh /home/manish/puppeteer-scraper/flipkart_urls/products/$product\_fk_$second/$product\_fk_$second.sh" >> /home/manish/puppeteer-scraper/flipkart_urls/shscripts.sh
=======

>>>>>>> 32954ce (Initial backup files upload)
nohup sh $product\_fk_$second.sh &



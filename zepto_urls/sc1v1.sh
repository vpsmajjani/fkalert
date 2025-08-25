#echo "enter your product name: "

#read product
#proudct= $1 | grep -oP '(?<=\.com/)[^/]+'
#product=$(echo $1 | grep -oP '(?<=\.com/)[^/]+')

#product=`echo "$1" | grep -oP '(?<=/pn/)[^/]+'
product=$(echo "$1" | grep -oP '(?<=/pn/)[^/]+')


second=`echo $(date +%s) | tail -c 4`

mkdir /home/manish/puppeteer-scraper/zepto_urls/product/$product\_zepto_$second

cp /home/manish/puppeteer-scraper/zepto_urls/link.js /home/manish/puppeteer-scraper/zepto_urls/product/$product\_zepto_$second/link.js

cp /home/manish/puppeteer-scraper/zepto_urls/areal.sh /home/manish/puppeteer-scraper/zepto_urls/product/$product\_zepto_$second/

mv /home/manish/puppeteer-scraper/zepto_urls/product/$product\_zepto_$second/areal.sh /home/manish/puppeteer-scraper/zepto_urls/product/$product\_zepto_$second/$product\_zepto_$second.sh

#echo "1" >> /home/manish/puppeteer-scraper/zepto/$product\_zepto/$product\_zepto.txt

#enter link
#echo "Enter your link :"
#read product_url

sed -i "s|http|$1|g" /home/manish/puppeteer-scraper/zepto_urls/product/$product\_zepto_$second/$product\_zepto_$second.sh
echo $1 >> /home/manish/puppeteer-scraper/zepto_urls/product/$product\_zepto_$second/url
node link.js $1 | grep -oP '₹\d+' | head -n 1 >> /home/manish/puppeteer-scraper/zepto_urls/product/$product\_zepto_$second/price_$product\_zepto_$second.txt
c_date=$(date "+%Y-%m-%d_%H:%M:%S")

price=`cat /home/manish/puppeteer-scraper/zepto_urls/product/$product\_zepto_$second/price_$product\_zepto_$second.txt`
echo $product\_zepto_$second, $c_date, $price >> /home/manish/puppeteer-scraper/zepto_urls/allpricehistory.txt

cd  /home/manish/puppeteer-scraper/zepto_urls/product/$product\_zepto_$second
nohup sh $product\_zepto_$second.sh &

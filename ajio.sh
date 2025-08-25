#echo "enter your product name: "

#read product
#proudct= $1 | grep -oP '(?<=\.com/)[^/]+'
#product=$(echo $1 | grep -oP '(?<=\.com/)[^/]+')

product=`echo "$1" | grep -oP '(?<=\.com/)[^/]+'`


second=`echo $(date +%s) | tail -c 4`

mkdir /home/manish/puppeteer-scraper/ajio_urls/$product\_ajio_$second

cp /home/manish/puppeteer-scraper/ajio_urls/link.js /home/manish/puppeteer-scraper/ajio_urls/$product\_ajio_$second/link.js

cp /home/manish/puppeteer-scraper/ajio_urls/ajio_areal.sh /home/manish/puppeteer-scraper/ajio_urls/$product\_ajio_$second/

mv /home/manish/puppeteer-scraper/ajio_urls/$product\_ajio_$second/ajio_areal.sh /home/manish/puppeteer-scraper/ajio_urls/$product\_ajio_$second/$product\_ajio_$second.sh

#echo "1" >> /home/manish/puppeteer-scraper/flipkart/$product\_fk/$product\_fk.txt

#enter link
#echo "Enter your link :"
#read product_url

sed -i "s|http|$1|g" /home/manish/puppeteer-scraper/ajio_urls/$product\_ajio_$second/$product\_ajio_$second.sh
echo $1 >> /home/manish/puppeteer-scraper/ajio_urls/$product\_ajio_$second/url
node link.js $1 | grep -oP '"price":\s*\K\d+' | head -n 1 >> /home/manish/puppeteer-scraper/ajio_urls/$product\_ajio_$second/price_$product\_ajio_$second.txt
c_date=$(date "+%Y-%m-%d_%H:%M:%S")

price=`cat /home/manish/puppeteer-scraper/ajio_urls/$product\_ajio_$second/price_$product\_ajio_$second.txt`
echo $product\_fk_$second, $c_date, $price >> /home/manish/puppeteer-scraper/ajio_urls/allpricehistory.txt

cd  /home/manish/puppeteer-scraper/ajio_urls/$product\_ajio_$second
nohup sh $product\_ajio_$second.sh &

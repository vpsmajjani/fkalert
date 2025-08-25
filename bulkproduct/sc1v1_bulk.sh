#echo "enter your product name: "

#read product
#proudct= $1 | grep -oP '(?<=\.com/)[^/]+'
#product=$(echo $1 | grep -oP '(?<=\.com/)[^/]+')
paths="/home/manish/puppeteer-scraper/flipkart_urls/bulkproduct/products"
product=`echo "$1" | grep -oP '(?<=\.com/)[^/]+'`

#product=`echo "$1" | grep -oP '(?<=\.com/)[^/]+'`
second=`echo $(date +%s) | tail -c 4`

mkdir $paths/$product\_fk_$second

cp $paths/link.js $paths/$product\_fk_$second/link.js

cp $paths/maindatabase.sh $paths/$product\_fk_$second/

mv $paths/$product\_fk_$second/maindatabase.sh $paths/$product\_fk_$second/$product\_fk_$second.sh

#echo "1" >> /home/manish/puppeteer-scraper/flipkart/$product\_fk/$product\_fk.txt

#enter link
#echo "Enter your link :"
#read product_url


full_url="$1"

# Use awk to cut the URL before "&lid"
cut_url=$(echo "$full_url" | awk -F "&lid" '{print $1}')

sed -i "s|http|$cut_url|g" $paths/$product\_fk_$second/$product\_fk_$second.sh




echo "\nThis is cropped URL"
echo "$cut_url \n"
echo "\nThis is folder"
echo $cut_url >> $paths/$product\_fk_$second/url
node link.js $cut_url | grep -oP '"price":\s*\K\d+' | head -n 1 >> $paths//$product\_fk_$second/price_$product\_fk_$second.txt
c_date=$(date "+%Y-%m-%d_%H:%M:%S")

price=`cat $paths/$product\_fk_$second/price_$product\_fk_$second.txt`
if [ -n "$price" ]; then
echo $product\_fk_$second, $c_date, $price >> $paths/allpricehistory.txt
echo $product\_fk_$second, $c_date, $price >> $paths/allpricehistory.txt
fi

cd  $paths/$product\_fk_$second
echo  $paths/$product\_fk_$second/
echo "\nPrice detected $price \n"
echo "\nenter in crontab"
echo "7 * * * * sh  $paths/$product\_fk_$second/$product\_fk_$second.sh >>/tmp/$product\_fk_$second.txt 2>&1"
echo "cd $paths/$product\_fk_$second/" >> $paths/bulkshscripts.sh
echo "sh $paths/$product\_fk_$second/$product\_fk_$second.sh" >> $paths/bulkshscripts.sh
echo "\n"
#nohup sh $product\_fk_$second.sh &
>$paths/$product\_fk_$second/price_$product\_fk_$second.txt

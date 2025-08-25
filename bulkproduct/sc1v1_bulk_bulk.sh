#echo "enter your product name: "

#read product
#proudct= $1 | grep -oP '(?<=\.com/)[^/]+'
#product=$(echo $1 | grep -oP '(?<=\.com/)[^/]+')

product=`echo "$1" | grep -oP '(?<=\.com/)[^/]+'`
current_path=`pwd`
#/home/manish/puppeteer-scraper/flipkart_urls/bulkproduct
#product=`echo "$1" | grep -oP '(?<=\.com/)[^/]+'`
second=`echo $(date +%s) | tail -c 4`

mkdir $current_path/products/$product\_fk_$second

cp $current_path/link.js $current_path/products/$product\_fk_$second/link.js

cp $current_path/areal.sh $current_path/products/$product\_fk_$second/

mv $current_path/products/$product\_fk_$second/areal.sh $current_path/products/$product\_fk_$second/$product\_fk_$second.sh

#echo "1" >> /home/manish/puppeteer-scraper/flipkart/$product\_fk/$product\_fk.txt

#enter link
#echo "Enter your link :"
#read product_url


full_url="$1"

# Use awk to cut the URL before "&lid"
cut_url=$(echo "$full_url" | awk -F "&lid" '{print $1}')

sed -i "s|http|$cut_url|g" $current_path/products/$product\_fk_$second/$product\_fk_$second.sh




echo "\nThis is cropped URL"
echo "$cut_url \n"
echo "\nThis is folder"
echo $cut_url >> $current_path/products/$product\_fk_$second/url
node link.js $cut_url | grep -oP '"price":\s*\K\d+' | head -n 1 >> $current_path/products//$product\_fk_$second/price_$product\_fk_$second.txt
c_date=$(date "+%Y-%m-%d_%H:%M:%S")

price=`cat $current_path/products/$product\_fk_$second/price_$product\_fk_$second.txt`
if [ -n "$price" ]; then
echo $product\_fk_$second, $c_date, $price >> $current_path/allpricehistory.txt
fi

cd  $current_path/products/$product\_fk_$second
echo  $current_path/products/$product\_fk_$second/
echo "\nPrice detected $price \n"
echo "\nenter in crontab"
echo "7 * * * * sh  $current_path/products/$product\_fk_$second/$product\_fk_$second.sh >>/tmp/$product\_fk_$second.txt 2>&1"
echo "cd $current_path/products/$product\_fk_$second/" >> $current_path/bulkshscripts.sh
echo "sh $current_path/products/$product\_fk_$second/$product\_fk_$second.sh" >> $current_path/bulkshscripts.sh
echo "\n"
nohup sh $product\_fk_$second.sh &



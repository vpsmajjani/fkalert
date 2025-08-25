echo "enter model name:"
read folder
path=/home/manish/puppeteer-scraper/flipkart_urls/recorder
mkdir $path/$folder
cp $path/link.js $path/record5working.js $path/online_Amy---Samy.sh $path/lulu_moonmoon.sh $path/$folder/
mv $path/$folder/online_Amy---Samy.sh $path/$folder/online_$folder.sh
mv $path/$folder/lulu_moonmoon.sh $path/$folder/$folder.sh
sed -i "1s/^/url=$folder\n/" "$path/$folder/$folder.sh"

echo "*/5 * * * *  /home/manish/puppeteer-scraper/flipkart_urls/recorder/$folder/online_$folder.sh $folder >>/tmp/log_for_$folder.txt 2>&1"

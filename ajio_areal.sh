while true; do
file=`ls *.txt`
  # Get the last price from fan (excluding the last line using `head -n -1`)
  last_price=$(cat $file | tail -1)

  # Get the current price by running other.js and extracting the price using grep
  current_price=$(node link.js 'http' | | grep -o '"maxSavingPrice":[0-9]*' | cut -d':' -f2 | head -n 1)

  # Compare the last price from fan with the current price
  if [ "$last_price" -eq "$current_price" ]; then
    echo "Status is the same"
  else
current_date=$(date "+%Y-%m-%d %H:%M:%S")
c_date=$(date "+%Y-%m-%d_%H:%M:%S")
echo $file, $c_date, $current_price >> /home/manish/puppeteer-scraper/flipkart_urls/allpricehistory.txt

#echo $file,  $current_price >>  /home/manish/puppeteer-scraper/flipkart_urls/allpricehistory.txt
#echo "$file, $(c_date), $current_price" >> /home/manish/puppeteer-scraper/flipkart_urls/allpricehistory.txt
#echo $file $date $current_price >> /home/manish/puppeteer-scraper/flipkart_urls/allpricehistory.txt
        echo "price changed"
echo "$current_date">>$file
    # Append the new price to fan
    echo "$current_price" >> $file
url=`cat url`
lowest_price=`grep -E '^[0-9]+$' *.txt | sort -n | head -n 1`
list=`grep -E '^[0-9]+$' *.txt | sort -n`
name=`ls *.txt`
 echo "Price changed! $last_price to $current_price for $file $url and lowest was $lowest_price, here is list $list" | mutt -s "Price changed $last_price to $current_price for $file"  -e "set realname='$name'" mannabhanushali@gmail.com
  fi
#name date price
  # Sleep for a defined time (e.g., 1 minute) before running the loop again
  sleep 7200
done

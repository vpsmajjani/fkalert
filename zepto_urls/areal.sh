while true; do
  file=$(ls *.txt)

  # Get the last price from the file
  last_price=$(cat "$file" | tail -1)

  # Get the current price by running link.js and extracting the price using grep
  current_price=$(node link.js 'http' | grep -oP '₹\d+' | head -n 1)

  # Compare the last price with the current price (string comparison since ₹ is included)
  if [ "$last_price" = "$current_price" ]; then
    echo "Status is the same"
  else
    current_date=$(date "+%Y-%m-%d %H:%M:%S")
    c_date=$(date "+%Y-%m-%d_%H:%M:%S")
    
    echo "$file, $c_date, $current_price" >> /home/manish/puppeteer-scraper/zepto_urls/allpricehistory.txt

    echo "price changed"
    echo "$current_date" >> "$file"
    echo "$current_price" >> "$file"

    url=$(cat url)
    lowest_price=$(grep -oP '₹\d+' *.txt | sort -n | head -n 1)
    list=$(grep -oP '₹\d+' *.txt | sort -n)
    name=$(ls *.txt)

    echo "Price changed! $last_price to $current_price for $file $url and lowest was $lowest_price, here is list $list" | \
    mutt -s "Price changed $last_price to $current_price" merakod@gmail.com

echo "Price changed on $current_date ! $last_price to $current_price for $file $url and lowest was $lowest_price, here is list $list" >>/home/manish/puppeteer-scraper/zepto_urls/listofchangedprice.txt


  fi

#  sleep 7200
exit
done


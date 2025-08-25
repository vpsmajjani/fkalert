<<<<<<< HEAD
#!/bin/bash

# Get the TXT filename (assuming only one)
file=$(ls *.txt)

# Get the last price from the file (last line)
last_price=$(tail -1 "$file")
record_date=$(date "+%Y-%m-%d %H:%M:%S")
# Get the current price from link.js and extract using grep
current_price=$(node link.js 'http' | grep -oP '"price":\s*\K\d+' | head -n 1)

# Check if current_price is valid
if [ -z "$current_price" ]; then
    echo "Price not found for $file on $record_date" |tee -a /home/manish/puppeteer-scraper/flipkart_urls/infologs.txt
else
    # Compare with last recorded price
    if [ "$last_price" -eq "$current_price" ]; then
        echo "Status is the same for $file price @ $current_price $record_date" |tee -a /home/manish/puppeteer-scraper/flipkart_urls/infologs.txt
    else
        current_date=$(date "+%Y-%m-%d %H:%M:%S")
        c_date=$(date "+%Y-%m-%d_%H:%M:%S")

        # Log to main history file
        echo "$file, $c_date, $current_price" |tee -a /home/manish/puppeteer-scraper/flipkart_urls/allpricehistory.txt

        echo "Price changed"

        # Append date and price to product-specific file
        echo "$current_date" >> "$file"
        echo "$current_price" >> "$file"

        # Gather info for email/logging
        url=$(cat url)
        lowest_price=$(grep -E '^[0-9]+$' *.txt | sort -n | head -n 1)
        list=$(grep -E '^[0-9]+$' *.txt | sort -n)
        name=$(ls *.txt)

        # Send email notification
        echo "Price changed! $current_date  $last_price to $current_price for $file $url and lowest was $lowest_price, here is list $list" \
            | mutt -s "Price changed $last_price to $current_price for $file" \
            -e "set realname='$name'" merakod@gmail.com

        # Save to list of changed prices
        echo "Price changed! $current_date $last_price to $current_price for $file $url and lowest was $lowest_price, here is list $list" \
            |tee -a /home/manish/puppeteer-scraper/flipkart_urls/listofchangedprice.txt
    fi
fi
=======
file=`ls *.txt`
  # Get the last price from fan (excluding the last line using `head -n -1`)
  last_price=$(cat $file | tail -1)

  # Get the current price by running other.js and extracting the price using grep
  current_price=$(node link.js 'http' | grep -oP '"price":\s*\K\d+' | head -n 1)

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
 echo "Price changed! $current_date  $last_price to $current_price for $file $url and lowest was $lowest_price, here is list $list" | mutt -s "Price changed $last_price to $current_price for $file"  -e "set realname='$name'" merakod@gmail.com
echo "Price changed! $current_date $last_price to $current_price for $file $url and lowest was $lowest_price, here is list $list" >>/home/manish/puppeteer-scraper/flipkart_urls/listofchangedprice.txt
  fi
#name date price
  # Sleep for a defined time (e.g., 1 minute) before running the loop again
>>>>>>> 32954ce (Initial backup files upload)

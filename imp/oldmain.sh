#!/bin/bash

# Get the TXT filename (assuming only one)
file=$(ls *.txt)

# Get the last price from the file (last line)
last_price=$(tail -1 "$file")
record_date=$(date "+%Y-%m-%d %H:%M:%S")
# Get the current price from link.js and extract using grep
rating=$(cat url)

current_price=$(node link.js "$rating" | grep -oP '"price":\s*\K\d+' | head -n 1)

node link.js "$rating" | grep -oP 'ratingValue":\s*\d+(\.\d+)?' | head -n 1 >>rating
ratingmail=$(cat rating|tail -n 1)

# Check if current_price is valid
if [ -z "$current_price" ]; then
    echo "Price not found for $file on $record_date" | tee -a /home/manish/puppeteer-scraper/flipkart_urls/infologs.txt
else
    # Compare with last recorded price
    if [ "$last_price" -eq "$current_price" ]; then
        echo "Status is the same for $file price @ $current_price and rating $ratingmail $record_date" | tee -a /home/manish/puppeteer-scraper/flipkart_urls/infologs.txt
    else
        current_date=$(date "+%Y-%m-%d %H:%M:%S")
        c_date=$(date "+%Y-%m-%d %H:%M:%S")

        # Log to main history file
        echo "$file, $c_date, $current_price rating $ratingmail" | tee -a /home/manish/puppeteer-scraper/flipkart_urls/allpricehistory.txt

        echo "Price changed"

        # Append date and price to product-specific file
        echo "$current_date" | tee -a "$file"
        echo "$current_price" | tee -a "$file"

        # Gather info for email/logging
        url=$(cat url)
        lowest_price=$(grep -E '^[0-9]+$' *.txt | sort -n | head -n 1)
        list=$(grep -E '^[0-9]+$' *.txt | sort -n)
        name=$(ls *.txt)
echo "print"
echo "$ratingmail"
        # Send email notification
        echo "rating is $ratingmail Price changed! $current_date  $last_price to $current_price for $file $url and lowest was $lowest_price, here is list $list" \
            | mutt -s "Price changed $last_price to $current_price for $file" \
            -e "set realname='$name'" merakod@gmail.com

        # Save to list of changed prices
        echo "Price changed! $current_date $last_price to $current_price for $file $url and lowest was $lowest_price, here is list $list" \
            | tee -a /home/manish/puppeteer-scraper/flipkart_urls/listofchangedprice.txt
    fi
fi

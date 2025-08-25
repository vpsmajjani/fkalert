#!/bin/bash

# Set working directory to the script's location
script_dir=$(dirname "$(readlink -f "$0")")
cd "$script_dir"
old_path='/home/manish/puppeteer-scraper/flipkart_urls'

# File and path setup
file=$(ls *.txt)
record_date=$(date "+%Y-%m-%d %H:%M:%S")
db_path="$script_dir/../product_prices.db"
log_base="$script_dir/../"

# Get the last price from the file (if exists)
if [ -f "$file" ]; then
    last_price=$(tail -1 "$file")
else
    last_price=""
fi

# Get URL and extract current price and rating (only numeric)
url=$(cat url)
current_price=$(node link.js "$url" | grep -oP '"price":\s*\K\d+' | head -n 1)
ratingmail=$(node link.js "$url" | grep -oP 'ratingValue":\s*\K\d+(\.\d+)?' | head -n 1)

# Ensure DB table exists
sqlite3 "$db_path" <<EOF
CREATE TABLE IF NOT EXISTS bulk_product_price_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_file TEXT,
    record_date TEXT,
    price INTEGER,
    rating TEXT,
    url TEXT
);
EOF

# Check if current price is valid
if [ -z "$current_price" ]; then
    echo "Price not found for $file on $record_date" | tee -a "${log_base}infologs.txt"
else
    # Check if it's the first time (file empty or no numbers)
    if ! grep -qE '^[0-9]+$' "$file" 2>/dev/null; then
        echo "$record_date" | tee -a "$file"
        echo "$current_price" | tee -a "$file"

        echo "$file, $record_date, $current_price $ratingmail" | tee -a "${log_base}allpricehistory.txt"
        echo "$file, $record_date, $current_price $ratingmail" | tee -a "$old_path/allpricehistory.txt"

        # Escape for SQLite
        safe_rating=$(echo "$ratingmail" | sed "s/'/''/g")
        safe_url=$(echo "$url" | sed "s/'/''/g")

        # Insert into database
        sqlite3 "$db_path" <<EOF
INSERT INTO bulk_product_price_history (product_file, record_date, price, rating, url)
VALUES ('$file', '$record_date', $current_price, '$safe_rating', '$safe_url');
EOF

        echo "Initial price recorded for $file: $current_price on $record_date" \
            | tee -a "${log_base}infologs.txt"
    else
        if [ "$last_price" -eq "$current_price" ]; then
            echo "Status is the same for $file price @ $current_price and rating $ratingmail $record_date" \
                | tee -a "${log_base}infologs.txt"
        else
            echo "$file, $record_date, $current_price $ratingmail" | tee -a "${log_base}allpricehistory.txt"
            echo "$file, $record_date, $current_price $ratingmail" | tee -a "$old_path/allpricehistory.txt"

            echo "Price changed"
            echo "$record_date" | tee -a "$file"
            echo "$current_price" | tee -a "$file"

            # Find lowest and full list of prices
            lowest_price=$(grep -E '^[0-9]+$' *.txt | sort -n | head -n 1)
            list=$(grep -E '^[0-9]+$' *.txt | sort -n)
            name=$(ls *.txt)

            # Escape for SQLite
            safe_rating=$(echo "$ratingmail" | sed "s/'/''/g")
            safe_url=$(echo "$url" | sed "s/'/''/g")

            # Insert into database
            sqlite3 "$db_path" <<EOF
INSERT INTO bulk_product_price_history (product_file, record_date, price, rating, url)
VALUES ('$file', '$record_date', $current_price, '$safe_rating', '$safe_url');
EOF

            # Email notification
            echo "rating is $ratingmail as on $record_date Price changed! $last_price to $current_price for $file $url and lowest was $lowest_price, here is list $list" \
                | mutt -s "Price changed $last_price to $current_price for $file" \
                -e "set realname='$name'" merakod@gmail.com

            # Log change
            echo "Price changed! $record_date $last_price to $current_price for $file $url and rating $ratingmail and lowest was $lowest_price, here is list $list" \
                | tee -a "${log_base}listofchangedprice.txt"
        fi
    fi
fi

#!/bin/bash

main=/home/manish/puppeteer-scraper/flipkart_urls/recorder/flight/main
db_path="/home/manish/puppeteer-scraper/flipkart_urls/recorder/flight/flight_prices.db"

echo "Enter your flight URL:"
read url

# Extract date and create folder path
date_from=$(echo "$url" | grep -oP '(?<=trips=).*?(?=&travellers)')
prefix=${date_from:0:8}
datepart=${date_from:8:8}
formatted_date="${datepart:0:2}-${datepart:2:2}-${datepart:4:4}"
result="${prefix}${formatted_date}"

echo "$result"

mkdir -p /home/manish/puppeteer-scraper/flipkart_urls/recorder/flight/$result
path=/home/manish/puppeteer-scraper/flipkart_urls/recorder/flight/$result
cp $main/scrolllink.js $main/price10.py $main/parse_flights_v2.sh $main/command $path/

# Create and prepare files
touch $path/runme.sh
echo "" > $path/old_price.txt
echo "cd $path" >$path/runme.sh
echo "/usr/bin/node $path/scrolllink.js '$url' | grep -oP '₹[0-9,]+' > $path/dump2 && /usr/bin/bash $path/parse_flights_v2.sh > $path/latest_price.txt" >>$path/runme.sh
echo "/usr/bin/python3 $path/price10.py" >>$path/runme.sh

# Run once immediately
sh $path/runme.sh

# Save initial snapshot
cp $path/latest_price.txt $path/initial_price_$result

# Suggest cronjob
echo "Add this to crontab:"
echo "7 * * * * sh $path/runme.sh >> /tmp/flight_$result.txt 2>&1"

# Update batch run file
echo "cd $path" >> /home/manish/puppeteer-scraper/flipkart_urls/recorder/flight/shflight.sh
echo "sh $path/runme.sh" >> /home/manish/puppeteer-scraper/flipkart_urls/recorder/flight/shflight.sh

# Update placeholder in script
sed -i "s/needdate/$result/g" $path/price10.py

# ----- SQLite Part -----
# Get extracted price (first ₹ matched, numbers only)
current_price=$(grep -oP '₹\K[0-9,]+' $path/latest_price.txt | head -n 1 | tr -d ',')
record_date=$(date "+%Y-%m-%d %H:%M:%S")

# Ensure DB and table exist
sqlite3 "$db_path" <<EOF
CREATE TABLE IF NOT EXISTS flight_price_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    flight_code TEXT,
    record_date TEXT,
    price INTEGER,
    url TEXT
);
EOF

# Insert new record
if [ -n "$current_price" ]; then
    sqlite3 "$db_path" <<EOF
INSERT INTO flight_price_history (flight_code, record_date, price, url)
VALUES ('$result', '$record_date', $current_price, '$url');
EOF
    echo "Inserted into DB: $result, ₹$current_price on $record_date"
else
    echo "No price found for $url"
fi

cd $path

#!/bin/bash
cd /home/manish/puppeteer-scraper/flipkart_urls/recorder/flight/pnr1
URL="https://www.railmitra.com/pnr-status?pnr=8632988568"
path=/home/manish/puppeteer-scraper/flipkart_urls/recorder/flight/pnr1
CURRENT_STATUS=$(node $path/link.js "$URL" | grep -oP '<td>GNWL 205</td><td>\KGNWL \d+')
STATUS_FILE="$path/old_status.txt"

# If no old status file, create it first time
if [ ! -f "$STATUS_FILE" ]; then
    echo "$CURRENT_STATUS" > "$STATUS_FILE"
    echo "First time setup done."
    exit 0
fi

OLD_STATUS=$(cat "$STATUS_FILE")

# Compare old and current status
if [ "$CURRENT_STATUS" != "$OLD_STATUS" ]; then
    echo "Status changed! Sending email..."
    
    # Sending email
    echo "$CURRENT_STATUS" | mutt -s "PNR Status Changed" mannabhanushali@gmail.com
    
    # Update the saved status
    echo "$CURRENT_STATUS" > "$STATUS_FILE"
else
    echo "No change in status."
fi


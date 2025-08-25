#!/bin/bash

# File paths
BASE_DIR="/home/manish/puppeteer-scraper/flipkart_urls/recorder/flight"
RAW_FILE="$BASE_DIR/flight_fares_raw.txt"
PREVIOUS_FILE="$BASE_DIR/flight_fares_previous.txt"
SORTED_CURRENT="$BASE_DIR/flight_fares_sorted_current.txt"
DIFF_FILE="$BASE_DIR/flight_fare_changes.txt"

# Get the latest fares (replace this block with live fetching if needed)
cat <<EOF > "$RAW_FILE"
IndiGo 6E-5323 ₹4770
IndiGo 6E-5205 ₹4770
IndiGo 6E-6283 ₹5145
Akasa Air QP-1194 ₹5218
Air India AI-2604 ₹394
IndiGo 6E-5218 ₹6011
IndiGo 6E-5089 ₹6011
IndiGo 6E-5011 ₹6011
IndiGo 6E-5069 ₹6011
IndiGo 6E-5031 ₹6011
IndiGo 6E-5255 ₹6011
IndiGo 6E-5094 ₹6011
Akasa Air QP-1736 ₹6205
Akasa Air QP-1375 ₹6407
Air India AI-2846 ₹6412
Air India AI-2840 ₹6412
Air India AI-2630 ₹6519
Air India AI-2645 ₹6519
IndiGo 6E-5051 ₹7058
IndiGo 6E-5351 ₹7058
IndiGo 6E-5376 ₹7058
Akasa Air QP-1366 ₹7121
Air India AI-2852 ₹7458
Air India AI-2864 ₹7458
Air India AI-2854 ₹7587
Air India AI-2850 ₹7587
Air India AI-2402 ₹9149
Air India AI-2610 ₹9311
IndiGo 6E-5216 ₹9852
IndiGo 6E-5295 ₹11699
EOF

# Sort the current fares
sort "$RAW_FILE" > "$SORTED_CURRENT"

# Check if previous file exists
if [ -f "$PREVIOUS_FILE" ]; then
    diff "$PREVIOUS_FILE" "$SORTED_CURRENT" > "$DIFF_FILE"
    
    if [ -s "$DIFF_FILE" ]; then
        echo "Fare changes detected. Sending email..."
        mutt -s "Flight Fare Changes Detected" your_email@example.com < "$DIFF_FILE"
    fi
fi

# Update the previous file with the latest sorted fares
cp "$SORTED_CURRENT" "$PREVIOUS_FILE"


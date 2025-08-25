#!/bin/bash

# 1. Run your flight scraper and clean the output
bash parse_flights_v2.sh | awk -F '|' '{print $2, $6}' | grep -v 'Flight No' \
    | sed 's/₹//' | tr -d ',' | sort -u > current_prices.txt

# 2. Check if previous_prices.txt exists
if [ ! -f previous_prices.txt ]; then
    echo "No previous prices found. Saving current as baseline."
    cp current_prices.txt previous_prices.txt
    exit 0
fi

# 3. Compare old vs new
echo "Comparing flight prices..."
awk '
    FNR==NR { prev[$1]=$2; next }
    {
        if (!($1 in prev)) {
            printf "%s: NEW flight, Price=%s\n", $1, $2
        } else if ($2 != prev[$1]) {
            diff = $2 - prev[$1]
            printf "%s: Price changed: Old=%s, New=%s, Change=%+d\n", $1, prev[$1], $2, diff
        }
    }
'  current_prices.txt  previous_prices.txt > price_diff_report.txt

# 4. Also check for removed flights
awk '
    FNR==NR { curr[$1]=$2; next }
    {
        if (!($1 in curr)) {
            printf "%s: REMOVED from current, Previous Price=%s\n", $1, $2
        }
    }
' current_prices.txt previous_prices.txt >> price_diff_report.txt

# 5. If there are changes, email the report (optional)
if [ -s price_diff_report.txt ]; then
    echo "Changes detected!"
    cat price_diff_report.txt
    # Uncomment this to email
    # mutt -s "Flight Fare Changes" -a price_diff_report.txt -- your@email.com < price_diff_report.txt
else
    echo "No changes found."
fi

# 6. Update previous_prices.txt with the latest prices
cp current_prices.txt previous_prices.txt
echo "Previous prices updated."


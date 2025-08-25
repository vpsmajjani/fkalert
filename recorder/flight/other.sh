#!/bin/bash

# Output file
OUTFILE="dimp"

# Flipkart flights URL
URL='https://www.flipkart.com/travel/flights/search?trips=BLR-BOM-25042025&travellers=1-0-0&class=e&tripType=ONE_WAY&isIntl=false&source=TravelFlightFareCard'

# Run the scrolllink script, extract relevant data
node scrolllink.js "$URL" \
| grep -oP '₹[0-9,]+|[0-9]{2}:[0-9]{2}|(?<=<span>)[^<]+' \
| sed 's/|/\n/g' \
| paste -d '\t' - - - - - - - - \
> "$OUTFILE"

# Insert header row
sed -i '1i Airline\tFlight1\tFlight2\tDepTime\tDuration\tArrival\tPrice\tDiscount\tTax' "$OUTFILE"

echo "✅ Flight data saved to $OUTFILE"


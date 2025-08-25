#!/bin/bash

# Define the paths for the old and latest price files
OLD_FILE="old_price.txt"
LATEST_FILE="latest_price.txt"
EMAIL="mannabhanushali@gmail.com"  # Replace with your email address

# Check if both files exist
if [[ ! -f "$OLD_FILE" ]]; then
  echo "Error: $OLD_FILE not found!"
  exit 1
fi

if [[ ! -f "$LATEST_FILE" ]]; then
  echo "Error: $LATEST_FILE not found!"
  exit 1
fi

# Function to send an email alert using mutt
send_email_alert() {
  local subject="$1"
  local body="$2"
  echo -e "$body" | mutt -s "$subject" "$EMAIL"
}

# Create a temporary file to store updated prices
TEMP_FILE=$(mktemp)

# Flag to track if any price change was detected
price_change_detected=false

# Loop through each line in the old and new files
while read -r old_line && read -r new_line <&3; do
  # Extract the price part using regex for price comparison
  old_price=$(echo "$old_line" | grep -oP '₹\d+[\d,]*')
  new_price=$(echo "$new_line" | grep -oP '₹\d+[\d,]*')

  # Compare the prices
  if [[ "$old_price" != "$new_price" && -n "$old_price" && -n "$new_price" ]]; then
    # A price change is detected, print the difference
    echo "Price change detected:"
    echo "Old: $old_line"
    echo "New: $new_line"
    
    # Update the flag that a price change was detected
    price_change_detected=true
  fi

  # Update the temporary file with the latest line (either old or new)
  echo "$new_line" >> "$TEMP_FILE"
done < "$OLD_FILE" 3< "$LATEST_FILE"

# If a price change is detected, send an email alert
if $price_change_detected; then
  subject="Price Change Detected"
  body="There has been a price change detected in the flight prices. Please check the details.\n\nOld prices and new prices are compared."
  send_email_alert "$subject" "$body"
else
  echo "No price changes detected."
fi

# Replace the old price file with the updated content (latest prices)
mv "$TEMP_FILE" "$OLD_FILE"

# End of the script


#!/bin/bash

# Run the node script and check if 'offline' appears
offline_count=$(node /home/manish/puppeteer-scraper/flipkart_urls/recorder/$1/link.js https://superchatlive.com/$1 | grep -oP 'offline' | wc -l)

# Check the value of the offline_count and take different actions based on the output
if [ "$offline_count" -eq 6 ]; then
  # If offline_count is 6, run your_other_script.sh
echo "model is online, recording may start soon"
sh /home/manish/puppeteer-scraper/flipkart_urls/recorder/$1/$1.sh
elif [ "$offline_count" -eq 2 ]; then
  # If offline_count is 2, print "Invalid URL"
  echo "Invalid URL"
elif [ "$offline_count" -eq 12 ]; then
  # If offline_count is 12, print "Model is offline"
  echo "Model is offline"
else
  # Handle any other cases if necessary
  echo "Unexpected number of 'offline' occurrences: $offline_count"
fi

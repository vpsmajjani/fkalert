# Run the node script and check if 'offline' appears 6 times
offline_count=$(node /home/manish/puppeteer-scraper/flipkart_urls/recorder/_Chlo__e/link.js https://superchatlive.com/$1 | grep -oP 'offline' | wc -l)

# Check if the count is 6, then run the next script
if [ "$offline_count" -eq 6 ]; then
  # Replace 'your_other_script.sh' with the script you want to run
sh /home/manish/puppeteer-scraper/flipkart_urls/recorder/_Chlo__e/_Chlo__e.sh
fi


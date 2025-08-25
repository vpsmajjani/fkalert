while true; do
file=`ls *.txt`
  # Get the last price from fan (excluding the last line using `head -n -1`)
  last_price=$(cat $file | tail -1)

  # Get the current price by running other.js and extracting the price using grep
  current_price=$(node link.js 'http' | grep -oP '₹\d+\.\d{2}(?=\s+with\s+\d+\s+percent\s+savings)' | sed 's/₹//; s/\.00//')

  # Compare the last price from fan with the current price
  if [ "$last_price" -eq "$current_price" ]; then
    echo "Status is the same"
  else
current_date=$(date "+%Y-%m-%d %H:%M:%S")
	echo "price changed"
echo "$current_date">>$file
    # Append the new price to fan
    echo "$current_price" >> $file

 echo "Price changed! $last_price to $current_price for $file" | mutt -s "Price changed $last_price to $current_price for $file" mannabhanushali@gmail.com
  fi

  # Sleep for a defined time (e.g., 1 minute) before running the loop again
  sleep 7200
done

#####

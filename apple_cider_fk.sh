while true; do
file=`ls *.txt`
  # Get the last price from fan (excluding the last line using `head -n -1`)
  last_price=$(cat $file | tail -1)

  # Get the current price by running other.js and extracting the price using grep
  current_price=$(node link.js 'https://www.flipkart.com/wow-skin-science-apple-cider-vinegar-foaming-no-parabens-sulphate-face-wash/p/itmbd81864d1c0de?pid=FCWFYFDCVEPQ3GHB' | grep -oP '"price":\s*\K\d+' | head -n 1)

  # Compare the last price from fan with the current price
  if [ "$last_price" -eq "$current_price" ]; then
    echo "Status is the same"
  else
current_date=$(date "+%Y-%m-%d %H:%M:%S")
        echo "price changed"
echo "$current_date">>$file
    # Append the new price to fan
    echo "$current_price" >> $file
url=`cat url`
lowest_price=`grep -E '^[0-9]+$' *.txt | sort -n | head -n 1`
list=`grep -E '^[0-9]+$' *.txt | sort -n`
 echo "Price changed! $last_price to $current_price for $file $url and lowest was $lowest_price, here is list $list" | mutt -s "Price changed $last_price to $current_price for $file" mannabhanushali@gmail.com
  fi

  # Sleep for a defined time (e.g., 1 minute) before running the loop again
  sleep 7200
done

current_hour=$(date +%H)

if [ "$current_hour" -eq 15 -o "$current_hour" -eq 23 ]; then
echo "Taking backup...at 3PM or 11PM"
cd /home/manish/puppeteer-scraper/flipkart_urls
sh backuptak1.sh
    # Your backup commands here
echo "successfully backup taken in tar at `date`"
else
echo "exiting, not 11pm or am for backup time"
fi

current_hour=$(date +%H)

if [ "$current_hour" -eq 5 -o "$current_hour" -eq 17 ]; then
echo "Taking backup...at 11"
cd /home/manish/puppeteer-scraper/flipkart_urls
sh backuptak1.sh
    # Your backup commands here
echo "successfully backup taken in tar at `date`"
else
echo "exiting, not 11pm or am for backup time"
fi

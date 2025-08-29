current_hour=$(date +%H)

if [ "$current_hour" -eq 1 -o "$current_hour" -eq 13 ]; then
echo "Taking backup...at 11"
cd /home/manish/puppeteer-scraper/flipkart_urls
sh backuptak1.sh
    # Your backup commands here
else
echo "exiting, not 11pm or am for backup time"
fi

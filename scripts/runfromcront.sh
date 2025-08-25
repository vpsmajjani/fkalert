sleep 30
echo "post reboot, sleep of 30 seconds passed, now price will be recorder on $date" >> /tmp/runfromcront.txt
cd /home/manish/puppeteer-scraper/flipkart_urls/
docker exec flipkart bash /home/manish/puppeteer-scraper/flipkart_urls/scripts/exeru.sh
sh /home/manish/puppeteer-scraper/flipkart_urls/scripts/backuptak1.sh
#docker exec flipkart bash -c "echo 'Backup complted, shutting down' | mutt -s 'Backup completed, Shutting down' mannabhanushali@gmail.com"
uptime
free -h


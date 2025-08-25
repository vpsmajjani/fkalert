docker exec -it price node /home/manish/puppeteer-scraper/flipkart_urls/record5working.js https://superchatlive.com/OraCurrington
videoname = $(cat videoscript.sh  | awk -F'/' {'print $9'} | head -n 1)
cp /var/lib/docker/overlay2/9d56c54c62e4801b99c10341b9ff2c23ebad78de88d3a8747a2a5045e008f636/diff/$videoname /root/
rm /var/lib/docker/overlay2/9d56c54c62e4801b99c10341b9ff2c23ebad78de88d3a8747a2a5045e008f636/diff/frames/*

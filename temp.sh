for i in `ls -1d */ | sed 's#/##'`; do
  cd "$i" && nohup sh /home/manish/puppeteer-scraper/flipkart/"$i.sh" &
done


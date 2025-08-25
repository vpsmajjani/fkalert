cd /home/manish/puppeteer-scraper/flipkart_urls/products
for i in $(find . -mindepth 2 -name "*.sh"); do cat maindatabase.sh >$i; done
for d in */; do (cd "$d" && bash *.sh); done

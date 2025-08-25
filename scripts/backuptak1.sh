date1=$(date +%d-%m-%y-%M)

cd /home/manish/puppeteer-scraper/flipkart_urls/

sudo tar --exclude='./node_modules' \
    --exclude='./products/node_modules' \
    --exclude='./products/.venv' \
    --exclude='./bulkproduct/products/.venv' \
    --exclude='./flipkart_url_git_setup' \
    --exclude='*.tar.gz' \
    --exclude='.git' \
    -czf backup_on_$date1.tar.gz .







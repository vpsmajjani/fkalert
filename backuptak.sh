cd /workspaces/flipkart_dockerfile/inside/flipkart_urls
sudo tar --exclude='./node_modules' \
    --exclude='./products/node_modules' \
    --exclude='./products/.venv' \
    --exclude='./bulkproduct/products/.venv' \
    --exclude='./flipkart_url_git_setup' \
    -czf /workspaces/flipkart_dockerfile/backup_on_`date +%d-%m-%y-%M`.tar.gz .

echo "started at `date`"

docker exec flipkart sh /home/manish/puppeteer-scraper/flipkart_urls/products/executeshfiles.sh
echo "file pricing done, passing to git push"

docker exec flipkart sh /home/manish/puppeteer-scraper/flipkart_urls/pushgit.sh
echo ""
echo "file pushing done, exiting from codespace, moving to localsystem docker"
#cd /workspaces/fkalert
#pwd
#whoami
#git add .
#git commit -m "added by server"
#git push
echo "ended at `date`"
#gh codespace list
#echo "stopping 11"
#gh codespace stop --codespace curly-xylophone-v66jv6wwr9x7hpwxw
#echo "stopping 2"
#gh codespace stop --codespace curly-xylophone-v66jv6wwr9x7hpwxw
#echo "stopping 3"
#gh codespace stop --codespace curly-xylophone-v66jv6wwr9x7hpwxw
#sleep 60
#echo "stoping 4"
#gh codespace stop --codespace curly-xylophone-v66jv6wwr9x7hpwxw

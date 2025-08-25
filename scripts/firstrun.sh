#this if outside github /home/manish
cd /home/manish/puppeteer-scraper/flipkart_urls
rm -rf ~/.gitconfig
rm -rf .git
rm -rf *
git clone git@github.com:mannakod/final_flipkar_backup.git .
git pull

git rm final_flipkar_backup
sh /home/manish/puppeteer-scraper/flipkart_urls/scripts/runfromcront.sh
sh /home/manish/puppeteer-scraper/flipkart_urls/scripts/backuptak1.sh
git branch -m master main
git init
git remote add origin git@github.com:mannakod/final_flipkar_backup.git
git pull origin main --rebase

git add .
git branch -m master main
git commit -m "server commited"

git push --set-upstream origin main
docker exec flipkart bash -c "echo 'Backup complted, shutting down' | mutt -s 'Backup completed, Shutting down' merakod@gmail.com@gmail.com
uptime
free -h
sudo shutdown now

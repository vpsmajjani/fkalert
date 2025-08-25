for i in $(find . -mindepth 2 -name "*.sh"); do cat maindatabase.sh >$i; done
sh executeshfiles.sh

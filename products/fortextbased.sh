for i in $(find . -mindepth 2 -name "*.sh"); do cat oldmain.sh >$i; done
sh executeshfiles.sh

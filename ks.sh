for i in $(cat killing); do
pgrep -f $i
done


current_hour=$(date +%H)

if [ "$current_hour" -eq 13 ]; then
    echo "Taking backup..."
    # Your backup commands here
else
echo "exiting"
fi

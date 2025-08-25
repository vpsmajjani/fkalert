#!/bin/bash

URL="https://www.railmitra.com/pnr-status?pnr=8632988568"
CURRENT_STATUS=$(node link.js "$URL" | grep -o 'TQWL [0-9]\+' | head -n 4 | sort)
STATUS_FILE="old_status.txt"

# If no old status file, create it first time
if [ ! -f "$STATUS_FILE" ]; then
    echo "$CURRENT_STATUS" > "$STATUS_FILE"
    echo "First time setup done."
    exit 0
fi

OLD_STATUS=$(cat "$STATUS_FILE")

# Compare old and current status
if [ "$CURRENT_STATUS" != "$OLD_STATUS" ]; then
    echo "Status changed! Sending email..."
    
    # Sending email
    echo "$CURRENT_STATUS" | mutt -s "PNR Status Changed" mannabhanushali@gmail.com
    
    # Update the saved status
    echo "$CURRENT_STATUS" > "$STATUS_FILE"
else
    echo "No change in status."
fi


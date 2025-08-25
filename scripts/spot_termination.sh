#!/bin/bash

# Log file for tracking
LOG_FILE="/var/log/spot_termination_watcher.log"
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

echo "$(date) - Spot termination watcher started." >> $LOG_FILE

while true; do
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://169.254.169.254/latest/meta-data/spot/instance-action)

    if [ "$RESPONSE" -eq 200 ]; then
        echo "$(date) - Termination notice received for instance $INSTANCE_ID" >> $LOG_FILE
        # Run your backup script
        sh /home/manish/puppeteer-scraper/flipkart_urls/scripts/backuptak1.sh >> $LOG_FILE 2>&1

        echo "$(date) - Custom backup script executed. Exiting watcher." >> $LOG_FILE
        break
    fi

    sleep 5
done

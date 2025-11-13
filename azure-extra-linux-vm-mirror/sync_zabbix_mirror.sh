#!/bin/bash

# Configuration Variables
ZABBIX_VERSION="7.0"
DISTRIBUTION="noble"
ARCHITECTURE="amd64"
MIRROR_ROOT="/var/www/html/zabbix_mirror"

# Log file for debmirror output
LOG_FILE="/var/log/zabbix-mirror-sync.log"

echo "$(date): Starting initial mirror sync for Zabbix $ZABBIX_VERSION on $DISTRIBUTION..." | tee -a $LOG_FILE

# The debmirror command. Output is redirected to the log file.
# FIX APPLIED: Changed --root from /zabbix/7.0/debian to /zabbix/7.0/ubuntu
sudo debmirror \
  --host=repo.zabbix.com \
  --root=/zabbix/$ZABBIX_VERSION/ubuntu \
  --method=http \
  --dist=$DISTRIBUTION \
  --arch=$ARCHITECTURE \
  --section=main \
  --progress \
  --ignore-release-gpg \
  $MIRROR_ROOT >> $LOG_FILE 2>&1

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "$(date): Synchronization completed successfully." | tee -a $LOG_FILE
else
    echo "$(date): Synchronization FAILED with exit code $EXIT_CODE. Check $LOG_FILE for details." | tee -a $LOG_FILE
fi

exit $EXIT_CODE
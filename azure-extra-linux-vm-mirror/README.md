# How to Setup a Local or Private Ubuntu Mirror


## Introduction
By default, Ubuntu systems get their updates straight from the internet at archive.ubuntu.com. In an environment with lots of Ubuntu systems (servers and/or desktops) this can cause a lot of internet traffic as each system needs to download the same updates.

In an environment like this, it would be more efficient if one system would download all Ubuntu updates just once and distribute them to the clients. In this case, updates are distributed using the local network, removing any strain on the internet link

## Why

https://louwrentius.com/how-to-setup-a-local-or-private-ubuntu-mirror.html

## debmirror ubuntu wiki

write about different types

https://help.ubuntu.com/community/Debmirror

## Zabbix Agent Repository Mirroring Guide (Ubuntu 24.04)

This guide provides a complete, step-by-step process for mirroring the Zabbix Debian/Ubuntu repository for a specific version and distribution using debmirror and serving it via Apache.

Scenario Details (for examples):

Zabbix Version: 7.0

Distribution: Noble (Ubuntu 24.04)

Architecture: amd64 (x64)

Mirror Root: /var/www/html/zabbix_mirror

### 1. Mirror Server Setup & Initial Sync

This section covers the installation of the necessary tools (debmirror and Apache) and the initial synchronization of the repository.

#### 1.1 Install Prerequisites

Install the mirroring tool and the web server on your dedicated mirror server (Ubuntu 24.04 VM).


dmzdocker03
* Linux (ubuntu 24.04)
* Standard B2s (2 vcpus, 4 GiB memory)
* VM architecture x64


```bash
# Update package lists
sudo apt update

# Install debmirror for synchronization
sudo apt install debmirror

# Install Apache to serve the files via HTTP
sudo apt install apache2

# Ensure Apache starts automatically on boot
sudo systemctl enable apache2

# log it
sudo systemctl status apache2
● apache2.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/apache2.service; enabled; prese>
     Active: active (running) since Thu 2025-11-13 17:28:16 UTC; 1min 15s ago

```
#### 1.2 Configure Apache Web Root

We need to ensure Apache is pointing to the correct root directory where the packages will be stored. We'll use the default Apache web root.

```bash
# Define the root path (must match the debmirror target)
MIRROR_ROOT="/var/www/html/zabbix_mirror"

# Create the target directory for the Zabbix packages
sudo mkdir -p $MIRROR_ROOT

# Ensure the www-data user (Apache's user) can read the directory structure
sudo chown -R www-data:www-data /var/www/html

cd /var/www/html/zabbix_mirror/
ls
# empty
```

#### 1.3 Create and Run Synchronization Script

It is best practice to wrap the mirroring command in a dedicated shell script. This ensures consistency for the initial run and for the automated cron job later.

First, create the script file: 

```bash
sudo nano /usr/local/bin/sync_zabbix_mirror.sh

```

Inside the file, add the following contents, including the shebang #!/bin/bash for consistency:

```bash
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
```

Next, make the script executable:

```bash
sudo chmod +x /usr/local/bin/sync_zabbix_mirror.sh
```

Finally, Run the script for the initial sync:

```bash
sudo /usr/local/bin/sync_zabbix_mirror.sh

```

```log
Thu Nov 13 17:40:50 UTC 2025: Starting initial mirror sync for Zabbix 7.0 on noble...
Thu Nov 13 17:45:01 UTC 2025: Synchronization completed successfully.
```

Check size

```bash
cd /var/www/html
du -sh *

12K     index.html
2.3G    zabbix_mirror

```

#### 1.4 Test Server Access

Verify that the mirrored repository is accessible via HTTP from any client machine. Replace YOUR_MIRROR_SERVER_IP with the actual IP address or hostname of your mirror server.

Expected Test URL: http://YOUR_MIRROR_SERVER_IP/zabbix_mirror/

![apache mirror files](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm-mirror/images/apache_mirror.png)





# How to Setup a Local or Private Ubuntu Mirror


## Introduction
By default, Ubuntu systems get their updates straight from the internet at archive.ubuntu.com. In an environment with lots of Ubuntu systems (servers and/or desktops) this can cause a lot of internet traffic as each system needs to download the same updates.

In an environment like this, it would be more efficient if one system would download all Ubuntu updates just once and distribute them to the clients. In this case, updates are distributed using the local network, removing any strain on the internet link

## Why and how

https://louwrentius.com/how-to-setup-a-local-or-private-ubuntu-mirror.html

## 💾 Local Debian Mirror for Zabbix Agent
This comprehensive guide includes all necessary steps to set up the mirror server, install a web server (Apache), and configure client machines to install the Zabbix Agent from your local source.
🚀 Server Setup: Creating the Mirror
1. Prerequisites and Initial Installation
You'll need debmirror for the sync and Apache to serve the files via HTTP.

### Update package list
sudo apt update

### Install debmirror and Apache Web Server
sudo apt install debmirror apache2 -y

2. Prepare the Mirror Directory
Create the directory where the Zabbix packages will be stored. We'll use the standard Apache web root for simplicity.

### Create the dedicated directory inside the Apache web root
sudo mkdir -p /var/www/html/zabbix-mirror

3. Configure and Run debmirror
Create a configuration file to specify the target repository.
> ⚠️ IMPORTANT: Replace YOUR_DISTRIBUTION (e.g., bookworm for Debian 12, jammy for Ubuntu 22.04) and YOUR_ARCH (e.g., amd64) with the correct values for your environment.
> 
### Create the config file
cat << EOF | sudo tee zabbix-mirror.conf
--root=/var/www/html/zabbix-mirror
--host=repo.zabbix.com
--method=http
--arch=YOUR_ARCH
--dist=YOUR_DISTRIBUTION
--section=zabbix
--ignore-release-gpg
--package=zabbix-agent*
EOF

### Execute the mirror sync (This may take a few minutes)
sudo debmirror --config-file=zabbix-mirror.conf

4. Configure Apache and Verification
Apache should be running by default after installation. The mirror should be accessible via your server's IP address.

### Ensure Apache service is active
sudo systemctl status apache2

The mirror content is now accessible at:
http://YOUR_SERVER_IP/zabbix-mirror/

## 💻 Client Setup: Using the Local Mirror
On each client machine, modify the list of package sources to use your new local mirror server.
1. Edit sources.list
Backup the original file, then open it for editing.
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
sudo nano /etc/apt/sources.list

2. Add the Local Mirror Entry
Add the following line to the file.
> ⚠️ IMPORTANT: Replace YOUR_SERVER_IP with your server's actual IP/hostname, and ensure YOUR_DISTRIBUTION matches the value you used in the server's debmirror.conf.
> 

Add this line to the end of the file:
deb http://YOUR_SERVER_IP/zabbix-mirror YOUR_DISTRIBUTION zabbix

3. Update and Install Zabbix Agent
The client will now resolve the zabbix-agent package against your local mirror.
sudo apt update
sudo apt install zabbix-agent

The Zabbix Agent is now installed from your local mirror.
Would you like a command to set up an automatic daily sync of the mirror on the server?

## 🔄 Setting up a Daily Mirror Sync (Cron Job)
To keep your local Zabbix mirror updated automatically, you should set up a cron job to run the debmirror command regularly.
1. Create a Sync Script
Although you could run the command directly in cron, creating a simple shell script makes it cleaner and easier to manage.
# Create the script file
sudo nano /usr/local/bin/sync-zabbix-mirror.sh

Paste the following content into the file. It assumes you saved your configuration file as zabbix-mirror.conf in the user's home directory.
#!/bin/bash
# Script to synchronize the local Zabbix mirror

# Change to the directory where the config file is located
cd /path/to/your/config/file # e.g., /home/user/

# Run debmirror using the configuration file
/usr/bin/debmirror --config-file=zabbix-mirror.conf

# Log the result (optional, but good practice)
echo "Zabbix mirror sync complete at $(date)" >> /var/log/zabbix-mirror-sync.log

2. Make the Script Executable
sudo chmod +x /usr/local/bin/sync-zabbix-mirror.sh

3. Add to Cron
Use crontab -e to open the cron configuration file.
sudo crontab -e

Add the following line to run the script every night at 3:00 AM (3 00 * * *).

Run Zabbix mirror sync daily at 3:00 AM
0 3 * * * /usr/local/bin/sync-zabbix-mirror.sh

The mirror will now automatically sync with the official Zabbix repository daily, ensuring your clients always get the latest agent version.


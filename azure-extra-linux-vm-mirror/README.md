# How to Setup a Local or Private Ubuntu Mirror


## Introduction
By default, Ubuntu systems get their updates straight from the internet at archive.ubuntu.com. In an environment with lots of Ubuntu systems (servers and/or desktops) this can cause a lot of internet traffic as each system needs to download the same updates.

In an environment like this, it would be more efficient if one system would download all Ubuntu updates just once and distribute them to the clients. In this case, updates are distributed using the local network, removing any strain on the internet link

## Why and how

https://louwrentius.com/how-to-setup-a-local-or-private-ubuntu-mirror.html

## 💾 Local Debian Mirror for Zabbix Agent

This guide outlines the steps to set up a local Debian mirror for the Zabbix Agent package using debmirror on a server and configure client machines to install the agent from this local source.
🚀 Server Setup: Creating the Mirror
1. Prerequisites
 * A server running Debian/Ubuntu.
 * sudo privileges.
 * A running Web Server (Apache or Nginx) to host the mirror files via HTTP.
2. Install debmirror
The debmirror utility handles the mirroring process.
sudo apt update
sudo apt install debmirror

3. Prepare the Mirror Directory
Create the directory that the web server will expose. We'll use /var/www/html/zabbix-mirror.
sudo mkdir -p /var/www/html/zabbix-mirror

4. Configure and Run debmirror
Create a configuration file to specify the target repository.
> ⚠️ IMPORTANT: Replace YOUR_DISTRIBUTION (e.g., bookworm, jammy) and YOUR_ARCH (e.g., amd64) with the values appropriate for your client systems.
> 
# Create the config file
'''bash 
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
'''

Execute the mirror sync (This may take a few minutes)
'''bash
sudo debmirror --config-file=zabbix-mirror.conf
'''

5. Verify Web Server Configuration
Ensure your web server (e.g., Apache) is running and configured to serve the contents of /var/www/html/zabbix-mirror. The mirror should be accessible via:
http://YOUR_SERVER_IP/zabbix-mirror/
💻 Client Setup: Using the Local Mirror
On each client machine, you need to modify the apt sources list to point to your new local mirror server.
1. Edit sources.list
Backup the original file, then open it for editing.
'''bash
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
sudo nano /etc/apt/sources.list
'''

2. Add the Mirror Entry
Add the following line to the end of the file.
> ⚠️ IMPORTANT: Replace YOUR_SERVER_IP with your server's IP/hostname, and ensure YOUR_DISTRIBUTION matches the value used in the server's debmirror.conf.
> 
# Add this line:
deb http://YOUR_SERVER_IP/zabbix-mirror YOUR_DISTRIBUTION zabbix

3. Update and Install Zabbix Agent
The client will now use the local mirror to find and install the package.
sudo apt update
sudo apt install zabbix-agent

The Zabbix Agent should now be installed, sourcing its files from your local mirror.

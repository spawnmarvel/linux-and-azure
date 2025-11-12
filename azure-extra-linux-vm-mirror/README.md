# How to Setup a Local or Private Ubuntu Mirror


## Introduction
By default, Ubuntu systems get their updates straight from the internet at archive.ubuntu.com. In an environment with lots of Ubuntu systems (servers and/or desktops) this can cause a lot of internet traffic as each system needs to download the same updates.

In an environment like this, it would be more efficient if one system would download all Ubuntu updates just once and distribute them to the clients. In this case, updates are distributed using the local network, removing any strain on the internet link

## Why

https://louwrentius.com/how-to-setup-a-local-or-private-ubuntu-mirror.html

## debmirror ubuntu wiki

https://help.ubuntu.com/community/Debmirror

## 💾 Local Debian Mirror for Zabbix Agent
This comprehensive guide includes all necessary steps to set up the mirror server, install a web server (Apache), and configure client machines to install the Zabbix Agent from your local source.
🚀 Server Setup: Creating the Mirror

## 💾 Local Debian Mirror for Zabbix Agent: Simplified Setup

Here is a concise guide covering both the server setup and client configuration.

-----

### 🚀 Server Setup: Creating the Mirror

This sets up the server to host the Zabbix Agent packages using Apache and `rsync`.

#### 1\. Server Preparation

Install the web server and the synchronization tool.

```bash
# Update and install tools
sudo apt update && sudo apt install apache2 rsync -y

# Create the mirror directory for serving files
sudo mkdir -p /var/www/html/zabbix_mirror
```

#### 2\. Mirror the Zabbix Files

Use `rsync` to pull the necessary Agent packages (`pool` directory) and the **`zabbix-release`** package file to your local server.

```bash
# Variables (Adjust ZABBIX_VERSION and OS_VERSION for your needs, e.g., 7.0 and debian12)
ZABBIX_VERSION="7.0"
OS_VERSION="debian12"
LOCAL_DIR="/var/www/html/zabbix_mirror"

# 1. Mirror the 'pool' directory (contains the zabbix-agent DEB files)
sudo rsync -av --delete --include "*/" --include "zabbix-agent*" --include "zabbix-release*" --exclude "*" \
    rsync://repo.zabbix.com/zabbix/${ZABBIX_VERSION}/debian/pool/ ${LOCAL_DIR}/pool/

# 2. Download the zabbix-release DEB package (for client key/repo setup)
wget -P ${LOCAL_DIR}/ \
    https://repo.zabbix.com/zabbix/${ZABBIX_VERSION}/debian/pool/main/z/zabbix-release/zabbix-release_*.deb
```

-----

### 🖥️ Client Setup: Installing the Agent

This configures the client to pull the Agent from your local mirror server (replace `192.168.1.10` with your **Server's IP address**).

#### 1\. Install the Release Package

Download the **`zabbix-release`** package from the local mirror and install it. This adds the Zabbix GPG key and creates the repository file.

```bash
# Replace 192.168.1.10 with your mirror IP
wget http://192.168.1.10/zabbix_mirror/zabbix-release_*.deb
sudo dpkg -i zabbix-release_*.deb
```

#### 2\. Redirect Repository Source

The installed package points to the official Zabbix repository. You must edit the file to point to your **local mirror**.

```bash
# Edit the Zabbix source file
sudo sed -i 's|http://repo.zabbix.com|http://192.168.1.10/zabbix_mirror|g' /etc/apt/sources.list.d/zabbix.list
```

*This command uses `sed` to automatically replace the official URL with your local server's URL.*

#### 3\. Install the Agent

Update the package list and install the agent. It will now be fetched from your local mirror.

```bash
sudo apt update
sudo apt install zabbix-agent -y
```

That's a great idea for completing the setup\! Adding testing and automation ensures your mirror is working and stays up-to-date.

-----

## ✅ Testing and Automation

### 1\. 🔍 Testing the Local Mirror

#### A. Server-Side Test

Ensure the files are accessible via the web server. Replace `YOUR_SERVER_IP` with the server's actual IP address.

```bash
# Check if the zabbix-release package is visible via HTTP
curl -I http://YOUR_SERVER_IP/zabbix_mirror/zabbix-release_*.deb
```

**Expected Output:** You should see a `HTTP/1.1 200 OK` response.

#### B. Client-Side Test

On the client machine, run `apt update` and look for the repository URL being used.

```bash
sudo apt update
```

**Expected Output:** The output should show it is fetching packages from your local IP address, not `repo.zabbix.com`. Look for a line similar to:

```
Hit:4 http://192.168.1.10/zabbix_mirror bookworm InRelease
```

If you see this, the client is correctly using the local mirror.

-----

### 2\. 🤖 Automation with Cron Job

You should automate the synchronization process to ensure your local mirror receives the latest Zabbix Agent package updates.

#### A. Create the Synchronization Script

Create a script file (e.g., `/usr/local/bin/sync_zabbix_mirror.sh`) to hold the `rsync` command.

```bash
sudo nano /usr/local/bin/sync_zabbix_mirror.sh
```

Paste the following content, adjusting the variables if necessary:

```bash
#!/bin/bash

# --- Mirror Synchronization Script ---
ZABBIX_VERSION="7.0"
LOCAL_DIR="/var/www/html/zabbix_mirror"

# 1. Mirror the 'pool' directory
rsync -av --delete --include "*/" --include "zabbix-agent*" --include "zabbix-release*" --exclude "*" \
    rsync://repo.zabbix.com/zabbix/${ZABBIX_VERSION}/debian/pool/ ${LOCAL_DIR}/pool/

# 2. Download the zabbix-release DEB package (overwriting the old one)
wget --output-document=${LOCAL_DIR}/zabbix-release_latest.deb \
    https://repo.zabbix.com/zabbix/${ZABBIX_VERSION}/debian/pool/main/z/zabbix-release/zabbix-release_*.deb
```

Make the script executable:

```bash
sudo chmod +x /usr/local/bin/sync_zabbix_mirror.sh
```

#### B. Set Up the Cron Job

Edit the root user's crontab to run the script automatically (e.g., every morning at 3:00 AM).

```bash
sudo crontab -e
```

Add the following line to the end of the file:

```crontab
# M H D_of_M M D_of_W  Command
0 3 * * * /usr/local/bin/sync_zabbix_mirror.sh > /dev/null 2>&1
```

This will run the synchronization script daily at 3 AM, keeping your local mirror fresh.

-----


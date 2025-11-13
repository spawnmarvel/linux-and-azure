# How to Setup a Local or Private Ubuntu Mirror


## Introduction
By default, Ubuntu systems get their updates straight from the internet at archive.ubuntu.com. In an environment with lots of Ubuntu systems (servers and/or desktops) this can cause a lot of internet traffic as each system needs to download the same updates.

In an environment like this, it would be more efficient if one system would download all Ubuntu updates just once and distribute them to the clients. In this case, updates are distributed using the local network, removing any strain on the internet link

## Why

https://louwrentius.com/how-to-setup-a-local-or-private-ubuntu-mirror.html

## debmirror ubuntu wiki

write about different types

https://help.ubuntu.com/community/Debmirror

## Example mirror zabbix agent
Mirroring the Zabbix agent Debian packages requires using a dedicated repository mirroring tool to safely copy the packages from the official Zabbix repository.
You generally need to mirror the entire Zabbix Debian repository for the specific version(s) and architecture(s) you need, as the agent package relies on the repository structure.
The two most common tools for this task are debmirror and apt-mirror. debmirror is highly recommended for its flexibility in filtering.
1. Using debmirror (Recommended)
debmirror is powerful because it allows you to filter exactly which components, architectures, and distributions you want, saving significant disk space and bandwidth.
Prerequisites
You need a dedicated server with enough disk space and the debmirror package installed.
# Install debmirror (on your mirror server)
sudo apt update
sudo apt install debmirror

debmirror Command Structure
You need to specify the source repository (Zabbix's official repo) and the desired filters.
 * Identify the Zabbix Repository: The official Zabbix repository structure is:
   * Base URL: http://repo.zabbix.com/zabbix/<VERSION>/debian
   * Distribution: bookworm, bullseye, etc.
   * Architecture: amd64, i386, arm64, etc.
 * Example Command (Zabbix 7.0, Bullseye, amd64):
   # Define variables
MIRROR_ROOT="/var/www/html/zabbix_mirror"
ZABBIX_VERSION="7.0"
DISTRIBUTION="bullseye"
ARCHITECTURE="amd64"

# Create the target directory
sudo mkdir -p $MIRROR_ROOT

# Run the debmirror command
sudo debmirror \
  --host=repo.zabbix.com \
  --root=/zabbix/$ZABBIX_VERSION/debian \
  --method=http \
  --dist=$DISTRIBUTION \
  --arch=$ARCHITECTURE \
  --section=main \
  --progress \
  --ignore-release-gpg \
  $MIRROR_ROOT

<!-- end list -->
 * --root: Specifies the subdirectory on the host (/zabbix/7.0/debian in this example).
 * --dist: Sets the Debian distribution codename (bullseye).
 * --arch: Specifies the CPU architecture (amd64).
 * --section: Zabbix typically uses the main component.
 * --ignore-release-gpg: Used because the Zabbix GPG keys aren't in the standard Debian keyring, which debmirror typically checks for.
Automate Synchronization
Schedule the command using cron to run regularly (e.g., daily) to keep your mirror up-to-date.
2. Configuring Clients to Use Your Mirror
Once the packages are mirrored, you need to update the sources.list.d file on your client machines (the Zabbix agent hosts) to point to your new local repository.
 * Create a new file on the client machine: /etc/apt/sources.list.d/zabbix-local.list
 * Add the repository line, replacing YOUR_MIRROR_SERVER and ZABBIX_VERSION as appropriate:
   deb http://YOUR_MIRROR_SERVER/zabbix_mirror/ zabbix-VERSION main

   * Example: If your mirror server is at 192.168.1.10 and you mirrored Zabbix 7.0 for Bullseye:
     deb http://192.168.1.10/zabbix_mirror/ bullseye main

     Note: The distribution name (e.g., bullseye) often becomes the section path in the mirror URL.
 * Update and install on the client:
   sudo apt update
sudo apt install zabbix-agent




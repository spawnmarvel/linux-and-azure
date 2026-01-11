# Zabbix Agent with dependencies as deb

For Ubuntu 24.04 (Noble Numbat), there is a specific detail you need to know: it uses OpenSSL 3 and libldap-2.5-0. If you try to use an older .deb package from Ubuntu 20.04 or 22.04, it will fail due to library version mismatches.
Since you are offline, the most reliable path for 24.04 is to use the Official Zabbix Repository packages downloaded on an online machine first.

Step 1: Download Packages (On an Online Machine)
* You need to download the Zabbix Agent and its specific Ubuntu 24.04 dependencies. * Open a terminal on an online Ubuntu 24.04 machine:

```bash
# ssh to Zabbix server that has internet access
ssh imsdal@145.xxx.xx.xx

mkdir zabbix_offline_2404
cd zabbix_offline_2404
pwd
/home/imsdal/zabbix_offline_24_04
```


## 1. Add the Zabbix 7.0 (or 6.4) Repo for Ubuntu 24.04

```bash
# we have already run the below commands since Zabbix is installed
# but now we will add packets to the folder
# cd /home/imsdal/zabbix_offline_24_04
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu24.04_all.deb
sudo dpkg -i zabbix-release_latest_7.0+ubuntu24.04_all.deb
sudo apt update

# or use the same packet as you already have on the Zabbix server from before

```

## 2. Download the agent and its specific dependencies without installing them
```bash
# cd /home/imsdal/zabbix_offline_24_04

apt-get download zabbix-agent zabbix-sender zabbix-get $(apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances zabbix-agent | grep "^\w" | sort -u)
```

Step 2: Transfer and Install (On the Offline Machine) using scp
* Make a deny rule on the vm, vmoffline01,192.168.3.4,   Deny-AllInternet
* Copy the zabbix_offline_2404 folder to your offline server.

 ```bash
# rsync
sync -azv zabbix_offline_24_04/ imsdal@192.168.3.4:/home/imsdal/zabbix_offline_24_04

# or scp if installed
# scp
# or make a python webserver and use wget in remote machine
# src vm
# cd /path/to/zabbix_files
# python3 -m http.server 8000
# destination vm
# wget http://[Source_IP]:8000/zabbix-agent_7.0.0.deb


 ```

 * Navigate into that folder on offline vm and install:
```bash
ssh imsdal@192.168.3.4
cd zabbix_offline_24_04/
sudo dpkg -i *.deb

# installing stuff
zabbix_agentd --version
zabbix_agentd (daemon) (Zabbix) 7.0.22
# success

# check the service
sudo service zabbix-agent status
● zabbix-agent.service - Zabbix Agent
     Loaded: loaded (/usr/lib/systemd/system/zabbix-agent.service;>
     Active: active (running) since Sun 2026-01-11 21:09:51 UTC; 1
```

Step 3: Configure for your Environment
Once installed, the service will be registered but won't work correctly until you tell it where the server is.

Configure the host in zabbix also

```bash
# Edit the config file:
sudo nano /etc/zabbix/zabbix_agentd.conf

# Update these three lines, select either passive or active depending og uses case:
# Server=192.168.3.5(Your Zabbix Server IP)
# ServerActive=127.0.0.1 (Your Zabbix Server IP), commented this out but used the other two
# Hostname=vmoffline01

# Restart the agent:
sudo systemctl restart zabbix-agent
sudo systemctl enable zabbix-agent
```

Log or data from zabbix

```log
vmoffline01 Linux: Host name of Zabbix agent running 1m 48s	vmoffline01	component: system

vmoffline01 Linux: Zabbix agent ping 21s	Up (1)		component: system
```
It works great


## Troubleshooting Dependencies on 24.04
If dpkg -i complains about a missing dependency, it is almost always one of these three. You can check what is missing by running:
```bash
ldd /usr/sbin/zabbix_agentd
```
If any line says "not found", you will need to grab that specific .deb from the Ubuntu package website (https://www.google.com/search?q=packages.ubuntu.com) for the "Noble" release.
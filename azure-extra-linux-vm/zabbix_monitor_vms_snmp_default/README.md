# Zabbix monitor VM's and SNMP default

A project for maximizing all default monitoring and not write a single script.

# Table of Contents

- [Zabbix monitor VM's and SNMP default](#zabbix-monitor-vms-and-snmp-default)
- [Table of Contents](#table-of-contents)
  - [Passive Mode (Server-Poll) Active Mode (Agent-Push)](#passive-mode-server-poll-active-mode-agent-push)
    - [Zabbix agents](#zabbix-agents)
    - [SNMP](#snmp)
  - [Tasks](#tasks)
  - [Stack and current version](#stack-and-current-version)
  - [Zabbix Windows/Linux by Zabbix agent active](#zabbix-windowslinux-by-zabbix-agent-active)
    - [Install Windows by Zabbix agent active](#install-windows-by-zabbix-agent-active)
    - [User parameters windows](#user-parameters-windows)
    - [Install Linux by Zabbix agent active](#install-linux-by-zabbix-agent-active)
    - [User parameters linux](#user-parameters-linux)
  - [Zabbix Linux by SNMP](#zabbix-linux-by-snmp)
    - [Install](#install)
  - [Simulate SNMP Trap Generator](#simulate-snmp-trap-generator)
  - [Setting up the Trap Receiver (Zabbix Side)](#setting-up-the-trap-receiver-zabbix-side)
  - [Enable Zabbix Trapper](#enable-zabbix-trapper)
    - [The "Low-Cost" Trap Generator (Sender Side)](#the-low-cost-trap-generator-sender-side)
  - [All Templates](#all-templates)
  - [Mysql tuning tbd](#mysql-tuning-tbd)

## Passive Mode (Server-Poll) Active Mode (Agent-Push)

In Zabbix, the distinction between Active and Passive modes relates to which entity initiates the communication and data transfer between the Zabbix Server/Proxy and the Zabbix Agent.

### Zabbix agents

![p_vs_a](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/p_vs_a.png)

### SNMP

Active Monitoring Note: While SNMP is primarily a polling (passive) protocol, Zabbix handles the metrics efficiently. If you require true "active" agent functionality (where the agent sends data to the server), ***it is recommended to use the "Linux by Zabbix agent active" template instead of SNMP***

![sp_vs_sa](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/sp_vs_sa.png)

## Tasks

* Use default agent 2 active / trap
* Use default templates for vm's
* Use Zabbix default snmp trap
* Use default snmp templates

## Stack and current version

* vmhybrid01, 192.168.3.7, (and puplic ip) Windows by Zabbix agent active
* vmzabbix03, 172.16.0.4, (and public ip) Zabbix 7 LTS and MySql 8.4
- https://www.zabbix.com/download?zabbix=7.0&os_distribution=ubuntu&os_version=24.04&components=server_frontend_agent_2&db=mysql&ws=apache
* vmzabbix03 MySQL by Zabbix agent 2
- https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/db/mysql_agent2
* vmchaos03, 172.16.0.5, (only private ip) ubuntu, Linux by Zabbix agent active
* vmsnmp03,  ubuntu (test true snmp), Linux by snmp

We made a new zabbix and mysql for fun.

Lets add ssl so we can use the octopus script after with runbook for change/ renew ssl easy.

```bash

sudo a2enmod ssl
sudo a2ensite default-ssl

sudo openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes \
  -out vmzabbix03.crt -keyout vmzabbix03.key \
  -subj "/C=NO/ST=Hordaland/L=BER/O=Socrates.inc/OU=IT/CN=vmzabbix03"

# Move the certificate
sudo mv vmzabbix03.crt /etc/ssl/certs/

# Move the private key
sudo mv vmzabbix03.key /etc/ssl/private/

sudo nano /etc/apache2/sites-available/default-ssl.conf

# SSLCertificateFile    /etc/ssl/certs/vmzabbix03.crt
# SSLCertificateKeyFile /etc/ssl/private/vmzabbix03.key

sudo apache2ctl configtest
# Syntax ok

# redirect http
sudo nano /etc/apache2/sites-available/000-default.conf
```
Add this to existing <VirtualHost *:80>:

```txt

[...]
ServerName vmzabbix03
# Redirect all HTTP traffic to HTTPS
Redirect permanent / https://vmzabbix03/
```

Run the syntax check again to ensure the redirect is written correctly.

```bash
sudo apache2ctl configtest
# syntax ok
sudo systemctl restart apache2
```
## Zabbix Windows/Linux by Zabbix agent active

### Install Windows by Zabbix agent active

vmhybrid01, 192.168.3.7, Windows by Zabbix agent active

Template

* https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/os/windows_agent_active

Install

* https://www.zabbix.com/download_agents?version=7.0+LTS&release=7.0.25&os=Windows&os_version=Server+2016+%2B&hardware=amd64&encryption=OpenSSL&packaging=MSI&show_legacy=0
* zabbix_agent2-7.0.25-windows-amd64-openssl.msi
* zabbix_agent2.conf

```bash
# Server=172.16.0.4
ServerActive=172.16.0.4
Hostname=vmhybrid01
```

Note: For active agents, the Zabbix Agent interface (IP address) is not strictly required in the host configuration, as the agent initiates the connection.

However if you want to add a Powershell/Bash scripts thats uses zabbix_sender (example)

```ps1
# [...]
C:\OP\Zabbix\zabbix_agent-7.0.24-windows-amd64-openssl\bin\zabbix_sender.exe -z 172.16.0.4 -s "vmhybrid01"  -k "WorkingSetMBTrapperPS1" -o $value
[...]
```
Then you should add interface with the servers ip and use item equal to this:

![item_ps1](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/item_ps1.png)

Data Collection and hosts (here no interface is defined, just active agent template and hostname)

![windows_a](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/windows_a.png)

Monitoring and hosts

![windows_items](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/windows_items.png)

In Zabbix, the "Windows by Zabbix agent active" template is a "master" or "parent" template. You generally do not need to manually select the other "active" items (CPU, Memory, Filesystem, etc.) because the master template already includes them as nested modules.  

1. What is already included?

When you link "Windows by Zabbix agent active", it automatically pulls in the following "active" modules:  

* Windows CPU: Utilization, interrupt time, and queue length.
* Windows Memory: Free/used memory and swap space.
* Windows Filesystems: Disk space discovery and usage.
* Windows Network: Interface discovery and traffic stats.
* Windows Physical Disks: Read/write latency and throughput.
* Windows Services: Monitoring of critical system services.

In Active Mode, your drive information does not appear instantly like a static field. It relies on a process called Low-Level Discovery (LLD).

* The Wait Time: By default, this rule usually runs every 1 hour.
* The Action: The Agent scans the Windows machine for drive letters (C:, D:, etc.) and sends that list to the Server.
* The Result: Only after this scan completes will the individual items (e.g., "Used disk space on C:") be created and start appearing in your Latest Data or Items list.

![wind_discovery](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/wind_discovery.png)

After discovery

![wind_data](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/windows_data.png)

Dashboards


![windows_disk](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/windows_disk.png)

### User parameters windows

https://www.zabbix.com/documentation/8.0/en/manual/config/items/userparameters



### Install Linux by Zabbix agent active

vmchaos03, 172.16.0.5, Linux by Zabbix agent active

Template

* https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/os/linux_active

Install

Add Zabbix repository, go the same pages as for install zabbix, but now select agent 2

* https://www.zabbix.com/download?zabbix=7.0&os_distribution=ubuntu&os_version=24.04&components=agent_2&db=&ws=

```bash
# This the same as we used for vmzabbix03
# wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu24.04_all.deb

# Since this vm does not have a public ip and is offline, we can login to
# vmzabbix03 and scp the same packet, then we use the same version.

# Solution: Use vmzabbix03 as a "Jump Host" for Packages
# Since you already have vmzabbix03 online, you can download the actual .deb installer files there and push them over, just like you did with the release package.

# Run these on vmzabbix03 (the online VM):
# Download the Zabbix Agent 2 package and its dependencies without installing them
mkdir -p ~/zabbix_pkgs && cd ~/zabbix_pkgs
sudo apt update
apt-get download zabbix-agent2

# Move the actual software package to the offline VM
scp *.deb imsdal@172.16.0.5:/home/imsdal/

ssh imsdal@172.16.0.5
# Install the local file directly bypassing the need for a repository
sudo dpkg -i zabbix-agent2*.deb

# If it complains about missing dependencies (like libssl), 
# you'll need to download those on the online VM as well.
sudo systemctl restart zabbix-agent2
sudo systemctl enable zabbix-agent2


# NB
# Wingate www proxy services is installed on DNS to apt now works
```
Configure it

```bash
# Server=172.16.0.4
ServerActive=172.16.0.4
Hostname=vmchaos03
```

Note: For active agents, the Zabbix Agent interface (IP address) is not strictly required in the host configuration, as the agent initiates the connection.

Data Collection and hosts

![linux_active](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/linux_active.png)

### User parameters linux


https://www.zabbix.com/documentation/8.0/en/manual/config/items/userparameters


## Zabbix Linux by SNMP

Monitoring Linux via SNMP in Zabbix is achieved by installing snmpd, configuring community strings (v2c) or authentication (v3), and linking the "Linux by SNMP" template. This template discovers file systems, network interfaces, and CPU metrics via UDP port 161, with Zabbix integrations providing pre-configured monitoring

Active Monitoring Note: While SNMP is primarily a polling (passive) protocol, Zabbix handles the metrics efficiently. If you require true "active" agent functionality (where the agent sends data to the server), ***it is recommended to use the "Linux by Zabbix agent active" template instead of SNMP***

### Install

https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/os/linux_snmp_snmp

## Simulate SNMP Trap Generator

Since Zabbix requires a receiver to handle traps, you can set up a "Dummy Agent" on a cheap Linux VM to fire off traps whenever you want to test your Zabbix server's reaction.

The Architecture

To test this, you need two components in your Azure VNet:

* The Receiver (Zabbix Server): Your existing Zabbix VM (192.168.3.5).
* The Sender (The "Trap Generator"): A new, tiny Linux VM (e.g., vm-trap-sender).

## Setting up the Trap Receiver (Zabbix Side)

## Enable Zabbix Trapper

### The "Low-Cost" Trap Generator (Sender Side)


## All Templates

All templates

* https://www.zabbix.com/integrations


https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/os/windows_agent_active

https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/os/linux_active

https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/os/linux_snmp_snmp

https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/net/fortinet/fortigate_snmp?at=release/6.4

![all templates](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/templates.png)


## Mysql tuning tbd


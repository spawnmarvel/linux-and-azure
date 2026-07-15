# Zabbix monitor VM's and SNMP default

A project for maximizing all default monitoring and trying to not write a single script, but use Zabbix Agent 2 built-in native functions.

# Table of Contents

- [Zabbix monitor VM's and SNMP default](#zabbix-monitor-vms-and-snmp-default)
- [Table of Contents](#table-of-contents)
  - [Passive Mode (Server-Poll) Active Mode (Agent-Push)](#passive-mode-server-poll-active-mode-agent-push)
    - [Zabbix agents](#zabbix-agents)
    - [SNMP](#snmp)
  - [Tasks](#tasks)
  - [Stack and current version](#stack-and-current-version)
  - [Zabbix Windows by Zabbix agent active](#zabbix-windows-by-zabbix-agent-active)
    - [Install Windows by Zabbix agent active](#install-windows-by-zabbix-agent-active)
    - [User parameters windows native](#user-parameters-windows-native)
    - [Item keys](#item-keys)
    - [Log monitor windows](#log-monitor-windows)
    - [Eventlog](#Eventlog)
  - [Zabbix Linux by Zabbix agent active](#zabbix-linux-by-zabbix-agent-active)
    - [Install Linux by Zabbix agent active](#install-linux-by-zabbix-agent-active)
    - [User parameters linux native](#user-parameters-linux-native)
    - [Log monitor linux](#log-monitor-linux)
  - [Zabbix Linux by SNMP](#zabbix-linux-by-snmp)
    - [Install](#install)
  - [Simulate SNMP Trap Generator](#simulate-snmp-trap-generator)
  - [References User parameter and log monitor](#references-user-parameter-and-log-monitor)
  - [All Templates](#all-templates)
- [AI 20h course](#ai-20h-course)
- [Zabbix Script Action](#zabbix-script-action)

## Passive Mode (Server-Poll) Active Mode (Agent-Push)

In Zabbix, the distinction between Active and Passive modes relates to which entity initiates the communication and data transfer between the Zabbix Server/Proxy and the Zabbix Agent.

A Zabbix Agent can be configured to run in both Active and Passive modes at the exact same time. By default, the standard out-of-the-box Zabbix Agent configuration is set up to listen for passive polling from the server while simultaneously processing active metrics and pushing them up.

While running both modes concurrently is common in standard corporate networks, you should avoid doing this inside your specific Purdue Model topology.


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
* vmsnmp03, 172.16.0.6 ,(only private ip) ubuntu Linux by snmp

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
## Zabbix Windows by Zabbix agent active

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

### User parameters windows native

Make custom template with 10 items

https://www.zabbix.com/documentation/8.0/en/manual/config/items/userparameters

### 1. Count all files in folder (native no scripts)

1. To count all files in a directory using a Zabbix Active Agent on Windows.

Since you are on Zabbix 7.0, you don't actually need PowerShell to count files. Zabbix Agent 2 has a built-in native function to do this. This is faster, more secure, and bypasses the shell restriction entirely.

This was tested for Zabbix 6.0 also.


ps1 test it

```ps1
(Get-ChildItem "C:\Program Files\GrafanaLabs\grafana\data\log" -File | Measure-Object).Count

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "(Get-ChildItem 'C:\Program Files\GrafanaLabs\grafana\data\log' -File | Measure-Object).Count"
```


The "Zabbix Agent Simulation" Test

This is the gold standard for testing. It checks if the Zabbix Agent can actually execute the command through its own engine.

* Run this from your current directory (c:\Program Files\Zabbix Agent 2):

```cmd
cd "c:\Program Files\Zabbix Agent 2"

zabbix_agent2.exe -c zabbix_agent2.conf -t vfs.dir.count["C:\Program Files\GrafanaLabs\grafana\data\log",,,file]

```
Result

```txt
vfs.dir.count["C:\Program Files\GrafanaLabs\grafana\data\log",,,file]
```


Note!!
Check what parmeter you need, there is many (it can count files, dirs, sockets and more)



```txt
vfs.dir.count[dir,<regex incl>,
<regex excl>,
<types incl>,
<types excl>,
<max depth>,
<min size>,
<max size>,<min age>,<max age>,<regex excl dir>]

```

https://www.zabbix.com/documentation/current/en/manual/config/items/itemtypes/zabbix_agent#vfs.dir.count


🔵 How to set it up in the Zabbix Web UI

You can now go straight to your Zabbix Server web interface and create the item:

* Name: Grafana Log File Count

* Type: Zabbix agent (active)

* Key: vfs.dir.count["C:\Program Files\GrafanaLabs\grafana\data\log",,,file]

* Type of information: Numeric (unsigned)

* Update interval: 1m or 5m

![vfs](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/vfs.png)

### 2. Zabbix Agent 2 has a built-in native function

1. Directory & File Monitoring (vfs.dir.*)


🔵  vfs.dir.size[path]: Calculates the total size of a folder (e.g., check if your backup folder is too large).

🔵  vfs.dir.size[C:\Program Files\GrafanaLabs\grafana\data\log]

🔵  vfs.file.cksum[path,mode]: Calculates a file checksum (CRC-32 by default). Used to detect if a configuration file or binary has been modified.

🔵 vfs.file.size[path,mode]: Returns the file size in bytes or the number of lines.

* vfs.file.size[C:\Program Files\GrafanaLabs\grafana\data\log\grafana.log,bytes]

* * bytes (default): Returns the actual size in bytes.
* * lines: Returns the number of lines in the file

![vfs params](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/vfs_params.png)

* vfs.file.exists[path,include,exclude]: Returns 1 if the file exists and 0 if it doesn't

* vfs.file.contents[path]: Reads the entire content of a file (useful for small config files or version files).

* vfs.file.regmatch[path,regexp]: Searches for a specific string inside a file and returns 1 if found. Great for checking "Success" or "Error" flags without full log monitoring.

2. Web & Certificate Monitoring (web.certificate.*)

In older versions, you needed a complex script to check SSL expiration. In Agent 2, it is native.

* web.certificate.get[hostname,port]: Returns all certificate details in JSON.

* web.certificate.errors[hostname,port]: Returns any validation errors (expired, self-signed, etc.).

* Trigger Tip: You can set an alert if the certificate has fewer than 30 days remaining.

3. Modern Windows Performance Counters
4. System & Network Reliability
5. Http

🔵 web.page.get[localhost,,80] : it’s a great way to verify that a local service (like WinGate's management interface, Grafana, or a local web server) is actually rendering content, rather than just having a "running" process. (Fetches the raw application landing page text).

Example:

* Web page is http://localhost:8983/solr/#/

In zabbix:

* key, web.page.get[localhost,"solr/index.html",8983]
* numeric
* Preproccessing, paramters HTTP/\d\.\d\s(\d+) and next box \1
* This gives a 200 value in zabbix that we can make a trigger on

🔵 net.tcp.service[tcp,staccount.file.core.windows.net,445]: TCP port check is actually more accurate than an ICMP ping

Example:
* Update intervall is 1m, it can fail occasionally so set trigger to check max in 3 min
* trigger:max(xxxxxx ,3m)=0
* max(/vmhybrid01/net.tcp.service[tcp,staccount.file.core.windows.net,445],3m) = 0


💡 Pro-Tip: The "Discover" Command
If you want to see every native key your specific Agent 2 supports, run this command on your Windows server:

```cmd
zabbix_agent2.exe -p

```

### Item keys

Note that all item keys supported by Zabbix agent are also supported by the new generation Zabbix agent 2. See the additional item keys that you can use with the agent 2 only.


* https://www.zabbix.com/documentation/8.0/en/manual/config/items/itemtypes/zabbix_agent


### Log monitor windows

Zabbix can be used for centralized monitoring and analysis of log files with/without log rotation support.


#### Log file monitoring
Notifications can be used to warn users when a log file contains certain strings or string patterns.

To find target text faults or capture service crashes, the agent relies heavily on integrated file monitoring routines

* log: Monitors lines within standard textual log files, with customizable regex filters.
* logrt: Reads continuously updated log sets featuring regular expression log-rotation patterns.


Make sure that in the agent configuration file:

* 'Hostname' parameter matches the host name in the frontend
* Servers in the 'ServerActive' parameter are specified for the processing of active checks

https://www.zabbix.com/documentation/3.4/en/manual/config/items/itemtypes/log_items



![active_server](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/active_server.png)


### log

Lets test log

* Make folder/file on server C:\appl\logs\application.log

Use this script to generate keywords and logs

```ps1
Add-Content -Path "C:\appl\logs\application.log" -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [INFO] Quick log entry 3" -Encoding utf8
Add-Content -Path "C:\appl\logs\application.log" -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [INFO] Quick log entry 4" -Encoding utf8
Add-Content -Path "C:\appl\logs\application.log" -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [INFO] Quick log entry 5" -Encoding utf8
Add-Content -Path "C:\appl\logs\application.log" -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [INFO] Quick log entry 6" -Encoding utf8
```

Example logs that will be generated

```log
[2026-07-15 12:18:49] [INFO] Quick log entry
[2026-07-15 12:31:00] [INFO] Quick log entry
[2026-07-15 12:31:06] [INFO] Quick log entry
[2026-07-15 12:31:07] [INFO] Quick log entry
[2026-07-15 12:31:38] [INFO] Quick log entry 1
[2026-07-15 12:35:00] [INFO] Quick log entry 2
[2026-07-15 12:35:49] [INFO] Quick log entry 3
[2026-07-15 12:36:04] [INFO] Quick log entry 3
[2026-07-15 12:36:54] [INFO] Quick log entry 3
[2026-07-15 12:36:58] [INFO] Quick log entry 4
[2026-07-15 12:37:04] [INFO] Quick log entry 5
[2026-07-15 12:37:08] [INFO] Quick log entry 6

```

Extracting matching part of regular expression

Sometimes we may want to extract only the interesting value from a target file instead of returning the whole line when a regular expression match is found.

Since Zabbix 2.2.0, log items have the ability to extract desired values from matched lines. This is accomplished by the additional output parameter in log and logrt items.

Using the 'output' parameter allows to indicate the subgroup of the match that we may be interested in.

Lets add it to the template we created below for eventlog (we are jumping a bit for section to section).

![log template](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/log_template.png)

How the Regular Expression and Capture Group Work

* Zabbix matches the word "Info " (with the space).
* The regular expression group (.*) captures everything remaining on that line:
* Because the 6th parameter is set to \1, the item value in Zabbix will store only the captured message:


Item Name

* Application Log Info 

Item key

* log["C:\\appl\\logs\\application.log","Quick (.*)",,,,\1]

Agent must be active.


![log_entry](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/log_entry.png)


If we want to track Warning for example

Item Name

* Application Log Warning

Item Key

* log["C:\\appl\\logs\\application.log","Warning (.*)",,,,\1]

Lets create that item and send

```ps1
Add-Content -Path "C:\appl\logs\application.log" -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [WARNING] Warning Application has crashed due to 13" -Encoding utf8
Add-Content -Path "C:\appl\logs\application.log" -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [INFO] Quick log entry 20" -Encoding utf8

```

Application low now

```log
[2026-07-15 13:03:33] [WARNING] Warning Application has crashed due to 13
[2026-07-15 13:03:33] [INFO] Quick log entry 20
```


![log warning](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/log_warning.png)

To get the log level in brackets

Item name

* Application Log Warning level

Item key

* log["C:\\appl\\logs\\application.log","\[WARNING\] (.*)",,,,\1]

Send events

```ps1
Add-Content -Path "C:\appl\logs\application.log" -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [WARNING] Warning Application has crashed due to 17" -Encoding utf8
Add-Content -Path "C:\appl\logs\application.log" -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [WARNING] Your Application has crashed due to 17" -Encoding utf8
Add-Content -Path "C:\appl\logs\application.log" -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [INFO] Quick log entry 24" -Encoding utf8
```

View result


![log level](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/log_level.png)


To get the full string with warning also

Item name

* Application Log Warning level appended

Item Key

* log["C:\\appl\\logs\\application.log","(\[WARNING\] .*)",,,,\1]

Result after running powershell


![log append](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/log_apppend.png)

### Eventlog

Just like standard text files monitored via log and logrt, monitoring the Windows Event Log requires that the item type be set explicitly to Zabbix agent (active)

Instead of log or logrt, Windows nodes use a dedicated item key called eventlog.

https://www.zabbix.com/documentation/3.4/en/manual/config/items/itemtypes/zabbix_agent/win_keys?hl=eventlog


Step-by-Step Implementation

Navigate to Data collection ➔ Hosts (or edit your Windows master template).  

Click Items ➔ 

Create item.Configure the following fields:

* Name: Windows Security Log: Failed LogonsType: 
* Select Zabbix agent (active).
* Key: eventlog[Security,,,,4625,,skip]
* Type of information: 
* Change this drop-down menu to Log.  
* Click Add.


![event item](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/event_item.png)

Test failed logon


Step 1: Verify Windows Logon Auditing is Enabled

Log into your target Windows VM via your remote access gateway.

Open PowerShell as an Administrator and check the current subcategory status:


```ps1

auditpol /get /subcategory:"Logon"

# System audit policy
# Category/Subcategory                      Setting
# Logon/Logoff
# Logon                                   Success and Failure

```

Look closely at the output. It must read Success and Failure or Failure.

Step 2: Trigger a Simulated Failed Logon Attempt

```cmd
runas /user:ZabbixTestAccount cmd.exe
```

Step 3: Verify the Results in Zabbix


![failed](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/failed.png)

View it in zabbix

![failed item](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/failed_item.png)

#### Eventlog Stream All System Warnings and Errors, Track Active Directory Service Outages

Monitors the overall System logs, automatically filtering out thousands of daily noisy Information alerts while forwarding critical system/hardware warnings and application crashes.

* eventlog[Application,,"Warning|Error",,,,skip]
* eventlog[System,,"Warning|Error",,,,skip]

Listens specifically to the Application log for any event explicitly thrown by the "Group Policy" system flagged with an Error state.

* eventlog[Application,"Group Policy",Error,,,,skip]


Test it

```ps1
Write-EventLog -LogName System -Source "EventLog" -EntryType Warning -EventId 9998 -Message "Zabbix Active Agent Test: Simulated System Warning payload."

Write-EventLog -LogName Application -Source "Application" -EntryType Error -EventId 9997 -Message "Group Policy processing failed. Simulated Zabbix Active Agent payload."
```


![event system 2](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/event_system2.png)


Trigger example

* count(/Lima eventlogs/eventlog[Application,,"Warning|Error",,,,skip],10m,"regexp","Aspen")>0

Recovery expression

* nodata(/Lima eventlogs/eventlog[Application,,"Warning|Error",,,,skip],10m)=1


![event trigger](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/event_trigger.png)

Example of other data collected

![event other](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/event_other.png)

## Zabbix Linux by Zabbix agent active

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
# it was added after dpkg
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

### User parameters linux native

Make custom template with 10 items

https://www.zabbix.com/documentation/8.0/en/manual/config/items/userparameters


### Log monitor linux

## Zabbix Linux by SNMP

Yes, that is a pull-based monitoring method. In this configuration, Zabbix acts as the active collector, and the Linux server acts as the passive agent.

Monitoring Linux via SNMP in Zabbix is achieved by installing snmpd, configuring community strings (v2c) or authentication (v3), and linking the "Linux by SNMP" template. This template discovers file systems, network interfaces, and CPU metrics via UDP port 161, with Zabbix integrations providing pre-configured monitoring

Active Monitoring Note: While SNMP is primarily a polling (passive) protocol, Zabbix handles the metrics efficiently. If you require true "active" agent functionality (where the agent sends data to the server), ***it is recommended to use the "Linux by Zabbix agent active" template instead of SNMP***

### Install

Tested versions

This template has been tested on:
* Linux OS

Configuration
* Zabbix should be configured according to the instructions in the Templates out of the box section.

Setup
* Install snmpd agent on Linux OS, enable SNMPv2.

Clarification
* snmpd.conf: Configures how the server responds to queries.

* snmp.conf: Configures how the tools (like snmpwalk or the agent itself) load MIB files.

```bash
ssh imsdal@172.16.0.6

# we added the procy for wingate also
# nc -zv 192.168.3.7 3128

# so we can apt 
sudo apt update
sudo apt upgrade

# Step 1: Install SNMP Tools
# Update repositories and install the SNMP daemon
# Else get .deb and use -i dpkg
sudo apt update
sudo apt install snmpd snmp -y

# Ubuntu does not include non-free MIBs by default. Run these commands to download them:

# Install the downloader tool
sudo apt update
sudo apt install snmp-mibs-downloader -y

# Download the MIBs
sudo download-mibs

# Check the client config file
sudo grep "mibs" /etc/snmp/snmp.conf
# If you see mibs :, you need to comment it out

# Step 2: Configure snmpd.conf

# Backup the original config
sudo cp /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.bak

# Edit the configuration
sudo nano /etc/snmp/snmpd.conf

```
snmpd.conf

```txt
###########################################################################
# SECTION: System Information Setup
###########################################################################
sysLocation    "Azure VM - vmsnmp03"
sysContact     "Admin <admin@example.org>"
sysServices    72

###########################################################################
# SECTION: Agent Operating Mode
###########################################################################
master  agentx

# Listen on all interfaces (required for Azure connectivity)
agentAddress udp:161,udp6:[::1]:161

###########################################################################
# SECTION: Access Control Setup
###########################################################################

# Create a 'full' view so Zabbix can see CPU, RAM, and Disk metrics
# The .1 OID represents the root of the entire tree
view    allview    included   .1

# 1. Update the community string to allow access to the 'allview'
# 2. Ensure 172.16.0.4 is your Zabbix Server/Proxy IP
rocommunity public 172.16.0.4 -V allview

# ADD THIS: Allow the local machine for testing
rocommunity public 127.0.0.1 -V allview

###########################################################################
# SECTION: Disk and Resource Monitoring
# Required for Zabbix Low-Level Discovery (LLD)
###########################################################################

# This tells the agent to report all mounted partitions
includeAllDisks 10%

# Monitor specific load average thresholds (Optional but good for SNMP health)
load 12 10 5

###########################################################################
# SECTION: Directory Inclusion
###########################################################################
# This line is correct and allows you to add modular configs
includeDir /etc/snmp/snmpd.conf.d
```

Before restart

```bash
# sudo systemctl stop snmpd
# sudo pkill -9 snmpd

sudo service snmpd restart
sudo ss -lunu | grep 161

# Before restarting, you can verify if the agent accepts the configuration:
sudo snmpd -f -Lo -C -c /etc/snmp/snmpd.conf
# Turning on AgentX master support.
# NET-SNMP version 5.9.4.pre2

snmpwalk -v 2c -c public localhost .1.3.6.1.4.1.2021

# Access Control: Your allview configuration is working because you can see objects under the .1.3.6.1.4.1.2021 OID (which the default "systemonly" view would block)

sudo systemctl enable snmpd

sudo systemctl status snmpd
```

### Remote Verification (Zabbix Server)

The final step in the code development flow is to ensure the Zabbix Server (172.16.0.4) can pull the same data.

```bash

sudo apt update

sudo apt upgrade

sudo apt install snmp
# Replace <VM_IP> with the private IP of vmsnmp03
snmpwalk -v 2c -c public 172.16.0.6 .1.3.6.1.4.1.2021.4.5.0
# iso.3.6.1.4.1.2021.4.5.0 = INTEGER: 3954964
```

Zabbix Web UI Configuration

1. Host Interface: Ensure the SNMP interface is set to 172.16.0.6 (or the correct private IP).

2. Template: Link the "Linux by SNMP" template.

3. Macros: Ensure {$SNMP_COMMUNITY} is set to public


![green vmsnmp03](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/vmsnmp03.png)
https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/os/linux_snmp_snmp

Data

![ vmsnmp03 data](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/vmsnmp03_data.png)


https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/os/linux_snmp_snmp


## Simulate SNMP Trap Generator

Since Zabbix requires a receiver to handle traps, you can set up a "Dummy Agent" on a cheap Linux VM to fire off traps whenever you want to test your Zabbix server's reaction.

The Architecture

To test this, you need two components in your Azure VNet:

* The Receiver (Zabbix Server): Your existing Zabbix VM (172.16.0.4).
* The Sender (The "Trap Generator"): A new, tiny Linux VM (e.g., vm-trap-sender).

We are using Linux by Zabbix agent active on vmchaos03:

Active Monitoring Note: While SNMP is primarily a polling (passive) protocol, Zabbix handles the metrics efficiently. If you require true "active" agent functionality (where the agent sends data to the server), ***it is recommended to use the "Linux by Zabbix agent active" template instead of SNMP***

![ vmchaos03](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/vmchaos03.png)



So now we have the following:

* vmzabbix03, Linux by Zabbix agent, MySQL by Zabbix agent 2, Zabbix server health
* vmchaos03,  Linux by Zabbix agent active
* vmhybrid01, Windows by Zabbix agent active
* vmsnmp03, Linux by SNMP

![ total](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/total.png)


Zabbix

![ zabbix](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/zabbix.png)

## References User parameter and log monitor

5 User parameters
* https://www.zabbix.com/documentation/7.0/en/manual/config/items/userparameters


6 Log file monitoring
* https://www.zabbix.com/documentation/7.0/en/manual/config/items/itemtypes/log_items

## All Templates

All templates

* https://www.zabbix.com/integrations


https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/os/windows_agent_active

https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/os/linux_active

https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/os/linux_snmp_snmp

https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/net/fortinet/fortigate_snmp?at=release/6.4

![all templates](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/templates.png)


# AI 20h course


Table of Contents

🔹 The 80/20 Pareto Strategy for Zabbix Agent 2

🔹 Phase 1: Native Plugin Foundations & Session Keys (Hours 1–5)

🔹 Phase 2: OS-Level Mastery Without Scripts (Hours 6–10)

🔹 Phase 3: Middleware & App Ingestion (Hours 11–15)

🔹 Phase 4: Low-Level Network, TLS, & Enterprise Scaling (Hours 16–20)



By mastering how Agent 2 natively packages data into JSON and how the Zabbix Server parses it via preprocessing, you completely eliminate the need for custom Bash or PowerShell wrappers.


## Phase 1: Native Plugin Foundations & Session Keys (Hours 1–5)

### Hour 1: Agent 2 Architecture & Go Runtime Mechanics


# Zabbix Script Action


This keeps your Level 3 firewall rules unidirectional (outbound only).

You have two primary ways to achieve this:

Zabbix Media Type / Script Action (Real-time): Zabbix fires a script the exact millisecond a problem occurs and passes the details directly to the external server.

External API Polling Script (Scheduled/Cron): A localized script runs on a schedule via cron, queries the Zabbix API locally, and forwards the payload.


### Method 1: Zabbix Script Action (Recommended)

This is the most efficient method because it doesn't require a continuous cron job loop. Zabbix pushes the data natively when an alert triggers.

Go to Alerts ➔ Media types ➔ Create media type.

Set Type to Script.

Name the script (e.g., forward_alert.sh).

Pass the necessary Zabbix macros as parameters:

{ALERT.SUBJECT}

{ALERT.MESSAGE}

Create a global Trigger action that executes this media type whenever a new problem is created.
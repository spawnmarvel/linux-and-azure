# Upgrade Zabbix Major

## Take a snapshot of the vm in Azure

Create a snapshot of a virtual hard disk

https://learn.microsoft.com/en-us/azure/virtual-machines/snapshot-copy-managed-disk?tabs=portal

* Go to VM-> Disk -> Create snapshot
* Source: vmzabbix02_OsDisk_1_fb136fc8afab4ba894f606f01600d7ec
* Name: zabbix.6.0.41
* VM: Linux (ubuntu 24.04)

To recover using a snapshot, you must create a new disk from the snapshot, then either deploy a new VM, and use the managed disk as the OS disk, or attach the disk as a data disk to an existing VM.


Create a VM from a specialized disk using PowerShell

https://learn.microsoft.com/en-us/azure/virtual-machines/attach-os-disk?tabs=portal

## Upgrade procedure

* Minimum required PHP version upped from 7.2.5 to 7.4.0.

Checked:

php --version
* PHP 8.3.6 (cli) (built: Jul 14 2025 18:30:55) (NTS)

mysql --version
* mysql  Ver 8.0.43-0ubuntu0.24.04.2 for Linux on x86_64 ((Ubuntu))

https://www.zabbix.com/documentation/current/en/manual/installation/upgrade

## Upgrade

Check mysql

```sql
-- sudo mysql

SELECT User, Host FROM mysql.user;

```
### 1 Stop Zabbix processes

```bash
sudo service zabbix-server stop
```

Have two ssh sessions open so you can view logs also

If upgrading Zabbix proxy, agent, or agent 2, stop these components too:

```bash
sudo service zabbix-agent stop
```
### 2 Back up Zabbix database

We took a snapshot of the disk

### 3 Back up Zabbix configuration files, PHP files, and Zabbix binaries


Back up existing Zabbix configuration files, PHP files, and Zabbix binaries.

```bash
# For configuration files, run:

sudo mkdir /opt/zabbix-backup/
sudo cp /etc/zabbix/zabbix_server.conf /opt/zabbix-backup/
sudo cp /etc/apache2/conf-enabled/zabbix.conf /opt/zabbix-backup/
sudo cp /etc/apache2/sites-enabled/default-ssl.conf /opt/zabbix-backup/

# For PHP files and Zabbix binaries, run:
sudo cp -R /usr/share/zabbix/ /opt/zabbix-backup/
sudo cp -R /usr/share/zabbix-* /opt/zabbix-backup/


cd /opt/zabbix-backup
ls
default-ssl.conf  zabbix  zabbix-sql-scripts  zabbix.conf  zabbix_server.conf
```

### 4 Update repository configuration package

Before proceeding with the upgrade, uninstall your current Zabbix repository package:

```bash
sudo rm -Rf /etc/apt/sources.list.d/zabbix.list
```

You may also need to manually remove any old Zabbix packages from your working directory (e.g., rm zabbix-release_latest+debian12_all.deb) before downloading the new one to prevent the package manager from reusing an outdated version during the upgrade process.

```bash
pwd
/home/imsdal

ls
# [...]
rm zabbix-release_latest+ubuntu24.04_all.deb

```

On Ubuntu 24.04, run:

It had a different version for OS, I went to officila zabbiz to get for 24.04 and v 7 LTS

https://www.zabbix.com/download?zabbix=7.0&os_distribution=ubuntu&os_version=24.04&components=server_frontend_agent&db=mysql&ws=apache

```bash
sudo wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu24.04_all.deb
sudo dpkg -i zabbix-release_latest_7.0+ubuntu24.04_all.deb

# You may see a prompt about the Zabbix repository configuration:
# Configuration file '/etc/apt/sources.list.d/zabbix.list'
# [...]
# Enter Y (or I) to install the package maintainer's version of the Zabbix repository configuration.
Y

# Then, update the repository information:
sudo apt update
```

### 5 Upgrade Zabbix components

```bash
sudo apt install --only-upgrade zabbix-server-mysql zabbix-frontend-php zabbix-agent

# You may see a prompt about the Zabbix server (or proxy) configuration:
# Configuration file '/etc/zabbix/zabbix_agent2.conf'
# Enter the option that best fits your situation. For example, enter D to compare the current and new configuration
# Then decide if you want to install the package maintainer's version (Y or I).
D
# After compare press
Q

# Y or I  : install the package maintainer's version
Y

# Configuration file '/etc/zabbix/zabbix_agentd.conf'
# Y or I  : install the package maintainer's version
Y

# Configuration file '/etc/zabbix/zabbix_server.conf'
# N or O  : keep your currently-installed version
N

```
Then, to upgrade Zabbix frontend with Apache and restart Apache, run:

```bash
sudo apt install zabbix-apache-conf
systemctl restart apache2

```
### 6 Review component configuration parameters

Skip for now, this is just a test

### 7 Start Zabbix processes

```bash
sudo service zabbix-server start
sudo service zabbix-agent start
sudo service zabbix-agent2 start
```
Tail zabbix server logs

```log
6692:20250925:200514.501 database upgrade failed on patch 06010049, exiting in 10 seconds
  6692:20250925:200524.501 Zabbix Server stopped. Zabbix 7.0.18 (revision 8b4aa26fa68).
  6728:20250925:200534.729 Starting Zabbix Server. Zabbix 7.0.18 (revision 8b4aa26fa68).
  6728:20250925:200534.729 ****** Enabled features ******
  6728:20250925:200534.729 SNMP monitoring:           YES
  6728:20250925:200534.729 IPMI monitoring:           YES
  6728:20250925:200534.729 Web monitoring:            YES
  6728:20250925:200534.729 VMware monitoring:         YES
  6728:20250925:200534.729 SMTP authentication:       YES
  6728:20250925:200534.729 ODBC:                      YES
  6728:20250925:200534.729 SSH support:               YES
  6728:20250925:200534.729 IPv6 support:              YES
  6728:20250925:200534.729 TLS support:               YES
  6728:20250925:200534.729 ******************************
  6728:20250925:200534.729 using configuration file: /etc/zabbix/zabbix_server.conf
  6728:20250925:200534.745 current database version (mandatory/optional): 06010048/06010048
  6728:20250925:200534.745 required mandatory version: 07000000
  6728:20250925:200534.745 mandatory patches were found
  6728:20250925:200534.747 starting automatic database upgrade
  6728:20250925:200534.747 [Z3005] query failed: [1419] You do not have the SUPER privilege and binary logging is enabled (you *might* want to use the less safe log_bin_trust_function_creators variable) [create trigger hosts_insert after insert on hosts
for each row
insert into changelog (object,objectid,operation,clock)
values (1,new.hostid,1,unix_timestamp())]
  6728:20250925:200534.747 database upgrade failed on patch 06010049, exiting in 10 seconds
```

Frontend

```log
The Zabbix database version does not match current requirements. Your database version: 6010048. Required version: 7000000. Please contact your system administrator.
```

On MySQL and MariaDB, this requires GLOBAL log_bin_trust_function_creators = 1 to be set if binary logging is enabled and there is no superuser privileges and log_bin_trust_function_creators = 1 is not set in MySQL configuration file. To set the variable using MySQL console, run:

```sql
mysql> SET GLOBAL log_bin_trust_function_creators = 1;
-- Query OK, 0 rows affected, 1 warning (0.00 sec)
```

Once the upgrade has been successfully completed, log_bin_trust_function_creators can be disabled:

```sql
SET GLOBAL log_bin_trust_function_creators = 0;
```
https://www.zabbix.com/documentation/6.0/en/manual/installation/upgrade_notes_6011

Check Zabbix logs

```log
 6946:20250925:200756.501 database upgrade failed on patch 06010049, exiting in 10 seconds
  6946:20250925:200806.501 Zabbix Server stopped. Zabbix 7.0.18 (revision 8b4aa26fa68).
  6983:20250925:200816.731 Starting Zabbix Server. Zabbix 7.0.18 (revision 8b4aa26fa68).
  6983:20250925:200816.731 ****** Enabled features ******
  6983:20250925:200816.731 SNMP monitoring:           YES
  6983:20250925:200816.731 IPMI monitoring:           YES
  6983:20250925:200816.731 Web monitoring:            YES
  6983:20250925:200816.731 VMware monitoring:         YES
  6983:20250925:200816.731 SMTP authentication:       YES
  6983:20250925:200816.731 ODBC:                      YES
  6983:20250925:200816.731 SSH support:               YES
  6983:20250925:200816.731 IPv6 support:              YES
  6983:20250925:200816.731 TLS support:               YES
  6983:20250925:200816.731 ******************************
  6983:20250925:200816.731 using configuration file: /etc/zabbix/zabbix_server.conf
  6983:20250925:200816.748 current database version (mandatory/optional): 06010048/06010048
  6983:20250925:200816.748 required mandatory version: 07000000
  6983:20250925:200816.748 mandatory patches were found
  6983:20250925:200816.750 starting automatic database upgrade
  6983:20250925:200816.787 completed 0% of database upgrade
  6983:20250925:200816.999 completed 1% of database upgrade
  6983:20250925:200817.252 completed 2% of database upgrade
  6983:20250925:200817.468 completed 3% of database upgrade
  6983:20250925:200817.870 completed 4% of database upgrade
  6983:20250925:200821.135 completed 5% of database upgrade
  6983:20250925:200828.898 completed 6% of database upgrade
  6983:20250925:200831.709 completed 7% of database upgrade
```

After some minuttes

```log
[...]
6983:20250925:200950.373 completed 97% of database upgrade
6983:20250925:200950.469 completed 98% of database upgrade
6983:20250925:200950.835 completed 99% of database upgrade
6983:20250925:200950.992 completed 100% of database upgrade
6983:20250925:200951.282 database upgrade fully completed
7460:20250925:200951.452 starting HA manager
7460:20250925:200951.492 HA manager started in active mode
6983:20250925:200951.494 server #0 started [main process]

```

Once the upgrade has been successfully completed, log_bin_trust_function_creators can be disabled:

```sql
SET GLOBAL log_bin_trust_function_creators = 0;
```

Check zabbix server logs

```logs

```

```bash
sudo service zabbix sever stop
```

Check zabbix server logs again

```log
6983:20250925:201346.893 Zabbix Server stopped. Zabbix 7.0.18 (revision 8b4aa26fa68).
7988:20250925:201346.923 Starting Zabbix Server. Zabbix 7.0.18 (revision 8b4aa26fa68).
7988:20250925:201346.923 ****** Enabled features ******
7988:20250925:201346.923 SNMP monitoring:           YES
7988:20250925:201346.923 IPMI monitoring:           YES
7988:20250925:201346.923 Web monitoring:            YES
7988:20250925:201346.923 VMware monitoring:         YES
7988:20250925:201346.923 SMTP authentication:       YES
7988:20250925:201346.923 ODBC:                      YES
7988:20250925:201346.923 SSH support:               YES
7988:20250925:201346.923 IPv6 support:              YES
7988:20250925:201346.923 TLS support:               YES
7988:20250925:201346.923 ******************************
7988:20250925:201346.923 using configuration file: /etc/zabbix/zabbix_server.conf
7988:20250925:201346.938 current database version (mandatory/optional): 07000000/07000020
7988:20250925:201346.938 required mandatory version: 07000000
7989:20250925:201346.942 starting HA manager
```

Check frontend,  and we have version 7.0.18

![zabbix 2](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/zabbix7.png)

Check the all alerts are gone after some minuttes.

They are, but we have one alert for the zabbix server itself

![agent 7](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/agent_7.png)

But we still had values, hm....

```bash

sudo tail -f zabbix_agentd.log
```
```log

6379:20250925:201838.281 failed to accept an incoming connection: connection from "192.168.3.5" rejected, allowed hosts: "127.0.0.1"
```
That was because we said N to keep the configuration, we must compare and edit it.

```bash
sudo systemctl stop zabbix-agent
```
```log

6382:20250925:203038.280 failed to accept an incoming connection: connection from "192.168.3.5" rejected, allowed hosts: "127.0.0.1"
6375:20250925:203046.948 Got signal [signal:15(SIGTERM),sender_pid:9928,sender_uid:114,reason:0]. Exiting ...
6375:20250925:203046.953 Zabbix Agent stopped. Zabbix 7.0.18 (revision 8b4aa26fa68)
```
Ok so we are using agent, not agent2, we can remove that after.

Lets edit the config

```bash
sudo nano zabbix_agentd.conf

# We added ip
grep 'Server*' zabbix_agentd.conf
# Server=127.0.0.1,192.168.3.5
# ServerActive=192.168.3.5

sudo systemctl start zabbix-agent
```

Zabbix agent logs are ok and the alert is gone

```log
11550:20250925:204120.052 Starting Zabbix Agent [Zabbix server]. Zabbix 7.0.18 (revision 8b4aa26fa68).
11550:20250925:204120.052 **** Enabled features ****
11550:20250925:204120.052 IPv6 support:          YES
11550:20250925:204120.052 TLS support:           YES
11550:20250925:204120.052 **************************
11550:20250925:204120.052 using configuration file: /etc/zabbix/zabbix_agentd.conf
11550:20250925:204120.053 agent #0 started [main process]
11551:20250925:204120.054 agent #1 started [collector]
11552:20250925:204120.054 agent #2 started [listener #1]
11553:20250925:204120.055 agent #3 started [listener #2]
```

But a new one came:

MySQL: Version has changed (new version value received: mysqladmin: [ERROR] Unknown suffix 'z' used for variable 'port' (value 'zbx_monitor'). mysqladmin: [ERROR] mysqladmin: Error while setting value 'zbx_monitor' to 'port'.)

![mysql error](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/mysql_error.png)



https://www.zabbix.com/documentation/current/en/manual/installation/upgrade/packages/debian_ubuntu
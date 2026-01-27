# Major version upgrade in Azure Database for MySQL

https://learn.microsoft.com/en-us/azure/mysql/flexible-server/how-to-upgrade

## Environment Rg-neazmysql-0001

![env](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/up_env.png)

Your server version will lose standard Azure support on May 31,2026, Upgrade to latest version to avoid extended support charges starting June 1, 2026.

Azure Database for MySQL flexible server

* Burstable, B1ms, 1 vCores, 2 GiB RAM, 20 storage, 360 IOPS
* 

## Install zabbix 6.0 LTS


https://www.zabbix.com/download?zabbix=6.0&os_distribution=ubuntu&os_version=24.04&components=server_frontend_agent&db=mysql&ws=apache

```bash
sudo apt update -y

sudo apt upgrade -y

sudo wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_6.0+ubuntu24.04_all.deb

sudo dpkg -i zabbix-release_latest_6.0+ubuntu24.04_all.deb

sudo apt update -y

sudo apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent


```
Create initial db (connnect to azure mysql as root or admin)

```bash
mysql -h name.mysql.database.azure.com -u imsdal --password=xxxx

```
```sql
create database zabbix character set utf8mb4 collate utf8mb4_bin;

create user zabbix@'%' identified by 'xxxxxxxxx';

grant all privileges on zabbix.* to zabbix@'%';

set global log_bin_trust_function_creators = 1;
-- ERROR 1227 (42000): Access denied; you need (at least one of) the SUPER or SYSTEM_VARIABLES_ADMIN privilege(s) for this operation

quit;
```

But this is on by default in azure mysql

![bin_trust](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/bin_trust.png)


```bash
# zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix

zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -u zabbix -h mysqlzabbix0101.mysql.database.azure.com -P 3306 --password=xxxxx Zabbix

# when this is done
```
count tables

```sql
SELECT COUNT(*) AS total_tables 
FROM information_schema.tables 
WHERE table_schema = 'zabbix';

-- total tables
-- 173

-- we should normally set this, but it is default on in azure mysql so we skip ti
set global log_bin_trust_function_creators = 0;
quit;
```
configure zabbix server

```bash
cd /etc/zabbix

sudo nano zabbix_server.conf

# DBPassword=password
# DBHost=host


```
Restart and enable at boot

```bash
sudo systemctl restart zabbix-server
sudo systemctl restart zabbix-agent
sudo systemctl restart apache2

sudo systemctl enable zabbix-server
sudo systemctl enable zabbix-agent
sudo systemctl enable apache2

# check it
sudo systemctl is-enabled zabbix-server.service
sudo systemctl is-enabled zabbix-agent.service
sudo systemctl is-enabled apache

```

Open nsg and visit

http://ip/zabbix

![done flex](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/done_flex.png)


Verify frontend after login.

![zabbix flex](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/zabbix_flex.png)


```bash
# get db password

sudo grep 'DBPass*' /etc/zabbix/zabbix_server.conf
```

## Upgrade MySql checklist

```bash
zabbix_server --version
zabbix_server (Zabbix) 6.0.43

```
verify zabbix requirements

mysql v for zabbix 6

```log
Added support for MySQL versions:
- 8.1 since Zabbix 6.0.21;
- 8.2 since Zabbix 6.0.26;
- 8.3 since Zabbix 6.0.27;
- 8.4 since Zabbix 6.0.32;
- 9.0 since Zabbix 6.0.33;
- 9.5 since Zabbix 6.0.43.
```

https://www.zabbix.com/documentation/6.0/en/manual/installation/requirements


### Major version upgrade in Azure Database for MySQL checklist

* Upgrading the major MySQL version is irreversible.
* MySQL driversmight encounter connection failures after the upgrade due to unsupported authentication methods, character sets, or protocol changes. 

Since you are running Zabbix 6.0.43, you are well within the supported range for MySQL 8.4 (which was introduced back in 6.0.32).

```sql
select user, host, plugin from mysql.user

-- zabbix	%	mysql_native_password

```

Lets connect from zabbix to mysql to verify password

```bash
mysql -h name.mysql.database.azure.com -u zabbix --password=xxxxxxxxx

```

show databases

```sql
-- show databases
show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| performance_schema |
| zabbix             |
+--------------------+
3 rows in set (0.01 sec)

-- count tables in zabbix
SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'zabbix';
+----------+
| COUNT(*) |
+----------+
|      173 |
+----------+
1 row in set (0.01 sec)
```

1. The Authentication Plugin (Crucial)

* The Change: Starting with MySQL 8.4, the mysql_native_password authentication plugin is deprecated and disabled by default, though it has not been fully removed yet. MySQL 8.0 uses caching_sha2_password as the default, but many older migrations kept the native password for compatibility.

* The Fix: You have two choices:

- 1. Server-side: Ensure the Azure Flexible Server parameter mysql_native_password is set to ON (if Azure provides this toggle in the 8.4 preview/release) to allow the legacy plugin.

- 2. Best Practice: Convert the Zabbix user to the newer plugin before or during the upgrade: ALTER USER 'zabbix'@'%' IDENTIFIED WITH caching_sha2_password BY 'your_password';

In this version, it is test /dev, the native is none editable.

![native no mod](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/native_no_mod.png)


2. Upgrade Strategy for Azure Flexible Server
Since your database size is tiny (6.12 MB), the actual data migration will be near-instant.

3. Pre-Upgrade Checklist

- 1. Manual Backup: Even though Azure takes automated backups, trigger a manual snapshot before starting.

- 2. Zabbix Maintenance: Stop the zabbix-server service on your Ubuntu box before the upgrade to prevent the logs from filling up with connection errors.

- 3. Check Deprecated Features: MySQL 8.4 removed several legacy variables. Check your Server Parameters in the Azure portal to ensure you aren't using custom flags that are no longer supported in 8.4.

4. Recommended Workflow

- 1. Stop Zabbix: sudo systemctl stop zabbix-server

- 2. Change Auth (Optional but recommended): Update the Zabbix user to caching_sha2_password.

- 3. Perform Upgrade: Initiate the Major Version Upgrade to 8.4 via the Azure Portal.

- 4. Verify Connection: Once Azure shows "Available," try connecting manually from your Ubuntu CLI: mysql -h your-server.mysql.database.azure.com -u zabbix -p

- 5.Restart Zabbix: sudo systemctl start zabbix-server

- 6. Monitor Logs: Check /var/log/zabbix/zabbix_server.log for any "unsupported DB version" errors (though with 6.0.43, you should be fine).

lets convert the user

```bash
#  log in as super user
mysql -h name.mysql.database.azure.com -u superuser --password='xxxxxxxx'

```

edit user

```sql
-- get user before
select user, host, plugin from mysql.user where user = 'zabbix';
+--------+------+-----------------------+
| user   | host | plugin                |
+--------+------+-----------------------+
| zabbix | %    | mysql_native_password |
+--------+------+-----------------------+
1 row in set (0.00 sec)

-- That is the most seamless way to do it. 
-- Keeping the same password while switching the plugin to caching_sha2_password ensures that your 
-- zabbix_server.conf file doesn't need any manual edits—it will just "work" as long as the handshake succeeds.

ALTER USER 'zabbix'@'%' IDENTIFIED WITH caching_sha2_password BY 'your_existing_password';

-- after flush
FLUSH PRIVILEGES;

-- get user
select user, host, plugin from mysql.user where user = 'zabbix';
+--------+------+-----------------------+
| user   | host | plugin                |
+--------+------+-----------------------+
| zabbix | %    | caching_sha2_password |
+--------+------+-----------------------+
1 row in set (0.00 sec)

```

One quick verification for Ubuntu
After you run the ALTER command, but before you trigger the Azure upgrade, verify that your Ubuntu Zabbix node can still talk to the 8.0 DB.

```bash
sudo systemctl restart zabbix-server

sudo systemctl status zabbix-server.service
#  Active: active (running) since Tue 2026-01-27 19:48:32 UTC; 24s ago

sudo grep "database network restore" /var/log/zabbix/zabbix_server.log | tail -n 5

```

still running

![still running](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/still_running.png)


stop zabbix

```bash
sudo systemctl stop zabbix-server
sudo systemctl status zabbix-server.servic
#  Active: inactive (dead) since Tue 2026-01-27 19:52:27 UTC; 3s ago
```

Trigger Azure Upgrade: In the Azure Portal, navigate to Upgrade under the settings of your Flexible Server and select 8.4.

![upgrade](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/upgrade.png)


Information

![information](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/information.png)

```log

Current MySQL version : 8.0
Target Server Version : 8.4
Current Compute Tier : Standard_B1ms
Target Compute Tier(Major version upgrade only) : Standard_D2ds_v4
Upgrade Success Behavior : Rollback to previous compute tier

```

Deployment is in progress, Once the Status changes to "Available".

Your deployment is complete

![8_4](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/8_4.png)


```bash

#  log in as super user
mysql -h name.mysql.database.azure.com -u superuser --password='xxxxxxxx'

Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 126
Server version: 8.4.5-azure Source distribution

# login as zabbix
mysql -h name.mysql.database.azure.com -u zabbix --password=xxxxxxxxx

Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 129
Server version: 8.4.5-azure Source distribution

# You can use the mysqlcheck utility directly from your Ubuntu terminal. 
# This is the fastest way to scan every table in the Zabbix database for errors.
mysqlcheck -h name.mysql.database.azure.com -u zabbix -p --databases Zabbix --password=xxxxxx

```
* Expected Output: Every table (e.g., history, trends, hosts) should show OK.

* What it does: It runs the CHECK TABLE command on every single table in your schema.

```log
zabbix.acknowledges                                OK
zabbix.actions                                     OK
zabbix.alerts                                      OK
zabbix.auditlog                                    OK
zabbix.autoreg_host                                OK
zabbix.conditions                                  OK
zabbix.config                                      OK
zabbix.config_autoreg_tls                          OK
zabbix.corr_condition                              OK
zabbix.corr_condition_group                        OK
zabbix.corr_condition_tag                          OK
[...]

```
sql check optional

```sql
SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'zabbix';
```

Start Zabbix server if success

```bash
sudo systemctl start zabbix-server

sudo tail -f /var/log/zabbix/zabbix_server.log

# What to watch for: Any "Unsupported DB version" warnings. Since you are on 6.0.43, you should see a message saying the version is supported.
sudo grep "Unsupported*" /var/log/zabbix/zabbix_server.log | tail -n 5

# to be absolutely certain that the connection is active and healthy, try running this to see the most recent "success" messages:
sudo grep -E 'current database version' /var/log/zabbix/zabbix_server.log | tail -n 3

1034:20260127:190732.174 current database version (mandatory/optional): 06000000/06000055
2662:20260127:194832.147 current database version (mandatory/optional): 06000000/06000055
# Looking at your log timestamp (20:41:43.94)
4912:20260127:204143.941 current database version (mandatory/optional): 06000000/06000055


# One final "Checkup"
# Since the server started at 20:41, you should now check if the Housekeeper has run its first cycle on the new version
sudo grep 'houskeeper' /var/log/zabbix/zabbix_server.log
# not run yet, let it run for 1h then check again.

```
Verify the Frontend if above success (zabbix v 7.0 and 6.4, not 6.0.x)

* Log into your Zabbix Web UI. Go to Reports -> System information.
* Check the Database status row. It should show OK and reflect the new MySQL 8.4 version.

Lets check the 6.0.43 frontend and verify

![verify zabbix](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/verify_zabbix.png)


https://learn.microsoft.com/en-us/azure/mysql/flexible-server/how-to-upgrade
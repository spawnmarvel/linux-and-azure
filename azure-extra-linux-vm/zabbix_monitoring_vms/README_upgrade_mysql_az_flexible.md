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


### Upgrade MySql checklist

https://learn.microsoft.com/en-us/azure/mysql/flexible-server/how-to-upgrade
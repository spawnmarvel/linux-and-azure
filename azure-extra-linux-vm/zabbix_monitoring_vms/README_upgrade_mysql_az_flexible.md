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

create user zabbix@'%' identified by 'password123';

grant all privileges on zabbix.* to zabbix@'%';

set global log_bin_trust_function_creators = 1;
-- ERROR 1227 (42000): Access denied; you need (at least one of) the SUPER or SYSTEM_VARIABLES_ADMIN privilege(s) for this operation
```

But this is on by default in azure mysql

![bin_trust](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/bin_trust.png)


## Upgrade MySql



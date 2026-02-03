## stack with proxy and differnt architectures

## architectures

Architecture:
- Singel vm database and zabbix, size small
- Two vm database and zabbix, size small, medium  or large
- Azure database and zabbix vm, size s, m or l
- Single vm and docker, s, m not l

Architecture  with proxy:

- Source zabbix on of the above, size l or m
- Replica proxy on site with linki to source, size s, l or m
- Could add grafana-zabbix plugin on the proxy
- Zabbix plugin for Grafana, https://grafana.com/grafana/plugins/alexanderzobnin-zabbix-app/

# How Does the Zabbix Proxy Roll Out Plan Work?

* Zabbix proxy is an optional, lightweight, server-side component that collects monitoring data (performance and availability) from devices on behalf of a main Zabbix server, reducing load and enabling distributed monitoring. It buffers data locally and transfers it to the central server, making it ideal for remote sites or networks with unreliable connections. 
* Proxies require a dedicated database (SQLite or MySQL/PostgreSQL) and, as of v7.0, support high-availability and load-balancing via proxy groups. 

Key Features and Benefits

* Reduced Server Load: Offloads the central server by handling data collection, reducing CPU and disk I/O usage.
* Remote/Distributed Monitoring: Ideal for monitoring networks behind firewalls or remote locations with low bandwidth.
* Data Buffering: Local storage prevents data loss during temporary network interruptions between the proxy and the server.
* High Availability (v7.0+): Proxy groups allow for automatic failover and load balancing, where hosts are redistributed if a proxy goes offline. 

Operational Details

* Requirements: A separate database (e.g., MySQL, PostgreSQL, SQLite for small, non-intensive setups).
* Configuration: The Hostname in the proxy config file must match the name defined in the Zabbix frontend.
* Active vs. Passive: Proxies can operate in active mode (pulling config from the server) or passive mode (waiting for the server to connect).
* Limitations: Proxies cannot perform actions (e.g., sending alerts) on their own, as all trigger logic is processed on the main server.

## Zabbix Proxy in "push only" mode

To set up a Zabbix Proxy in "push only" mode, you are looking for what Zabbix formally calls an Active Proxy. In this configuration, the proxy initiates all communication, "pushing" data to the Zabbix Server and "pulling" its own configuration from the server.

This is ideal for monitoring remote networks behind firewalls or NAT, as it requires zero open inbound ports on the proxy’s side.

1. Proxy Configuration (zabbix_proxy.conf)

On the proxy server, edit your configuration file (usually /etc/zabbix/zabbix_proxy.conf) with these key parameters:

 * ProxyMode=0: This is the critical setting. 0 sets the proxy to Active (push) mode.
 * Server=<Zabbix_Server_IP_or_FQDN>: The IP or address of your central Zabbix Server.
 * Hostname=<Proxy_Name>: This must exactly match the "Proxy name" you enter in the Zabbix Web UI.

2. Web Interface Configuration

You must register the proxy in the Zabbix frontend so the server knows to accept its data.

 * Go to Administration → Proxies (or Reports → Proxies in newer versions).
 * Click Create proxy.
 * Proxy name: Match the Hostname from your config file.
 * Proxy mode: Select Active.
 * (Optional) Proxy address: You can list the IP of the proxy here for extra security, but for a true "push" setup from a dynamic IP, you can leave this blank.

3. Communication Flow

In this mode, the port requirements are unidirectional:

 * Proxy → Server: The proxy connects to the server on port 10051.
 * Server → Proxy: No connection is made. The server remains passive and waits for the proxy to check in.

[!IMPORTANT]
Data Buffering: One of the biggest perks of this setup is that if the connection to the Zabbix Server drops, the proxy will store the collected data in its local database and "push" it all at once when the connection is restored.

## Install and configure zabbix proxy

Main zabbix, vmzabbix02, 192.168.3.5

* zabbix_server (Zabbix) 7.0.22, mysql  Ver 8.0.45-0ubuntu0.24.04.1 for Linux on x86_64

Proxy zabbix, vmchaos09, 192.168.3.4

* Here we will install proxy with same version as above and also mysql

Lets uninstall the zabbix agent on vmchao09 so we can configure it as a proxy

```bash
zabbix_agent2 --version
zabbix_agent2 (Zabbix) 7.0.22

sudo apt remove zabbix-agent2

cd /etc/zabbix
# remove zabbix agent conf
sudo rm zabbix_agent2.conf
# remove folder and recursivley
sudo rm -r zabbix_agent2.d/


cd /bin
# check if we have more files in bin
ls *zabbix*

# now go to home folder, where we ran weget to download zabbix agent files
ls
secure_mysql.sh  zabbix-release_latest_7.0+ubuntu24.04_all.deb
# remove the zabbix-release file also
sudo rm zabbix-release_latest_7.0+ubuntu24.04_all.deb
```
Now we are ready to install the proxy, we need the samme version as the agent, since that is the version main zabbix is running.

Go to zabbix download and select same version, linux distro and select proxy

https://www.zabbix.com/download?zabbix=7.0&os_distribution=ubuntu&os_version=24.04&components=proxy&db=mysql&ws=

```bash
sudo wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu24.04_all.deb

sudo dpkg -i zabbix-release_latest_7.0+ubuntu24.04_all.deb

# install proxy
sudo apt install zabbix-proxy-mysql zabbix-sql-scripts

# install mysql
sudo apt install mysql-server

mysql --version
# mysql  Ver 8.0.45-0ubuntu0.24.04.1 for Linux on x86_64 ((Ubuntu))

sudo systemctl start mysql
sudo systemctl status mysql
#  Active: active (running) since Tue 2026-02-03 20:55:03 UTC; 1min 31s ag

systemctl enable mysql
sudo mysql_secure_installation


# login mysql
sudo mysql
# Welcome to the MySQL monitor.  Commands end with ; or \g

```
Create initial database

```sql
create database zabbix_proxy character set utf8mb4 collate utf8mb4_bin;
create user 'zabbix'@'%' identified by 'password';
grant all privileges on zabbix_proxy.* to 'zabbix'@'%';
FLUSH PRIVILEGES;
set global log_bin_trust_function_creators = 1;
quit;

-- test login with user
mysql -u zabbix -p zabbix_proxy -h localhost

```
On Zabbix server host import initial schema and data. You will be prompted to enter your newly created password.

```bash
sudo cat /usr/share/zabbix-sql-scripts/mysql/proxy.sql | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix_proxy --password=password
# takes 1 to 3 min

sudo mysql
```

Check mysql and remove log bin

```sql
show databases;

use zabbix_proxy;

SELECT TABLE_NAME, TABLE_ROWS FROM information_schema.tables 
WHERE table_schema = 'zabbix_proxy';
-- 203 rows in set (1.74 sec)

set global log_bin_trust_function_creators = 0;
quit;
```

Configure the database for Zabbix proxy

```bash
cd /etx/zabbix
ls
# zabbix_proxy.conf  zabbix_proxy.d

sudo nano zabbix_proxy.con
# DBPassword=password
# ProxyMode=0: This is the critical setting. 0 sets the proxy to Active (push) mode.
# Server=192.168.3.5
# Hostname=zabbix_proxy

sudo grep 'DB*' zabbix_proxy.conf

sudo systemctl restart zabbix-proxy.service
sudo systemctl enable zabbix-proxy.service
sudo systemctl status zabbix-proxy.service
#  Active: active (running) since Tue 2026-02-03 21:23:03 UTC; 32s ag

```

Now go to docs for proxy on zabbix we need to configure it as active / push

```bash
# check logs
sudo tail -f /var/log/zabbix/zabbix_proxy.log

```

```log
6472:20260203:213157.621 thread started
6474:20260203:213157.623 thread started
6475:20260203:213157.623 proxy #30 started [snmp poller #1]
6475:20260203:213157.624 thread started
6477:20260203:213157.624 proxy #31 started [internal poller #1]
6424:20260203:213157.693 cannot send proxy data to server at "192.168.3.5": proxy "zabbix_proxy" not found
```

You must register the proxy in the Zabbix frontend so the server knows to accept its data.

 * Go to Administration → Proxies (or Reports → Proxies in newer versions).
 * Click Create proxy.
 * Proxy name: Match the Hostname from your config file.
 * Proxy mode: Select Active.
 * (Optional) Proxy address: You can list the IP of the proxy here for extra security, but for a true "push" setup from a dynamic IP, you can leave this blank.


![proxy success](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/proxy.png)

https://www.zabbix.com/documentation/7.0/en/manual/appendix/config/zabbix_proxy


## Get data from zabbix proxy


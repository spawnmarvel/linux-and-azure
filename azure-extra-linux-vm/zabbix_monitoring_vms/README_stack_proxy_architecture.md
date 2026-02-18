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

zabbix_proxy --version
# zabbix_proxy (Zabbix) 7.0.22

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
# Hostname=vmchaos09

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
6982:20260203:214342.990 cannot send proxy data to server at "192.168.3.5": proxy "vmchaos09" not found
  6982:20260203:214343.993 cannot send proxy data to server at "192.168.3.5": proxy "vmchaos09" not found
  6982:20260203:214344.997 cannot send proxy data to server at "192.168.3.5": proxy "vmchaos09" not found
```

You must register the proxy in the Zabbix frontend so the server knows to accept its data.

 * Go to Administration → Proxies (or Reports → Proxies in newer versions).
 * Click Create proxy.
 * Proxy name: Match the Hostname from your config file.
 * Proxy mode: Select Active.
 * (Optional) Proxy address: You can list the IP of the proxy here for extra security, but for a true "push" setup from a dynamic IP, you can leave this blank.


![proxy success](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/proxy2.png)


```bash
# check logs
sudo tail -f /var/log/zabbix/zabbix_proxy.log

```

```log
 6975:20260203:214352.837 received configuration data from server at "192.168.3.5", datalen 5474
```

https://www.zabbix.com/documentation/7.0/en/manual/appendix/config/zabbix_proxy

🔍 Verification Checklist

* Since this is an Active Proxy (ProxyMode=0), it should update every few seconds.
* Ensure the Proxy can write to its local DB. You can check for database-specific errors in the log:
```sql
sudo grep "database is down" /var/log/zabbix/zabbix_proxy.log
```

## Monitor the proxy's health right now without touching MySQL monitor

Create the Proxy Host

Go to Data collection → Hosts and click Create host.

![proxy monitor](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/proxy_monitor.png)

Once you hit Add, wait about 2–5 minutes. Then go to Monitoring → Latest data and filter by host vmchaos09. You want to keep an eye on these specific items:

* Zabbix proxy: Configuration cache, % used: If this hits 100%, the proxy can't load new host configurations.

* Zabbix proxy: History write cache, % used: If this is high, your proxy is collecting data faster than it can write to its local database.

* Zabbix proxy: Sending queue: This tells you if there is a backup of data waiting to be sent to your Main Zabbix server (vmzabbix02).

![proxy queue](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/proxy_queue.png)

## Configure the Agent on vmchaos09

```bash
sudo apt update
sudo apt install zabbix-agent2
```

Configure for Active Monitoring

```bash
sudo nano /etc/zabbix/zabbix_agent2.conf
# LogFileSize=100
# Server=127.0.0.1
# ServerActive=127.0.0.1
# Hostname=vmchaos09

sudo systemctl enable zabbix-agent2
sudo systemctl restart zabbix-agent2
```

Update host vmchaos09, add Ensure the template Linux by Zabbix agent active is linked.

![proxy template](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/proxy_template.png)

Check data.

Proxy performance

![proxy performance](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/proxy_performance.png)

Proxy agent

![proxy agent](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/proxy_agent.png)


## Adding a New Host via the Proxy

1. In the Web UI

- Go to Data collection → Hosts → Create host.

- Host name: (e.g., remote-vm-01).

- Templates: Link whatever you need (e.g., Linux by Zabbix agent).

- Monitored by proxy: Select vmchaos09.

- Interfaces: Add the Agent IP of that new machine (e.g., 192.168.3.10).

2. On the New Machine (The Target)

- In that machine's zabbix_agentd.conf, you must point it to the Proxy IP, not the Main Server:

- Server=192.168.3.4 (Your Proxy IP)

- ServerActive=192.168.3.4 (If using active checks)

## Set a "High Queue" Trigger (Optional but Recommended)

One of the most common issues with proxies is a "queue" backup. You might want to check the item: 

Zabbix proxy: Number of values waiting to be sent 

If this number stays high (in the thousands) and doesn't go down, it means the connection between 192.168.3.4 and 192.168.3.5 is too slow or the Main Server's database is struggling.

![proxy values](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/proxy_values.png)

## PSK (Pre-Shared Key) for encryption

Moving to SSL (TLS) encryption is a smart move, especially in Zabbix 7.0. It ensures that the data being pushed from your proxy (vmchaos09) to your main server (vmzabbix02) cannot be intercepted or spoofed.

Since you are using Active Proxy mode, we will use PSK (Pre-Shared Key). It is much simpler to manage than a full Certificate Authority (CA) setup but provides strong encryption

```bash
sudo mkdir -p /etc/zabbix/keys
openssl rand -hex 32 | sudo tee /etc/zabbix/keys/proxy.psk

```
Copy the output of the key (the long string of numbers and letters). You will need it for the Web UI.

Configure the Proxy for TLS
Edit the proxy configuration file on vmchaos09:
sudo nano /etc/zabbix/zabbix_proxy.conf

```ini
TLSConnect=psk
TLSPSKIdentity=PSK_PROXY_001
TLSPSKFile=/etc/zabbix/keys/proxy.psk
```

```bash
sudo systemctl restart zabbix-proxy.service
```


Go to Administration → Proxies.

Click on vmchaos09.

Set Connections to proxy to No encryption (since it's an Active proxy, the server doesn't "connect to" it)

![psk](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/psk.png)


Verify the Encrypted Tunnel
Check the Proxy logs on vmchaos09 to ensure the handshake is successful:

```bash
sudo tail -f /var/log/zabbix/zabbix_proxy.log
# 1742:20260218:111859.108 received configuration data from server at "192.168.3.5", datalen 29926

```

![psk ok](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/psk_ok.png)


## Prepare MySQL for Monitoring on proxy todo

```bash
sudo mysql
```

Once inside the MySQL prompt, run these commands:

```sql
CREATE USER 'zbx_monitor'@'%' IDENTIFIED BY 'your_secure_password';
GRANT REPLICATION CLIENT, PROCESS, SHOW DATABASES, SHOW VIEW ON *.* TO 'zbx_monitor'@'%';
FLUSH PRIVILEGES;
EXIT;
```

Configure the Zabbix Agent 2

Zabbix Agent 2 has a built-in MySQL plugin. You need to tell it how to log in

```bash
sudo nano /etc/zabbix/zabbix_agent2.d/plugins.d/mysql.conf

```
Add these lines (using the password you created in Step 1):

```ini
Plugins.Mysql.Sessions.Local.Uri=tcp://localhost:3306
Plugins.Mysql.Sessions.Local.User=zbx_monitor
Plugins.Mysql.Sessions.Local.Password=your_secure_password
```

```bash
sudo systemctl restart zabbix-agent2

```

Link the Template in Main Zabbix

- Click on vmchaos09.

- In the Templates tab, add: MySQL by Zabbix agent 2.

Note: Since your host is set up for "Active" monitoring, ensure you use the "Active" version of the template if available, or simply ensure the Agent 2 is configured to handle the plugin requests.

- Go to the Macros tab on the host and click Inherited and host macros.

- Find the macro {$MYSQL.DSN} and change its value to Local (this matches the session name we created in the config file).

🧪 Quick Test
To verify the agent can actually talk to MySQL before waiting for the UI, run this command on the proxy:

```bash


zabbix_agent2 -t mysql.ping[Local]
# If it returns [t|1], the connection is successful!
```

Critical metrics to watch:

* MySQL: Status: Is the database actually up?
* MySQL: Queries per second: Shows the load the proxy is putting on its DB.
* MySQL: Slow queries: If this increases, your proxy's disk I/O might be a bottleneck.
* MySQL: Buffer pool utilization: Tells you if you need to give MySQL more RAM.

# Test more templates and stuff

### Template Linux by Zabbix agent

The inital one that is running on vmdocker01

https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/README.md


### Template MySQL by Zabbix agent

Let s start monitor our MySQL database

Install Zabbix agent and MySql client, we already have that since we are on local host 

```bash
# check agent
zabbix_agent2 -V
zabbix_agent2 (Zabbix) 6.0.40

# check our mysql client
dpkg -l | grep mysql-client
```

1. Create the MySQL user that will be used for monitoring

```sql

-- login
sudo mysql -uroot -p

-- create a user for monitor
CREATE USER 'zbx_monitor'@'%' IDENTIFIED BY 'LudoBicEnhanced#7-';
GRANT REPLICATION CLIENT,PROCESS,SHOW DATABASES,SHOW VIEW ON *.* TO 'zbx_monitor'@'%';

```

2. Log into Zabbix frontend.

On Zabbix server

In the Templates field, type or select the template "MySQL by Zabbix agent 2" that will be linked to the host.

In the Macros tab, switch to Inherited and host macros, look for the following macros and click on Change next to the macro value to update it:


{$MYSQL.DSN} tcp://localhost:3306

{$MYSQL.PASSWORD} LudoBicEnhanced#7-

{$MYSQL.USER} zbx_monitor


Zabbix server

![mysql zabbix](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/mysql_zabbix.jpg)

And data should come.

![mysql data](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/mysql.jpg)


https://www.zabbix.com/documentation/current/en/manual/guides/monitor_mysql

### Template RabbitMQ node by Zabbix agent todo

Lets install Zabbix Agent 2 oon the vm with rabbitmq, amqp04



```bash
# instal repos
sudo wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_6.0+ubuntu24.04_all.deb
sudo dpkg -i zabbix-release_latest_6.0+ubuntu24.04_all.deb
sudo apt update -y

# Install Zabbix agent 2
sudo apt install zabbix-agent2

# Install Zabbix agent 2 plugins
# na, not needed now, but this is how
# sudo apt install zabbix-agent2-plugin-mongodb zabbix-agent2-plugin-mssql zabbix-agent2-plugin-postgresql

# Start Zabbix agent 2 process
sudo systemctl restart zabbix-agent2
sudo systemctl enable zabbix-agent2

# log it
cat /var/log/zabbix/zabbix_agent2.log


# edit conf
cd /etc/zabbix
sudo nano zabbix-agent2.conf
```

Edit conf

```ini
LogFileSize=100
Server=192.168.3.5
# set comment
# ServerActive=127.0.0.1
Hostname=amqp04
```

Restart and check logs
```bash
sudo systemctl restart zabbix-agent2

sudo service zabbix-agent2 status

```
Host name on second last line.

![amqp01 vm zabbix agent](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/amqp04.jpg)

https://www.zabbix.com/download?zabbix=6.0&os_distribution=ubuntu&os_version=24.04&components=agent_2&db=&ws=

Now create the host in Zabbix frontend with Linux by zabbix agent (passive), not the active.

![amqp01 vm zabbix agent ok](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/amqp04_ok.jpg)

Now we can monitor amqp rabbitmq

### Website certificate by Zabbix agent 2 todo


### InfluxDB template for zabbix todo


https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/influxdb/README_integrate_with_zabbix.md
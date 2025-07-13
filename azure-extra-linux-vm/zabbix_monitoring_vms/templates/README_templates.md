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

### Website certificate by Zabbix agent 2 todo


### InfluxDB template for zabbix todo


https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/influxdb/README_integrate_with_zabbix.md
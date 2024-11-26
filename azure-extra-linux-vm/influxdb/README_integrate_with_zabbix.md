# InfluxDB template

https://www.zabbix.com/integrations/influxdb

## Zabbix 6 montor influxdb

* VNET, vnet-uks-central/Vms03
* Zabbix VM, 192.168.3.5
* InfluxDB VM, 192.168.3.4

```bash

# Check influxdb
sudo service influxdb status

influxdb.service - InfluxDB is an open-source, distributed, time series database
     Loaded: loaded (/lib/systemd/system/influxdb.service; enabled; vendor preset: enabled)
     Active: active (running) since Sat 2024-11-23 15:12:00 UTC; 3min 4s ago
```

login influxdb, hm removed self signed

http://ip-address:8086/signin

login zabbix

http://ip-address/zabbix/zabbix.php?action=dashboard.view

## New host (pre already added)

![Influxdb host](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/influxdb/images/influxdb_host.jpg)


## Templates / Linux by Zabbix agent (pre already added)

Lets first add this one to the influxdb host

```bash

# the agen tis running must have installed it before
imsdal@vmdocker01:~$ sudo service zabbix-agent status
● zabbix-agent.service - Zabbix Agent
     Loaded: loaded (/lib/systemd/system/zabbix-agent.service; enabled; vendor preset: enabled)
     Active: active (running) since Sat 2024-11-23 15:11:52 UTC; 21min ago

## lets configure it correct to get the linux data
cd /etc/zabbix/


# edit
cat zabbix_agentd.conf | grep "Hostname*"

Hostname=vmdocker01

cat zabbix_agentd.conf | grep "ServerActive*"

ServerActive=192.168.3.5

cat zabbix_agentd.conf | grep "Server="

Server=192.168.3.5


# bck
imsdal@vmdocker01:/etc/zabbix$ sudo cp zabbix_agentd.conf zabbix_agentd.conf_bck
imsdal@vmdocker01:/etc/zabbix$ sudo nano zabbix_agentd.conf
imsdal@vmdocker01:/etc/zabbix$ sudo service zabbix-agent restart
imsdal@vmdocker01:/etc/zabbix$ sudo service zabbix-agent status
● zabbix-agent.service - Zabbix Agent
     Loaded: loaded (/lib/systemd/system/zabbix-agent.service; enabled; vendor preset: enabled)
     Active: active (running) since Sat 2024-11-23 15:39:12 UTC; 6s ago


```

## Edit ufw since it is enabled (pre already added)

```bash
imsdal@vmdocker01:/etc/zabbix$ hostname
vmdocker01

sudo ufw status
Status: active

sudo ufw allow 10050
sudo ufw allow 10051

Rule added
Rule added (v6)



```

https://www.zabbix.com/documentation/current/en/manual/guides/monitor_linux


# This template works with self-hosted InfluxDB instances

This template works with self-hosted InfluxDB instances. Internal service metrics are collected from InfluxDB /metrics endpoint. For organization discovery template need to use Authorization via API token. See docs: https://docs.influxdata.com/influxdb/v2.0/security/tokens/

Don't forget to change the macros {$INFLUXDB.URL}, {$INFLUXDB.API.TOKEN}. Also, see the Macros section for a list of macros used to set trigger values. NOTE. Some metrics may not be collected depending on your InfluxDB instance version and configuration.











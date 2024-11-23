# 2 vms and fun with monitoring in zabbix

https://www.zabbix.com/integrations/influxdb

## Zabbix 6

Start both vms

* VNET, vnet-uks-central/vms03
* Zabbix vm, 192.168.3.5
* Docker and InfluxDB vm, 192.168.3.4

## New host

![Influxdb host](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/influxdb_host.jpg)


## Templates / Linux by Zabbix agent

Lets first add this one to the host sine it is a linux vm

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

## Edit ufw since it is enabled

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











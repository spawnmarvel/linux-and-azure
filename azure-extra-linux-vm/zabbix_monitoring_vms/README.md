# Zabbix Linux by Zabbix agent (templates) and fun with monitoring (2 vms) and more


## Zabbix 6 is installed


![Zabbix](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/zabbix6.jpg)

Start both vms

* VNET, vnet-uks-central/vms03
* Zabbix vm (vmzabbix02), 192.168.3.5
* Docker and InfluxDB vm (vmdocker01), 192.168.3.4


![Vnet](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/vnet.jpg)


## Zabbix Trapper items (10051 inbound to zabbix server)

Trapper items accept incoming data instead of querying for it. This is useful for any data you want to send to Zabbix.

```bash
# Zabbix sender

zabbix_sender -z <server IP address> -p 10051 -s "New host" -k trap -o "test value"

```

To send the "test value", the following command options are used:

* -z to specify Zabbix server IP address
* -p to specify Zabbix server port number (10051 by default)
* -s to specify the host (make sure to use the technical instead of the visible host name)
* -k to specify the key of the item configured in the trapper item
* -o to specify the value to send

https://www.zabbix.com/documentation/current/en/manual/config/items/itemtypes/trapper

Telegraf is trapping

This plugin writes metrics to Zabbix via traps. It has been tested with versions v3.0, v4.0 and v6.0 but should work with newer versions of Zabbix as long as the protocol doesn't change.

https://github.com/influxdata/telegraf/tree/master/plugins/outputs/zabbix

### Make a trapper item


```bash
cat send_2_zabbix_data.sh

#!/bin/bash
zabbix_sender -z 192.168.3.5 -s "VM28" -k interface1 -o 2
# sleep 5 sec
sleep 5
zabbix_sender -z 192.168.3.5 -s "VM28" -k interface2 -o 2

# send
bash send_2_zabbix_data.sh
Response from "192.168.3.5:10051": "processed: 0; failed: 1; total: 1; seconds spent: 0.000481"
sent: 1; skipped: 0; total: 1
Response from "192.168.3.5:10051": "processed: 0; failed: 1; total: 1; seconds spent: 0.000021"
sent: 1; skipped: 0; total: 1

```

We must add the items on host and it doens not need an interface.

Sendd some data and view it

![trapping](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/trapping.jpg)



## Zabbix Agent: Active vs Passive (is not trapper)


When it comes to Zabbix agent modes, there is a choice between the active and the passive modes. Each time new items or hosts are added in the front end, you need to choose the item type.

Item type dropdown, For the Zabbix agent, there is a choice between:

* Zabbix agent (passive)
* Zabbix agent (active)

![active passive](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/active_passive.jpg)


https://follow-e-lo.com/2022/09/30/zabbix-agent-active-vs-passive/

https://blog.zabbix.com/zabbix-agent-active-vs-passive/9207/




### Install Zabbix agent

```bash

# https://www.zabbix.com/documentation/3.0/en/manual/installation/install_from_packages/agent_installation

# the agent is running must have installed it before

imsdal@vmdocker01:~$ sudo service zabbix-agent status
● zabbix-agent.service - Zabbix Agent
     Loaded: loaded (/lib/systemd/system/zabbix-agent.service; enabled; vendor preset: enabled)
     Active: active (running) since Sat 2024-11-23 15:11:52 UTC; 21min ago

## lets configure it correct to get the linux data
cd /etc/zabbix/


# edit and add
cat zabbix_agentd.conf | grep "Hostname*"

Hostname=vmdocker01

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
### Configure Zabbix for monitoring Passive checks

* In the Interfaces parameter, add Agent interface and specify the IP address or DNS name of the Linux machine where the agent is installed.
* In the Templates parameter, type or select Linux by Zabbix agent.

![Docker Influxdb host](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/influxdb_host.jpg)


Edit ufw since it is enabled

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

Green and healthy linux host

![green host](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/green_host.jpg)



### Active checks


```bash
# # edit and add
cat zabbix_agentd.conf | grep "ServerActive*"

ServerActive=192.168.3.5

```
View collected metrics

![Collected metrics](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/collected_metrics.jpg)


## Stop vm

![stop vm](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/stop_vm.jpg)

zbx down

![zabbix host down](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/zbx_host_down.jpg)



### Set up problem alerts


### Test your configuration


On Linux, you can simulate high CPU load and as a result receive a problem alert by running:

```bash

cat /dev/urandom | md5sum
```


https://www.zabbix.com/documentation/current/en/manual/guides/monitor_linux


## Test more templates and stuff










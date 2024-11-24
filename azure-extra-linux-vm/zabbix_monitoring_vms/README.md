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

We must add the items on host and it does not need an interface but port 10051 must be open.

Send some data and view it

![trapping](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/trapping.jpg)



## Zabbix Agent: Active 10051 vs Passive 10050 (is not trapper)


When it comes to Zabbix agent modes, there is a choice between the active and the passive modes. Each time new items or hosts are added in the front end, you need to choose the item type.

Item type dropdown, For the Zabbix agent, there is a choice between:

* Zabbix agent

If you use the Zabbix agent in the passive mode, it means that the poller (internal server process) connects to the agent on port 10050/TCP and polls for a certain value

* Zabbix agent (active)

In the active mode, all data processing is performed on the agent, without the interference of pollers. However, the agent must know what metrics should be monitored, and that is why the agent connects to the trapper port 10051/TCP of the server once every two minutes (by default).



![active passive](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/active_passive.jpg)


https://follow-e-lo.com/2022/09/30/zabbix-agent-active-vs-passive/

https://blog.zabbix.com/zabbix-agent-active-vs-passive/9207/




### Install Zabbix agent

Note!!

```bash
# Check your Zabbix server version:
zabbix_server -V

# Install Zabbix agent of the same version (recommended) on the Linux machine that you want to monitor. 

```


We will use zabbix agent and not zabbix agent2

https://www.zabbix.com/documentation/current/en/manual/appendix/items/activepassive

```bash

# https://www.zabbix.com/documentation/3.0/en/manual/installation/install_from_packages/agent_installation

# the agent is running must have installed it before

imsdal@vmdocker01:~$ sudo service zabbix-agent status
● zabbix-agent.service - Zabbix Agent
     Loaded: loaded (/lib/systemd/system/zabbix-agent.service; enabled; vendor preset: enabled)
     Active: active (running) since Sat 2024-11-23 15:11:52 UTC; 21min ago


# lets uninstall it and install it again since it is a low version

zabbix_agentd --version
zabbix_agentd (daemon) (Zabbix) 5.0.17
Revision 0a4ac3dabc 18 October 2021, compilation time: Nov 19 2021 00:15:32

# name
sudo service zabbix-agent status

# remove it
sudo apt-get --purge autoremove zabbix-agent
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following packages will be REMOVED:
  zabbix-agent*
0 upgraded, 0 newly installed, 1 to remove and 36 not upgraded.
After this operation, 945 kB disk space will be freed.
Do you want to continue? [Y/n] y
(Reading database ... 163439 files and directories currently installed.)
Removing zabbix-agent (1:5.0.17+dfsg-1) ...
Processing triggers for man-db (2.10.2-1) ...
(Reading database ... 163423 files and directories currently installed.)
Purging configuration files for zabbix-agent (1:5.0.17+dfsg-1) ...
dpkg: warning: while removing zabbix-agent, directory '/etc/zabbix' not empty so not removed

# just update pack
sudo apt update -y

# install it
sudo apt install zabbix-agent
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following NEW packages will be installed:
  zabbix-agent

# check running or start it

sudo service zabbix-agent status
● zabbix-agent.service - Zabbix Agent
     Loaded: loaded (/lib/systemd/system/zabbix-agent.service; enabled; vendor preset: enabled)
     Active: active (running) since Sun 2024-11-24 13:33:26 UTC; 3min 41s ago

# check version
zabbix_agentd --version
zabbix_agentd (daemon) (Zabbix) 5.0.17

```
### Configure Zabbix for monitoring Passive checks

A passive check is a simple data request. Zabbix server or proxy asks for some data (for example, CPU load) and Zabbix agent sends back the result to the server.


* In the Interfaces parameter, add Agent interface and specify the IP address or DNS name of the Linux machine where the agent is installed.


![Docker Influxdb host](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/influxdb_host.jpg)



```bash
## lets configure it correct to get the linux data
cd /etc/zabbix/


# edit and add 
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

Edit ufw since it is enabled

```bash
imsdal@vmdocker01:/etc/zabbix$ hostname
vmdocker01

sudo ufw status
Status: active

sudo ufw allow 10050

# lets deny this since it is for active
sudo ufw deny 10051

Rule added
Rule added (v6)

sudo ufw status

10050                      ALLOW       Anywhere
10051                      DENY        Anywhere

```

Green and healthy linux host, but without data.

![green host](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/green_host2.jpg)


### AI

Lets add some passive data

Question:
```log
A passive check is a simple data request. Zabbix server or proxy asks for some data (for example, CPU load) and Zabbix agent sends back the result to the server. how to configure that?
```

Answer:

User Parameters (Optional but Recommended): For better organization and security, you can define user parameters within the zabbix_agentd.conf file. These parameters allow you to specify custom metrics that the agent will report

* Add Host: In the Zabbix web interface, navigate to "Configuration" -> "Hosts". Click "Create host."
* Items: This is where you define the passive checks. Navigate to the "Items" tab of the newly added host. Click "Create item."
* Key: This is the crucial part. For built-in metrics, you'll find keys in the Zabbix documentation. Examples:

```log
system.cpu.load[all,avg1] (Average CPU load over 1 minute)
vm.memory.size[available] (Available memory)
```

* Update interval: How often the data should be collected (e.g., 60 seconds).
* UserParameter: If you defined user parameters in the agent configuration, you would specify them here. For example, my.custom.metric[argument1]


Let's say you want to monitor the number of files in a specific directory. You'd add this to your zabbix_agentd.conf:

```log
UserParameter=files.count[/tmp],ls -l /tmp | wc -l
```

Then, in the Zabbix server, you'd create an item with the key files.count[/tmp]. The agent will execute the ls -l /tmp | wc -l command and return the number of files.

https://www.zabbix.com/documentation/current/en/manual/config/items/userparameters

Lets do that

```bash
 cat zabbix_agentd.conf | grep "UserPa*"
#       Does not support UserParameters or aliases.
### Option: UnsafeUserParameters
# UnsafeUserParameters=0
### Option: UserParameter
#       Format: UserParameter=<key>,<shell command>
# UserParameter=
UserParameter=varname, echo 1

imsdal@vmdocker01:/etc/zabbix$ sudo service zabbix-agent stop
imsdal@vmdocker01:/etc/zabbix$ sudo service zabbix-agent start
imsdal@vmdocker01:/etc/zabbix$ sudo service zabbix-agent status
● zabbix-agent.service - Zabbix Agent
     Loaded: loaded (/lib/systemd/system/zabbix-agent.service; enabled; vendor preset: enabled)
     Active: active (running) since Sun 2024-11-24 14:23:39 UTC; 2s ago

```
On zabbix host add item ping and host will be healthy after the request.


![varname user paramter](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/varname.jpg)

And we have the custom data

![varname data](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/varname_data.jpg)

The host is green and healthy but with not template

![green no template](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/green_no_template.jpg)

### Active checks

We will do this on the same host

In the Templates parameter, type or select Linux by Zabbix agent active.

```bash
# edit and add

cat zabbix_agentd.conf | grep "Hostname*"

Hostname=vmdocker01

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










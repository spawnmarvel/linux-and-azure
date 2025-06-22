# Stack for int, real, short text monitoring Zabbix and Linux by Zabbix agent (2 vms)

Example with Zabbix server and a Linux VM with Linux template as test bases for passiv or active agent.

## Zabbix 6 is installed


![Zabbix](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/zabbix6.jpg)

View the README_install docs in this folder.

Azure environment

* VNET, vnet-uks-central/vms03
* Zabbix vm (vmzabbix02), 192.168.3.5
* VM dummy01 192.168.3.4, dummy03 192.168.3.6 (updated 22 06 2025)


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

### Install zabbix sender on vm dummy01 linux vm

```bash
pwd
# /home/imsdal

# Example for Zabbix 6.0 on Ubuntu 24.04 - adjust for your version
wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_6.0+ubuntu24.04_all.deb
sudo dpkg -i zabbix-release_6.0-1+ubuntu22.04_all.deb

# install
sudo apt update -y
sudo apt install zabbix-sender
which zabbix_sender
# /usr/bin/zabbix_sender


```

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



## Zabbix Agent: Active 10051 (is not trapper) vs Passive 10050


When it comes to Zabbix agent modes, there is a choice between the active and the passive modes. Each time new items or hosts are added in the front end, you need to choose the item type.

Item type dropdown, For the Zabbix agent, there is a choice between:

* Zabbix agent

If you use the Zabbix agent in the passive mode, it means that the poller (internal server process) connects to the agent on port 10050/TCP and polls for a certain value

* Zabbix agent (active)

In the active mode, all data processing is performed on the agent, without the interference of pollers. However, the agent must know what metrics should be monitored, and that is why the agent connects to the trapper port 10051/TCP of the server once every two minutes (by default).


Direction

![active_vs_passive](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/active_vs_passive.jpg)

Template


![active passive](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/active_passive.jpg)


https://follow-e-lo.com/2022/09/30/zabbix-agent-active-vs-passive/

https://blog.zabbix.com/zabbix-agent-active-vs-passive/9207/




### Install Zabbix agent (default with passive checks) and Template Linux by Zabbix agent 10050

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

# we are on the same vm as we installed zabbix-sender so we have the packet already
# install it
sudo apt install zabbix-agent

# configure the agent for passive

sudo nano /etc/zabbix/zabbix_agentd.conf

Server=192.168.3.5
# ServerActive=127.0.0.1
Hostname=dummy01

# check running or start it
sudo service zabbix-agent status

# check version
zabbix_agentd --version
zabbix_agentd (daemon) (Zabbix) 6.0.40


```
### Configure Zabbix for monitoring Passive checks 10050, it means that the poller (internal server process) connects to the agent on port 10050/TCP and polls for a certain value

A passive check is a simple data request. Zabbix server or proxy asks for some data (for example, CPU load) and Zabbix agent sends back the result to the server.


* In the Interfaces parameter, add Agent interface and specify the IP address or DNS name of the Linux machine where the agent is installed.
* And add the linux passive template as well


![Agent passive interface](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/agent_passive.jpg)


And it already works since the vm can talk to each other on the same vnet using port 10050.


![Agent passive interface ok](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/agent_passive_ok.jpg)

Now lets block that port.


Edit ufw since it is disabled

```bash
imsdal@dummy01:/var/log/zabbix$ sudo ufw status
Status: inactive

sudo ufw app list
Available applications:
  OpenSSH

sudo ufw allow OpenSSH
Rules updated
Rules updated (v6)

sudo ufw show added
Added user rules (see 'ufw status' for running firewall):
ufw allow OpenSSH

sudo ufw enable
Command may disrupt existing ssh connections. Proceed with operation (y|n)? y
Firewall is active and enabled on system startup

sudo ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp (OpenSSH)           ALLOW IN    Anywhere
22/tcp (OpenSSH (v6))      ALLOW IN    Anywhere (v6)


```

But now our agent interface fails

![Agent passive interface not ok](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/agent_passive_10050.jpg)

Lets fix that

```bash
sudo ufw allow 10050
Rule added
Rule added (v6)

sudo ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp (OpenSSH)           ALLOW IN    Anywhere
10050                      ALLOW IN    Anywhere
22/tcp (OpenSSH (v6))      ALLOW IN    Anywhere (v6)
10050 (v6)                 ALLOW IN    Anywhere (v6)

```

Green and valid

![Agent passive interface ok again](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/passive_check_ok_again.jpg)

### User Parameters (Optional but Recommended)


#### User parameter simple
User Parameters (Optional but Recommended): For better organization and security, you can define user parameters within the zabbix_agentd.conf file. These parameters allow you to specify custom metrics that the agent will report

* Update interval: How often the data should be collected (e.g., 60 seconds).
* UserParameter: If you defined user parameters in the agent configuration, you would specify them here. For example, my.custom.metric[argument1]


Lets do that

```bash
 cat zabbix_agentd.conf | grep "UserPa*"
#       Does not support UserParameters or aliases.
### Option: UnsafeUserParameters
# UnsafeUserParameters=0
### Option: UserParameter
#       Format: UserParameter=<key>,<shell command>
# UserParameter=
UserParameter=echo1, echo 1

```

![echo 1](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/echo1.jpg)

On zabbix host add item ping and host will be healthy after the request.


![echo 1 agent](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/echo1_agent.jpg)

And we have the custom data

![echo 1 agent value](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/echo1_value.jpg)

The host is green and healthy and no template was used, the item was added tot the host and zabbix agent executed it and sent via port 10050.

#### User parameter advanced

TBD

https://www.zabbix.com/documentation/6.0/en/manual/config/items/userparameters



### Install Zabbix agent and Template Linux by Zabbix agent active 10051


* A single Zabbix Agent can collect metrics in both passive and active modes
* Zabbix Agent is backward compatible
* The frontend ZBX interface icon is related only to passive checks 
* Active Zabbix Agent doesn’t require an interface configuration in Zabbix frontend
* For active checks, the Zabbix Agent Hostname in the configuration file must match the Host name in the frontend

https://blog.zabbix.com/handy-tips-15-deploying-zabbix-passive-and-active-agents/17696/


Lets use the active template on vm dummy03

Check agent installed

```bash
# ssh from vm dummy01 to vm dummy 03, since dummy01 is proxy
imsdal@dummy03:~$ zabbix_agentd --version
zabbix_agentd (daemon) (Zabbix) 6.0.40

sudo nano /etc/zabbix/zabbix_agentd.conf
# edit config
Server=192.168.3.5
ServerActive=192.168.3.5

Hostname=dummy03

# Default:
# RefreshActiveChecks=120  
```

Check the log for the active statment

```bash
imsdal@dummy03:/etc/zabbix$ sudo tail -f /var/log/zabbix/zabbix_agentd.log
  1744:20250622:130917.987 IPv6 support:          YES
  1744:20250622:130917.987 TLS support:           YES
  1744:20250622:130917.987 **************************
  1744:20250622:130917.987 using configuration file: /etc/zabbix/zabbix_agentd.conf
  1744:20250622:130917.987 agent #0 started [main process]
  1745:20250622:130917.988 agent #1 started [collector]
  1746:20250622:130917.989 agent #2 started [listener #1]
  1747:20250622:130917.989 agent #3 started [listener #2]
  1748:20250622:130917.990 agent #4 started [listener #3]
  1749:20250622:130917.995 agent #5 started [active checks #1]
```

In the Templates parameter, type or select Linux by Zabbix agent template, we have no interface.

![Active agent](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/active_agent.jpg)

And after RefreshActiveChecks=120, we get the data.

![Active agent ok](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/active_agent_ok.jpg)




### Active checks all data processing is performed on the agent, without the interference of pollers. (agent ask for parameters every 2 ,im 10051)

We will do this on the same host

In the Templates parameter, remove Linux by Zabbix agent

![unlink ](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/template_unlink.jpg)

In the Templates parameter, type or select Linux by Zabbix agent active and add it

![template_active ](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/template_active.jpg)

Configure the host to use active server

```bash
# edit and add

cat zabbix_agentd.conf | grep "Hostname*"

Hostname=vmdocker01

cat zabbix_agentd.conf | grep "ServerActive*"

ServerActive=192.168.3.5

imsdal@vmdocker01:/etc/zabbix$ sudo nano zabbix_agentd.conf
imsdal@vmdocker01:/etc/zabbix$ sudo service zabbix-agent restart
imsdal@vmdocker01:/etc/zabbix$ sudo service zabbix-agent status

```

Lets make a deny rule for 10051

![deny rule](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/deny_rule.jpg)

and log at the logs

```bash
sudo tail -f zabbix_agentd.log
 10413:20241124:150500.676 **************************
 10413:20241124:150500.676 using configuration file: /etc/zabbix/zabbix_agentd.conf
 10413:20241124:150500.676 agent #0 started [main process]
 10415:20241124:150500.677 agent #1 started [collector]
 10417:20241124:150500.677 agent #3 started [listener #2]
 10419:20241124:150500.677 agent #5 started [active checks #1]
 10418:20241124:150500.677 agent #4 started [listener #3]
 10416:20241124:150500.678 agent #2 started [listener #1]
 10419:20241124:150500.722 active check "vfs.file.cksum[/etc/passwd,sha256]" is not supported: Too many parameters.
 10419:20241124:151403.255 active check data upload to [192.168.3.5:10051] started to fail ([connect] cannot connect to [[192.168.3.5]:10051]: [4] Interrupted system call)
```

View collected metrics with deny 10051, template uses 10051, user paramter in passive uses 10050 and is updated

![deny rule data ](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/deny_rule_data.jpg)

View collected metrics with allow 10051, remove NSG

![allow rule data](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/allow_rule_data.jpg)


## Conclusion: It all comes down to who is responsible for the processing and use of power

## Zabbix Agent Configuration Guide

* Trapping is not agent, but port is 10051 and no interface is needed
* Agent passive, 10050 and interface needed, template name, can use userparamter also
* Agent active, 10051 and interface needed, template name active, can use userparamter also

https://follow-e-lo.com/2022/09/30/zabbix-agent-active-vs-passive/

In Zabbix, the agent mode determines how the agent communicates with the Zabbix server or proxy. There are two main modes:

This guide explains how to configure the Zabbix Agent in both passive and active modes, including port usage, configuration file settings, and restart instructions for both Linux and Windows.

***Passive Mode (default)***
In passive mode, the Zabbix server or proxy connects to the agent to request data.

If you use the Zabbix agent in the passive mode, it means that the poller (internal server process) connects to the agent on port 10050/TCP and polls for a certain value (e.g., host CPU load). The poller waits until the agent on the host responds with the value. Then the server gets the value back, and the connection closes.



* Port used: 10050 (TCP)
* Direction: Server/Proxy → Agent

Configuration
Edit the Zabbix agent config file:

Linux: /etc/zabbix/zabbix_agentd.conf
Windows: C:\Program Files\Zabbix Agent\zabbix_agentd.conf
Set the following parameter:

```bash
Server=your.zabbix.server.ip

sudo systemctl restart zabbix-agent
```
Windows: Restart the "Zabbix Agent" service from the Services panel.

***Active Mode***
In active mode, the Zabbix agent connects to the server or proxy and pushes data.

In the active mode, all data processing is performed on the agent, without the interference of pollers. However, the agent must know what metrics should be monitored, and that is why the agent connects to the trapper port  10051/TCP of the server once every two minutes (by default). The agent requests the information about the items, and then performs the monitoring on the host and pushes the data to the server via the same TCP port.

* Port used: 10051 (TCP)
* Direction: Agent → Server/Proxy

Configuration
Edit the Zabbix agent config file:

Linux: /etc/zabbix/zabbix_agentd.conf
Windows: C:\Program Files\Zabbix Agent\zabbix_agentd.conf
Set the following parameters:

```bash
ServerActive=your.zabbix.server.ip
Hostname=your-agent-hostname

sudo systemctl restart zabbix-agent
```
Windows: Restart the "Zabbix Agent" service from the Services panel.

Dual Mode (Optional)

You can enable both modes by setting both Server and ServerActive in the config file.

Example logs

```ini
192.168.3.4

# Server=
Server=192.168.3.5

# ServerActive=
ServerActive=192.168.3.5

Template and interface 192.168.3.4, 10050

Linux by Zabbix agent and not Linux by Zabbix agent active

192.168.3.4
cd /var/log/zabbix
sudo tail -f zabbix.agentd.log

6673:20250617:210155.511 **************************
  6673:20250617:210155.511 using configuration file: /etc/zabbix/zabbix_agentd.conf
  6673:20250617:210155.511 agent #0 started [main process]
  6674:20250617:210155.511 agent #1 started [collector]
  6675:20250617:210155.512 agent #2 started [listener #1]
  6676:20250617:210155.512 agent #3 started [listener #2]
  6677:20250617:210155.514 agent #4 started [listener #3]
  6678:20250617:210155.515 agent #5 started [active checks #1]


# ServerActive=192.168.3.5
6940:20250617:210831.912 **************************
  6940:20250617:210831.912 using configuration file: /etc/zabbix/zabbix_agentd.conf
  6940:20250617:210831.912 agent #0 started [main process]
  6941:20250617:210831.913 agent #1 started [collector]
  6942:20250617:210831.913 agent #2 started [listener #1]
  6944:20250617:210831.913 agent #4 started [listener #3]
  6943:20250617:210831.914 agent #3 started [listener #2]

```

## HA or Multiple Zabbix server by same agent

To enable passive checks, the node names must be listed in the Server parameter, separated by a comma.

```bash

Server=zabbix-node-01,zabbix-node-02
```
To enable active checks, the node names must be listed in the ServerActive parameter. Note that for active checks the nodes must be separated by a comma from any other servers, while the nodes themselves must be separated by a semicolon, e.g.:

```bash
ServerActive=zabbix-node-01;zabbix-node-02

```

https://www.zabbix.com/documentation/current/en/manual/appendix/config/zabbix_agentd#serveractive

![HA or mult](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/ha_mult.jpg)

https://www.zabbix.com/documentation/current/en/manual/concepts/server/ha


Yes, a single Zabbix agent **can send data to more than one Zabbix server (or Zabbix proxy)**, but there are important distinctions between passive and active checks:

### 1. Passive Checks (`Server` parameter)

* **How it works:** In passive mode, the Zabbix Server (or Proxy) initiates the connection to the agent and requests data for specific items. The agent simply listens on its port (default 10050) and responds to these requests.
* **Multiple Servers:** You **can** list multiple Zabbix server or proxy IP addresses/hostnames in the `Server` parameter of the `zabbix_agentd.conf` file, separated by commas.
    ```
    Server=192.168.1.100,192.168.1.101,zabbix-server-prod.example.com
    ```
    https://www.zabbix.com/documentation/current/en/manual/appendix/config/zabbix_agentd#server
    
* **Behavior:** Each server/proxy specified in this list can independently connect to the agent and query data. The agent will respond to requests from any of the allowed servers.
* **Considerations:**
    * **Duplicate Data:** If both servers are configured to monitor the same items on that agent, the agent will send the data to *both* servers when they request it. This means you'll have duplicate data in your Zabbix databases, which can increase storage and processing load unnecessarily.
    * **Firewall:** The agent's port (10050 by default) must be open to inbound connections from all specified Zabbix servers/proxies.
    * **Purpose:** This setup is typically used for:
        * **Redundancy (limited):** If one Zabbix server goes down, the other can still collect data. However, it's not a true high-availability solution for the Zabbix server itself (that requires a Zabbix HA cluster).
        * **Dev/Test Environments:** A development or test Zabbix server might pull a subset of data from production agents for testing without interfering with the main production server.
        * **Centralized Monitoring with Specific Use Cases:** Sometimes different teams might have their own Zabbix instances but need a subset of data from common hosts.

### 2. Active Checks (`ServerActive` parameter)

* **How it works:** In active mode, the Zabbix agent initiates the connection to the Zabbix Server (or Proxy), requests a list of items to monitor, collects the data itself, and then pushes the collected data back to the server.
* **Multiple Servers:** You **can** list multiple Zabbix server or proxy IP addresses/hostnames in the `ServerActive` parameter of the `zabbix_agentd.conf` file, separated by commas.
    ```
    ServerActive=192.168.1.100,zabbix-server-dr.example.com
    ```
    https://www.zabbix.com/documentation/current/en/manual/appendix/config/zabbix_agentd#serveractive

* **Behavior:** The agent will try to fetch active checks configuration from each listed server/proxy. It then sends the collected data for active items to the server/proxy that originally provided the configuration for those items.
    * **Important Note:** The agent typically only receives the configuration from **one** of the `ServerActive` addresses at a time. If a specific active item is defined on multiple servers, the agent will generally send the data to the server that *first* provided the configuration for that item. It's not designed for different items to go to different servers easily from one agent configuration.
* **Considerations:**
    * **Duplication (less common, but possible):** Similar to passive checks, if the *same active item* is configured on multiple servers the agent reports to, you might get duplicate data. However, active checks are usually configured so that each server monitors a unique set of items or only one server is the primary for active checks.
    * **Hostname Matching:** The `Hostname` parameter in `zabbix_agentd.conf` must precisely match the hostname defined in the Zabbix Frontend for the host on *each* server it's reporting to.
    * **Firewall:** The Zabbix server's trapper port (10051 by default) must be open to inbound connections from the agent.

### **Typical Use Cases for Multi-Server Agent Monitoring:**

* **Migration:** During a Zabbix server migration, you can have agents report to both the old and new servers simultaneously for a transition period.
* **Disaster Recovery (DR) / Backup:** A secondary (DR) Zabbix server could be configured to passively monitor key systems, or agents could actively send data to both primary and DR servers.
* **Testing/Development:** A dev/test Zabbix instance can monitor a subset of production systems for testing new templates, items, or Zabbix versions.
* **Segregation of Duties:** Different departments or teams might have their own Zabbix servers, and some critical hosts might need to report to multiple of these.

### **What a Zabbix Agent *Cannot* Do:**

* **Item-level Routing:** A single Zabbix agent cannot be configured to send specific items to Server A and other items to Server B. All data collected by that agent instance will generally be available to (and sent to, if configured) all listed servers/proxies.
* **True Server HA (without Zabbix HA cluster):** While multi-server agent configuration offers some redundancy, it doesn't provide a seamless Zabbix server high-availability solution. For true HA, Zabbix has its own HA cluster feature (since Zabbix 6.0), which involves multiple Zabbix server instances sharing a database and taking over if one fails.

**In summary, yes, a Zabbix agent can send to multiple Zabbix servers by listing them in the `Server` and/or `ServerActive` parameters, but be mindful of potential data duplication and manage your monitoring configurations on each server accordingly.**

https://www.zabbix.com/forum/zabbix-help/379138-one-node-monitored-by-2-differents-zabbix-servers

### Troubleshooting

View folder troubleshooting 


### Test more templates and stuff

View folder templates

### Enable ssl tbd


* Openssl
* and AI






# Zabbix monitor VM's and SNMP default

In Zabbix, the distinction between Active and Passive modes relates to which entity initiates the communication and data transfer between the Zabbix Server/Proxy and the Zabbix Agent.


# Table of Contents

1. [Zabbix monitor VM's and SNMP default](#zabbix-monitor-vms-and-snmp-default)  
   1.1 [Tasks](#tasks)  
   1.2 [Stack and current version](#stack-and-current-version)  
   1.3 [Zabbix Windows/Linux by Zabbix agent active](#zabbix-windowslinux-by-zabbix-agent-active)  
       - [Install Windows by Zabbix agent active](#install-windows-by-zabbix-agent-active)  
       - [User parameters windows](#user-parameters-windows)  
       - [Install Linux by Zabbix agent active](#install-linux-by-zabbix-agent-active)  
       - [User parameters linux](#user-parameters-linux)  
   1.4 [Zabbix Linux by SNMP](#zabbix-linux-by-snmp)  
       - [Install](#install)  
   1.5 [All Templates](#all-templates)  
   1.6 [Mysql tuning tbd](#mysql-tuning-tbd)


## Passive Mode (Server-Poll) Active Mode (Agent-Push)

### Zabbix agents

![p_vs_a](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/p_vs_a.png)

### SNMP

Active Monitoring Note: While SNMP is primarily a polling (passive) protocol, Zabbix handles the metrics efficiently. If you require true "active" agent functionality (where the agent sends data to the server), ***it is recommended to use the "Linux by Zabbix agent active" template instead of SNMP***

![sp_vs_sa](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/sp_vs_sa.png)

## Tasks

* Use default agent 2 active / trap
* Use default templates for vm's
* Use Zabbix default snmp trap
* Use default snmp templates

## Stack and current version

* Zabbix, vmzabbix02, 192.168.3.5
* Mysql, vmzabbix02, 192.168.3.5
* vmhybrid01, 192.168.3.7, Windows by Zabbix agent active
* New vm Linux by Zabbix agent active
* New vm Linux by SNMP

## Zabbix Windows/Linux by Zabbix agent active

### Install Windows by Zabbix agent active

Template

* https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/os/windows_agent_active

Install

* https://www.zabbix.com/download_agents?version=7.0+LTS&release=7.0.25&os=Windows&os_version=Server+2016+%2B&hardware=amd64&encryption=OpenSSL&packaging=MSI&show_legacy=0
* zabbix_agent2-7.0.25-windows-amd64-openssl.msi
* zabbix_agent2.conf

```bash
# Server=192.168.3.5
ServerActive=192.168.3.5
Hostname=vmhybrid01
```

Note: For active agents, the Zabbix Agent interface (IP address) is not strictly required in the host configuration, as the agent initiates the connection.

Data Collection and hosts

![windows_a](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/windows_a.png)

Monitoring and hosts

![windows_items](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/windows_items.png)

In Zabbix, the "Windows by Zabbix agent active" template is a "master" or "parent" template. You generally do not need to manually select the other "active" items (CPU, Memory, Filesystem, etc.) because the master template already includes them as nested modules.  

1. What is already included?

When you link "Windows by Zabbix agent active", it automatically pulls in the following "active" modules:  

* Windows CPU: Utilization, interrupt time, and queue length.
* Windows Memory: Free/used memory and swap space.
* Windows Filesystems: Disk space discovery and usage.
* Windows Network: Interface discovery and traffic stats.
* Windows Physical Disks: Read/write latency and throughput.
* Windows Services: Monitoring of critical system services.

In Active Mode, your drive information does not appear instantly like a static field. It relies on a process called Low-Level Discovery (LLD).

* The Wait Time: By default, this rule usually runs every 1 hour.
* The Action: The Agent scans the Windows machine for drive letters (C:, D:, etc.) and sends that list to the Server.
* The Result: Only after this scan completes will the individual items (e.g., "Used disk space on C:") be created and start appearing in your Latest Data or Items list.

![wind_discovery](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/wind_discovery.png)

After discovery

![wind_data](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/windows_data.png)



### User parameters windows

### Install Linux by Zabbix agent active

Template

* https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/os/linux_active


### User parameters linux



## Zabbix Linux by SNMP

Monitoring Linux via SNMP in Zabbix is achieved by installing snmpd, configuring community strings (v2c) or authentication (v3), and linking the "Linux by SNMP" template. This template discovers file systems, network interfaces, and CPU metrics via UDP port 161, with Zabbix integrations providing pre-configured monitoring

Active Monitoring Note: While SNMP is primarily a polling (passive) protocol, Zabbix handles the metrics efficiently. If you require true "active" agent functionality (where the agent sends data to the server), ***it is recommended to use the "Linux by Zabbix agent active" template instead of SNMP***

### Install

https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/os/linux_snmp_snmp

## All Templates

All templates

* https://www.zabbix.com/integrations


https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/os/windows_agent_active

https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/os/linux_active

https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/os/linux_snmp_snmp

https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/net/fortinet/fortigate_snmp?at=release/6.4

![all templates](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/templates.png)


## Mysql tuning tbd


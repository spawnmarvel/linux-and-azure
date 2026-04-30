# Zabbix monitor VM's and SNMP default

In Zabbix, the distinction between Active and Passive modes relates to which entity initiates the communication and data transfer between the Zabbix Server/Proxy and the Zabbix Agent.

## Passive Mode (Server-Poll) Active Mode (Agent-Push)

![p_vs_a](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitor_vms_snmp_default/images/p_vs_a.png)

# Table of Contents

1. [Zabbix monitor VM's and SNMP default](#zabbix-monitor-vms-and-snmp-default)  
   1.1 [Tasks](#tasks)  
   1.2 [Stack and current version](#stack-and-current-version)  
   1.3 [Zabbix Windows/Linux by Zabbix agent active](#zabbix-windowslinux-by-zabbix-agent-active)  
       - [Install Windows by Zabbix agent active](#install-windows-by-zabbix-agent-active)  
       - [Install Linux by Zabbix agent active](#install-linux-by-zabbix-agent-active)  
       - [Templates](#templates)  
       - [User parameters](#user-parameters)  
   1.4 [Zabbix Linux by SNMP](#zabbix-linux-by-snmp)  
       - [Install](#install)  
       - [Templates](#templates-1)  
   1.5 [Mysql tuning tbd](#mysql-tuning-tbd)

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

https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/os/windows_agent_active

### Install Linux by Zabbix agent active

https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/os/linux_active


### Templates

https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/os/linux_active

https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/os/windows_agent_active

### User parameters

#### Windows

#### Linux

## Zabbix Linux by SNMP

### Install

https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/os/linux_snmp_snmp

### Templates

https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/os/linux_snmp_snmp

## Mysql tuning tbd


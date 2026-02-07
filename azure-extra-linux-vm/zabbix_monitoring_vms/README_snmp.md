# Zabbix and SNMP

Simple Network Management Protocol is an Internet Standard protocol for collecting and organizing information about managed devices on IP networks and for modifying that information to change device behaviour.

You may want to use SNMP monitoring on devices such as printers, network switches, routers or UPS that usually are SNMP-enabled and on which it would be impractical to attempt setting up complete operating systems and Zabbix agents.

All solutions:

https://www.zabbix.com/integrations/snmp#generic_snmp_snmp

## SNMP agent

https://www.zabbix.com/documentation/7.0/en/manual/config/items/itemtypes/snmp


### SNMP traps

https://www.zabbix.com/documentation/7.0/en/manual/config/items/itemtypes/snmp

## SNMP general

How it Works: The Players
The SNMP ecosystem relies on three main components working together:

1. The SNMP Manager (NMS): This is the "boss" or the central software (like SolarWinds, PRTG, or Zabbix). It asks the questions and collects the data.

2. The Managed Device: The hardware you're monitoring (e.g., a Cisco router).

3. The SNMP Agent: A small piece of software running inside the managed device. It gathers local data and hands it over when the Manager asks.

The "Dictionary": MIBs and OIDs
Since every device is different, SNMP uses a structured system to keep data organized:

- OID (Object Identifier): A unique numeric string that points to a specific piece of data. For example, the OID for "system uptime" is always the same series of numbers.

- MIB (Management Information Base): A text file that acts as a translator. It converts those long numeric OIDs into human-readable labels (e.g., "sysUpTime").

Key SNMP Operations

![snmp words](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/snmp_words.png)


## SNMP zabbix
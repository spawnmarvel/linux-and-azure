# SNMP


## Telegraf Best Practices: SNMP Plugin


https://www.influxdata.com/blog/telegraf-best-practices-snmp-plugin/


We will focus on this Telegraf SNMP Input Plugin.

![SNMP input Plugin](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/telegraf/images/toplogy.png)

https://github.com/influxdata/telegraf/tree/master/plugins/inputs/snmp

There is also Telegraf SNMP Trap Input Plugin

https://github.com/influxdata/telegraf/blob/master/plugins/inputs/snmp_trap/README.md#snmp-trap-input-plugin

## Telegraf SNMP Input Plugin

* Telegraf installed on a Linux server
* Monitor remote Windows
* Monitor remote Linux

Toplogy:

* After gathering all SNMP data you could:
* Have output plugin to AMQP (AMQP server can be moved within the segements of network)
* Have output zabbix direct plugin after AMQP or as-is.

Lets first set up telegraf with logfile

Lets configure SNMP and log data to file



# Misc

## Zabbix SNMP Monitoring - Beginner's Guide to Setup and Configuration

https://www.youtube.com/watch?v=R3JDBxU4sow

## Zabbix SNMP Monitoring traps

https://www.youtube.com/watch?v=eXVD8ukx4-Q

## More Zabbix

https://www.youtube.com/watch?v=R3JDBxU4sow

https://medium.com/@MetricFire/step-by-step-guide-to-monitoring-your-snmp-devices-with-telegraf-cc3370a2d247



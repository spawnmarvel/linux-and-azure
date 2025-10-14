# SNMP


## Telegraf SNMP Plugin


We will focus on this Telegraf SNMP Input Plugin.

![SNMP input Plugin](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/telegraf/images/toplogy.png)

https://github.com/influxdata/telegraf/tree/master/plugins/inputs/snmp

There is also Telegraf SNMP Trap Input Plugin

https://github.com/influxdata/telegraf/blob/master/plugins/inputs/snmp_trap/README.md#snmp-trap-input-plugin

## Telegraf SNMP Input Plugin Best Practices

* Telegraf installed on a Linux server
* Monitor remote Windows
* Monitor remote Linux

Toplogy:

* After gathering all SNMP data you could:
* Have output plugin to AMQP (AMQP server can be moved within the segements of network)
* Have output zabbix direct plugin after AMQP or as-is.

Lets first set up telegraf with logfile

Lets configure SNMP and log data to file

https://www.influxdata.com/blog/telegraf-best-practices-snmp-plugin/

### Windows Windows (Windows Server 2022 Datacenter Azure Edition) enable SNMP

Step 1: Install SNMP

First we need to enable SNMP.

Server Manager, go to features, Under Select features, select SNMP Service, and then confirm by clicking on Add Features.

![snmp_win](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/telegraf/images/snmp_win.png)

Step 2: Configure SNMP

![snmp_service](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/telegraf/images/snmp_service.png)

Tick all the boxes

![enable](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/telegraf/images/enable.png)

For now we will add the comunity string and use only localhost

Navigate to the Security tab and configure SNMP settings, including the community string and the IP address/host filter list, according to your security compliance requirements. For example, add the community name "public" with READ ONLY rights and allow SNMP packets from at least the address of your monitoring server.

To ensure proper configuration, make sure your SNMP agent is set up correctly to accept SNMP packets from authorized sources. This step is crucial for remote access and effective troubleshooting of network devices.

That's it! You have successfully configured SNMP on your Windows machine.

![config](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/telegraf/images/config.png)


https://blog.paessler.com/how-to-enable-snmp-on-your-operating-system


# Misc

## Zabbix SNMP Monitoring - Beginner's Guide to Setup and Configuration

https://www.youtube.com/watch?v=R3JDBxU4sow

## Zabbix SNMP Monitoring traps

https://www.youtube.com/watch?v=eXVD8ukx4-Q

## More Zabbix

https://www.youtube.com/watch?v=R3JDBxU4sow

https://medium.com/@MetricFire/step-by-step-guide-to-monitoring-your-snmp-devices-with-telegraf-cc3370a2d247



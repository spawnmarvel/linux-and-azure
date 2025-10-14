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

![config](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/telegraf/images/config2.png)


### Powershell SNMP


```ps1
# Define the IP address of your SNMP-enabled device
$DeviceIP = '127.0.0.1' # Replace with your device's actual IP address

# Define the SNMP community string (commonly 'public' for read-only access)
$CommunityString = 'public'

# Create a new OleSNMP object
$SNMP = New-Object -ComObject olePrn.OleSNMP

# Open the connection to the device
# The parameters are: IP address, community string, SNMP version (2 for v2c), timeout in milliseconds
$SNMP.Open($DeviceIP, $CommunityString, 2, 1000)

# Define the OID you want to query (e.g., device description)
# You will need to find the correct OID for the specific information you want to retrieve.
# MIB browsers and manufacturer documentation are helpful for this.
$OID_DeviceDescription = ".1.3.6.1.2.1.1.1.0" # sysDescr.0

# Get the value for the specified OID
$DeviceDescription = $SNMP.Get($OID_DeviceDescription)

# Display the retrieved data
Write-Host "Device Description: $DeviceDescription"

# Close the SNMP connection
$SNMP.Close()

```


![powershell test](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/telegraf/images/powershell_test.png)

How do you obtain the numerical OID for a named object in SNMP?

With pain:

How do you read an OID?

```log

```

https://www.dpstele.com/snmp/what-does-oid-network-elements.php#:~:text=Search%20Within%20the%20MIB%20File,OID%20in%20a%20hierarchical%20structure.


iReasoning MIB Browser

https://www.ireasoning.com/download.shtml






### Install Telegraf on (Windows Server 2022 Datacenter Azure Edition) get SNMP data

### Install Telegraf remote host get SNMP data

https://blog.paessler.com/how-to-enable-snmp-on-your-operating-system


# Misc

## Zabbix SNMP Monitoring - Beginner's Guide to Setup and Configuration

https://www.youtube.com/watch?v=R3JDBxU4sow

## Zabbix SNMP Monitoring traps

https://www.youtube.com/watch?v=eXVD8ukx4-Q

## More Zabbix

https://www.youtube.com/watch?v=R3JDBxU4sow

https://medium.com/@MetricFire/step-by-step-guide-to-monitoring-your-snmp-devices-with-telegraf-cc3370a2d247



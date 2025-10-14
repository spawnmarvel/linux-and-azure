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

![mib browser](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/telegraf/images/mib_browser.png)

The iReasoning MIB Browser is highly popular because it makes the process of working with SNMP straightforward. Here is a step-by-step guide on how to typically use it, broken down into three main phases: **Setup, Discovery, and Operation.**

***

## How to Use iReasoning MIB Browser (read it and skip to Use snmpwalk from remote machine)

### Phase 1: Setup (Loading the MIB Files)

Before you can talk to a device using its proprietary names, the MIB browser needs to know those names.

1.  **Download and Install:** Install the iReasoning MIB Browser (Personal Edition is often free for private use).
2.  **Obtain MIB Files:** Download the custom MIB files for the network device you are targeting (e.g., a Cisco router, a server, a printer). These are typically found on the manufacturer's support website.
3.  **Load MIBs:**
    * Go to **File** $\rightarrow$ **Load MIBs**.
    * Browse to the location of the MIB files you downloaded and select the ones you need (you can often select multiple files at once).
    * The browser will parse the files, and the corresponding tree structure will appear in the left-hand panel under the standard OID branches.

### Phase 2: Discovery (Connecting to the Device)

This step tells the browser which device to query and what credentials to use.

1.  **Enter Agent Address:** In the **Address** field (usually near the top toolbar), enter the **IP address** or hostname of your SNMP-enabled network device (the SNMP *Agent*).
2.  **Configure SNMP Credentials:**
    * Set the **Port** (default is usually 161).
    * Set the **SNMP Version** (v1, v2c, or v3).
    * If using **v1 or v2c**, enter the **Read Community** string (default is often `public`).
    * If using **v3**, click the **Advanced** button to set the security parameters (Username, Security Level, Auth Protocol, Priv Protocol, etc.).
3.  **Select Starting OID (Optional but Recommended):** The default OID in the OID field might be the root of the entire MIB tree. For targeted operations, you can select a more specific node in the MIB Tree on the left (like the `system` branch, or your vendor's specific branch) as your starting point.

### Phase 3: Operation (Querying the Data)

Once configured, you can perform various SNMP operations to retrieve or modify data.

| SNMP Operation | Icon/Button | How to Use | Purpose |
| :--- | :--- | :--- | :--- |
| **Get** | **Go** button (or equivalent) | 1. Select a specific MIB object in the left-hand tree. 2. Click the **Get** button. | Retrieves the **single, current value** of the selected Object Identifier (OID). |
| **GetNext** | **Go** dropdown | 1. Select a specific MIB object. 2. Click **GetNext**. | Retrieves the value of the **next sequential OID** in the MIB tree. This is essential for iterating through tables. |
| **Walk** | **Go** dropdown | 1. Select a MIB object or branch (like `interfaces`). 2. Click **Walk**. | Performs a series of `GetNext` operations automatically to retrieve **all values** in a branch or sub-tree and displays them in the result table. This is the fastest way to map out all available information. |
| **Table View** | **Go** dropdown | 1. Select an OID that represents a MIB table (e.g., `ifTable`). 2. Click **Table View**. | Presents the tabular MIB data (like a list of network interfaces) in an easy-to-read, spreadsheet-like format. |
| **Set** | **Set** button | 1. Select a writable MIB object. 2. Enter a new **Value** and its data type. 3. Click **Set**. | **Writes a new value** to the device to change a configuration setting (e.g., change the system contact email). *Requires the Write Community string for v1/v2c or the appropriate v3 credentials.* |

### Key Benefit: OID Translation

Throughout this process, the MIB Browser displays the **human-readable symbolic names** in the MIB tree, and when you select a node, the **numerical OID** is clearly displayed in the OID field, performing the translation for you instantly.

## Use snmpwalk from remote machine

First we must add the allowed host, update the snmp service and add ip of the server where we will run snmpwalk.

https://www.youtube.com/watch?v=pxM-t751l0Y

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



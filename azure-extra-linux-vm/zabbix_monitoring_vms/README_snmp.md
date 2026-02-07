# Zabbix and SNMP

Simple Network Management Protocol is an Internet Standard protocol for collecting and organizing information about managed devices on IP networks and for modifying that information to change device behaviour.

You may want to use SNMP monitoring on devices such as printers, network switches, routers or UPS that usually are SNMP-enabled and on which it would be ***impractical to attempt setting up complete operating systems and Zabbix agents.***

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


- SNMPv1: The original. It’s old, slow, and uses "Community Strings" (basically clear-text passwords) which are very insecure.

- SNMPv2c: Improved performance and error handling. Still uses insecure Community Strings. This is currently the most widely used version.

- SNMPv3: The gold standard. It adds encryption and authentication, ensuring that only authorized managers can see or change data.

Is it still relevant? SNMP remains the universal language for basic monitoring. If it has an Ethernet port, it almost certainly speaks SNMP.


### 3. Option B: Turn a Linux VM into an SNMP Device

If you want to keep it simple, just install the standard SNMP agent (snmpd) on your other Linux VMs. This turns the VM itself into a "Managed Device."

Step 1: On your "Device" VM, install the agent: sudo apt install snmpd

Step 2: Edit /etc/snmp/snmpd.conf to allow your Zabbix VM IP to poll it.

Step 3: Restart the service: sudo systemctl restart snmpd

The Learning Moment: Now, from your Zabbix VM, run snmpwalk -v 2c -c public <Device_IP>. You will see hundreds of lines of data (CPU, RAM, Disk) coming from the other VM via the SNMP protocol.

### 4. Learning the "Dark Arts": SNMP Traps

Since you aren't using a VPN, you can practice Traps (the device sending an emergency alert to Zabbix).

Configure the snmptrapd service on your Zabbix VM.

On your simulated device VM, use the command snmptrap to manually "fire" a fake alert (e.g., "Power Supply Failed").

Watch as the alert appears in your Zabbix dashboard in real-time.

***Important Azure Settings***

Because these VMs are in the same VNet, they can talk to each other on any port by default. However, if you have hardened your Network Security Group (NSG), you must explicitly allow:

- UDP Port 161: For Polling (Manager -> Device).

- UDP Port 162: For Traps (Device -> Manager).

## 3. Option B: Turn a Linux VM into an SNMP Device

Rg-uksnmp-0001

vmsnmpsim01, 192.168.3.6

vmzabbix02, 192.168.3.5


Step 1: Installing the Agent
Log into your "Device" VM (not the Zabbix one) and run:

```bash
sudo apt update -y
sudo apt install snmpd -y

snmpd --version

# NET-SNMP version:  5.9.4.pre2
```

Step 2: The Configuration (The Critical Part)
By default, SNMP agents only listen to themselves (localhost). We need to tell it to listen to the network and recognize your Zabbix VM.

```bash

# take a backup
sudo cp snmpd.conf snmpd.conf_bck

# 1. Open the config file: 

sudo nano /etc/snmp/snmpd.conf

# 2. Listen to the Network: Find the line agentAddress udp:127.0.0.1:161. 
# Change it to: agentAddress udp:161 (This tells it to listen on all interfaces.)

agentAddress udp:161

# 3. Set the Community String: Find the section for rocommunity. 
# Comment out the default and add your own: rocommunity learning-lab <Zabbix_VM_Internal_IP> (This is your "password." 
# Replacing <Zabbix_VM_Internal_IP> with your Zabbix VM's internal IP adds a layer of security.)

rocommunity learning-lab 192.168.3.5

# Save and Exit: Ctrl+O, Enter, Ctrl+X.

sudo grep 'agentAddress*' /etc/snmp/snmpd.conf
sudo grep 'rocom*' /etc/snmp/snmpd.conf

# Step 3: Restart and Verify

sudo systemctl restart snmpd
```

3. The Big Test (From vmzabbix02)
Log into vmzabbix02 (192.168.3.5) and run the "walk" to see if the door is open:

Give the computer the "Dictionary" (The professional way)
To make snmpwalk understand words like system, sysName, or hrStorage, you need to install the MIBs on your Zabbix VM:

```bash
sudo apt update -y
# install client
sudo apt install snmp

# Install the downloader:
sudo apt install snmp-mibs-downloader -y

# Download the files:
sudo download-mibs
```

Tell SNMP to use them: Open the client config: 

```bash
sudo nano /etc/snmp/snmp.conf 
# (not snmpd.conf!) 
# Find the line that says mibs : and put a # in front of it to comment it out: #mibs :

```
Now walk it

```bash
snmpwalk -v 2c -c learning-lab 192.168.3.6 system

```

log

```log
 snmpwalk -v 2c -c learning-lab 192.168.3.6 system
SNMPv2-MIB::sysDescr.0 = STRING: Linux vmsnmpsim01 6.14.0-1017-azure #17~24.04.1-Ubuntu SMP Mon Dec  1 20:10:50 UTC 2025 x86_64
SNMPv2-MIB::sysObjectID.0 = OID: NET-SNMP-MIB::netSnmpAgentOIDs.10
DISMAN-EVENT-MIB::sysUpTimeInstance = Timeticks: (51572) 0:08:35.72
SNMPv2-MIB::sysContact.0 = STRING: Me <me@example.org>
SNMPv2-MIB::sysName.0 = STRING: vmsnmpsim01
SNMPv2-MIB::sysLocation.0 = STRING: Sitting on the Dock of the Bay
SNMPv2-MIB::sysServices.0 = INTEGER: 72
SNMPv2-MIB::sysORLastChange.0 = Timeticks: (0) 0:00:00.00
SNMPv2-MIB::sysORID.1 = OID: SNMP-FRAMEWORK-MIB::snmpFrameworkMIBCompliance
SNMPv2-MIB::sysORID.2 = OID: SNMP-MPD-MIB::snmpMPDCompliance
SNMPv2-MIB::sysORID.3 = OID: SNMP-USER-BASED-SM-MIB::usmMIBCompliance
SNMPv2-MIB::sysORID.4 = OID: SNMPv2-MIB::snmpMIB
SNMPv2-MIB::sysORID.5 = OID: SNMP-VIEW-BASED-ACM-MIB::vacmBasicGroup
SNMPv2-MIB::sysORID.6 = OID: TCP-MIB::tcpMIB
SNMPv2-MIB::sysORID.7 = OID: UDP-MIB::udpMIB
```

Why this matters for Zabbix

Even though Zabbix mainly uses numerical OIDs in the background for efficiency, having these MIBs on the Zabbix server allows you to use "SNMP Get" and "SNMP Walk" tools within the Zabbix Web UI more easily when you are troubleshooting.

## Zabbix pull snmp

Now that you’ve proven the "plumbing" works with snmpwalk and snmptrap, it’s time to move into the Zabbix Web UI. This is where we turn those raw text lines into persistent monitoring, graphs, and triggers.
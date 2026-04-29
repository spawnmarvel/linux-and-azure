# Zabbix and SNMP

Simple Network Management Protocol is an Internet Standard protocol for collecting and organizing information about managed devices on IP networks and for modifying that information to change device behaviour.

You may want to use SNMP monitoring on devices such as printers, network switches, routers or UPS that usually are SNMP-enabled and on which it would be ***impractical to attempt setting up complete operating systems and Zabbix agents.***

All solutions:

https://www.zabbix.com/integrations/snmp#generic_snmp_snmp

# Table of Contents: Zabbix & SNMP Monitoring


# Table of Contents: Zabbix & SNMP Monitoring

- [🔹 Zabbix and SNMP Overview](#zabbix-and-snmp)
- [🔹 SNMP Agent](#snmp-agent)
- [🔹 SNMP Traps](#snmp-traps)
- [🔹 SNMP General Concepts](#snmp-general)
  - [How it Works: The Players](#how-it-works-the-players)
  - [The Dictionary: MIBs and OIDs](#the-dictionary-mibs-and-oids)
  - [Key SNMP Operations](#key-snmp-operations)
- [🔹 Option B: Turn a Linux VM into an SNMP Device](#3-option-b-turn-a-linux-vm-into-an-snmp-device)
  - [Step 1: Installing the Agent](#step-1-installing-the-agent)
  - [Step 2: Configuration](#step-2-the-configuration-the-critical-part)
  - [Step 3: Restart and Verify](#step-3-restart-and-verify)
- [🔹 Option B: Pull from Zabbix](#3-option-b-turn-a-linux-vm-into-an-snmp-device-pull-from-zabbix)
  - [Step 1: Installing the Agent](#step-1-installing-the-agent-1)
  - [Step 2: The Configuration](#step-2-the-configuration-the-critical-part-1)
  - [Step 3: Restart and Verify](#step-3-restart-and-verify-1)
- [🔹 The Big Test (From vmzabbix02)](#3-the-big-test-from-vmzabbix02)
  - [Give the computer the "Dictionary"](#give-the-computer-the-dictionary-the-professional-way)
  - [Tell SNMP to use them](#tell-snmp-to-use-them-open-the-client-config)
- [🔹 Zabbix Pull SNMP](#zabbix-pull-snmp)
- [🔹 Learning the "Dark Arts" (Traps)](#4-learning-the-dark-arts-snmp-traps-push-to-zabbix-todo)

---


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

## 3. Option B: Turn a Linux VM into an SNMP Device pull from zabbix

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

# Those steps are not required for Zabbix to function. Zabbix is perfectly happy talking in "numerical" OIDs ($1.3.6.1...$).
# Install the downloader:
sudo apt install snmp-mibs-downloader -y

# Download the files:
sudo download-mibs
```

Tell SNMP to use them: Open the client config: 

```bash
# The step are not required for Zabbix to function. Zabbix is perfectly happy talking in "numerical" OIDs ($1.3.6.1...$).
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

![snmp host](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/snmp_host.png)

Check status after 1-2 min

![snmp host status](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/snmp_status.png)

data

```log
vmsnmpsim01 Linux: System location6m 49s	Sitting on the Dock of the Bay		History	
vmsnmpsim01 Linux: System name 6m 49s	vmsnmpsim01		History	
vmsnmpsim01 Linux: Uptime (network) 19s	00:27:20	+00:00:30	Graph	
vmsnmpsim01 Linux: System object ID 6m 49s	NET-SNMP-MIB::netSnmpAgentOIDs.10		History

```

## 4. Learning the "Dark Arts": SNMP Traps, push to zabbix

The Workflow
1. The Device sends a trap packet (UDP port 162).
2. snmptrapd (Linux daemon) on the Zabbix server receives it.
3. A Receiver Script (Perl) parses the trap into a format Zabbix understands.
4. Zabbix Server reads the parsed data and triggers an alert.

Lets assume this: 
* vmsnmpsim01 (192.168.3.6) running ubuntu 24.04 is a new vm, nothing is installed. 
* vmzabbix02 (192.168.3.5) running same linux distro and is the zabbix server.

Since you are starting with a fresh Ubuntu 24.04 VM for the simulator (vmsnmpsim01), we will take it from zero to a fully functioning SNMP node.

1. Setup the "Managed Device" (vmsnmpsim01)
Log into 192.168.3.6. We need to install the SNMP daemon and configure it to "listen" for Zabbix.

### Step 1: Install the SNMP Daemon

```bash
sudo apt update && sudo apt install snmpd -y

snmpd -version
# NET-SNMP version:  5.9.4.pre2
``` 

Step 2: Configuration

```bash
# The default config is very restrictive. We need to open it up for your Zabbix server.

# Backup the original:
sudo cp /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.bak

# Edit the file:
sudo nano /etc/snmp/snmpd.conf

# Update these specific lines:

# Listening IP: Change agentAddress  udp:127.0.0.1:161 
# to:
agentAddress udp:161 # (This allows connections from the network).

# Access Control: Add your community string and link it to the Zabbix IP:
rocommunity learning-lab 192.168.3.5

# Restart and Enable:

sudo systemctl restart snmpd
sudo systemctl enable snmpd
```

2. Setup the "Manager" (vmzabbix02)

Log into 192.168.3.5. We need to ensure Zabbix is ready to "pull" data and "receive" traps.

Step 1: Install Tools & MIBs
To make your life easier during troubleshooting, install the client tools and the "dictionaries" (MIBs).

```bash
sudo apt update
sudo apt install snmp snmp-mibs-downloader -y
sudo download-mibs
```

Log example

```txt
Downloading documents and extracting MIB files.
This will take some minutes.

In case this process fails, it can always be repeated later by executing
/usr/bin/download-mibs again.

RFC1155-SMI: 119 lines.
RFC1213-MIB: 2613 lines.
NOTE: SMUX: ignored.
SMUX-MIB: 158 lines.
CLNS-MIB: 1294 lines.
RFC1381-MIB: 1007 lines.
RFC1382-MIB: 2627 lines.
RFC1414-MIB: 131 lines.
MIOX25-MIB: 708 lines.
[...]

```

Note: Edit /etc/snmp/snmp.conf and comment out the line mibs : (add a #) to allow the tools to use the downloaded MIBs.


### Step 2: Configure SNMP Trap Receiving

Since we want to practice the "Dark Arts," let's set up the trap receiver.

```bash

# Install the handler:
sudo apt install snmptrapd -y

# Configure the trap daemon:
sudo nano /etc/snmp/snmptrapd.conf
# Add: 

authCommunity log,execute,net learning-lab

# Enable Traps in Zabbix Server:
sudo nano /etc/zabbix/zabbix_server.conf
Set StartSNMPTrapper=1.

# Restart Zabbix:
sudo systemctl restart zabbix-server snmptrapd
```
3. Verification Table

```bash
# Test Polling
snmpwalk -v 2c -c learning-lab 192.168.3.6 system
```

A list of system info (Uptime, Name, etc.)
```txt
SNMPv2-MIB::sysDescr.0 = STRING: Linux vmsnmpsim01 6.17.0-1011-azure #11~24.04.2-Ubuntu SMP Wed Mar 25 22:46:36 UTC 2026 x86_64
SNMPv2-MIB::sysObjectID.0 = OID: NET-SNMP-MIB::netSnmpAgentOIDs.10
DISMAN-EVENT-MIB::sysUpTimeInstance = Timeticks: (135955) 0:22:39.55
SNMPv2-MIB::sysContact.0 = STRING: Me <me@example.org>
SNMPv2-MIB::sysName.0 = STRING: vmsnmpsim01
SNMPv2-MIB::sysLocation.0 = STRING: Sitting on the Dock of the Bay
SNMPv2-MIB::sysServices.0 = INTEGER: 72
SNMPv2-MIB::sysORLastChange.0 = Timeticks: (0) 0:00:00.00
[...]
```
Test connectivity

```bash
nc -vzu 192.168.3.6 161
Connection to 192.168.3.6 161 port [udp/snmp] succeeded!
```

Simulate Trap

```bash
sudo touch /var/log/zabbix/zabbix_traps.log
sudo chown zabbix:zabbix /var/log/zabbix/zabbix_traps.log
sudo chmod 664 /var/log/zabbix/zabbix_traps.log

# check that the file exists
cat /var/log/zabbix/zabbix_traps.log
## else create it
# Create the file
sudo touch /var/log/zabbix/zabbix_traps.log

# Give ownership to the zabbix user, but allow the snmp group to write to it
sudo chown zabbix:zabbix /var/log/zabbix/zabbix_traps.log
sudo chmod 664 /var/log/zabbix/zabbix_traps.log

# Run this command to see which user is running the snmptrapd process:
ps aux | grep snmptrapd
# Add the snmp user to the zabbix group so it has permission
sudo usermod -a -G zabbix Debian-snmp

# restart
sudo systemctl daemon-reload
sudo systemctl restart snmptrapd

# test it
snmptrap -v 2c -c learning-lab 127.0.0.1 '' 1.3.6.1.4.1.3.1.1 1.3.6.1.4.1.3.1.1 s "Manual Test"
```

Check journal for log for trap data.


```bash
sudo journalctl -u snmptrapd -n 20

``` 
```txt
pr 29 19:46:18 vmzabbix02 snmptrapd[32552]: NET-SNMP version 5.9.4.pre2 AgentX subagent connected
Apr 29 19:46:18 vmzabbix02 snmptrapd[32552]: NET-SNMP version 5.9.4.pre2
Apr 29 19:47:13 vmzabbix02 snmptrapd[32552]: 2026-04-29 19:47:13 UDP: [127.0.0.1]:43085->[127.0.0.1]:162 [UDP: [127.0.0.1]:43085->[127.0.0.1>
Apr 29 19:47:13 vmzabbix02 snmptrapd[32552]: DISMAN-EVENT-MIB::sysUpTimeInstance = Timeticks: (395025) 1:05:50.25        SNMPv2-MIB::snmpTra>
```



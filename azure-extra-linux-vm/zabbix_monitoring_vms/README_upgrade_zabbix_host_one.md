# Upgrade zabbix singel host

## Upgrade procedure matrix version

https://www.zabbix.com/documentation/current/en/manual/installation/upgrade

## Debian/Ubuntu

https://www.zabbix.com/documentation/7.0/en/manual/installation/upgrade/packages/debian_ubuntu

### Upgrade procedure


#### 0 Take a snapshot of the vm in Azure

Create a snapshot of a virtual hard disk

https://learn.microsoft.com/en-us/azure/virtual-machines/snapshot-copy-managed-disk?tabs=portal


To recover using a snapshot, you must create a new disk from the snapshot, then either deploy a new VM, and use the managed disk as the OS disk, or attach the disk as a data disk to an existing VM.


Create a VM from a specialized disk using PowerShell

https://learn.microsoft.com/en-us/azure/virtual-machines/attach-os-disk?tabs=portal


#### 1 Stop Zabbix processes

#### 2 Back up Zabbix database

#### 3 Back up Zabbix configuration files, PHP files, and Zabbix binaries


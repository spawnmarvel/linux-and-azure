# MS Tutorials for Linux

https://learn.microsoft.com/en-us/azure/virtual-machines/windows/quick-create-bicep?tabs=CLI


![Linux tutorials ](https://github.com/spawnmarvel/linux-and-azure/blob/main/images/linux_tutorials.jpg)

Just follow next steps

![Next step ](https://github.com/spawnmarvel/linux-and-azure/blob/main/images/next_steps.jpg)

## Quickstart: Create an Ubuntu Linux virtual machine using a Bicep file

Edit size from Standard_D2as_v4 to Standard_B2ms

https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-bicep?tabs=CLI

### Modifications, since the template was not made for redeploy when resources existed.

* i.e default template was deployed, tried to change SKU, but it prompted error about vnet elready existing
* * This will happen when the subnet is declared as a child resource. 
* *  It is instead recommended to create all the subnets in the array property inside of the vnet, like you are doing with the first subnet in the above code sample:
* * https://github.com/Azure/bicep/issues/4653

``` bash
// Not able to redeploy due to hardcode subnet
// Edit from

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    [...]

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  parent: virtualNetwork
  name: subnetName
  properties: {
    addressPrefix: subnetAddressPrefix
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

//To
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    // 1. It is instead recommended to create all the subnets in the array property inside of the vnet, like you are doing with the first subnet in the above code sample:
    // 1. https://github.com/Azure/bicep/issues/4653
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      [...]

// And had to update reference subnet id on the NetworkInterface
// From
subnet: {
            id: subnet.id
          }

// To
subnet: {
             // 1.2 And had to update reference subnet id on the NetworkInterface
            id: resourceId('Microsoft.Network/VirtualNetworks/subnets', virtualNetworkName, subnetName)
          }

```
### Add a data disk, this was alreadu in the bicep just added name:'${vmName}-dataDiskLun0'

``` bash
  // 2. Add a data disk start
 dataDisks:[
        {
          diskSizeGB:8
          lun:0
          createOption:'Empty'
          name:'${vmName}-dataDiskLun0'
        }
      ]
      // It must be mounted after
      // https://learn.microsoft.com/en-us/azure/virtual-machines/linux/attach-disk-portal?tabs=ubuntu
     // 2. Add a datadisk end
```

## Login,  view outputs from deployments in main

* output adminUsername string = adminUsername
* output hostname string = publicIPAddress.properties.dnsSettings.fqdn
* output sshCommand string = 'ssh ${adminUsername}@${publicIPAddress.properties.dnsSettings.fqdn}'

![Output ](https://github.com/spawnmarvel/linux-and-azure/blob/main/images/linux_output.jpg)


```bash
ssh user@serverip
```


## Attach an new data disk

Ref the disk is already attached in the bicep file

![SDA, B, C](https://github.com/spawnmarvel/linux-and-azure/blob/main/images/sda_b_c.jpg)

Or deploy a VM with just OS and then use the portal to attach a data disk to a Linux VM
https://learn.microsoft.com/en-us/azure/virtual-machines/linux/attach-disk-portal?tabs=ubuntu

### Find the disk

Now find the disk, prepare it, mount and verify it.

``` bash
# 1 Find the disk
lsblk

sda       8:0    0   30G  0 disk
sdb       8:16   0   16G  0 disk
sdc       8:32   0    8G  0 disk


# 1.1 
lsblk -o NAME,HCTL,SIZE,MOUNTPOINT | grep -i "sd"

sda     0:0:0:0      30G
├─sda1             29.9G /
├─sda14               4M
└─sda15             106M /boot/efi
sdb     0:0:0:1      16G
└─sdb1               16G /mnt
sdc     1:0:0:0       8G


# In this example, the disk that was added was sdc. It's a LUN 0 and is 8GB.

# 3 Prepare a new empty disk (Important If you are using an existing disk that contains data, skip to mounting the disk. The following instructions will delete data on the disk.)
# The following example uses parted on /dev/sdc, which is where the first data disk will typically be on most VMs. 
# Replace sdc with the correct option for your disk. We're also formatting it using the XFS filesystem.
sudo parted /dev/sdc --script mklabel gpt mkpart xfspart xfs 0% 100%
sudo mkfs.xfs /dev/sdc1
sudo partprobe /dev/sdc1

// 4 Mount the disk
sudo mkdir /datadrive
sudo mount /dev/sdc1 /datadrive

# 5 Verify mount
lsblk

[...]
sdc       8:32   0    8G  0 disk
└─sdc1    8:33   0    8G  0 part /datadrive

# 6 To ensure that the drive is remounted automatically after a reboot, it must be added to the /etc/fstab file.
#  It's also highly recommended that the UUID (Universally Unique Identifier) is used in /etc/fstab to refer to the drive rather than just the device name (such as, /dev/sdc1)
#  To find the UUID of the new drive, use the blkid utility:
sudo blkid

[...]
/dev/sdc1: UUID="5fb6228d-e3d4-4666-a291-8c311bbe6c7f" TYPE="xfs" PARTLABEL="xfspart" PARTUUID="a149db51-bd45-4ad7-876a-39b140b19ee1"

# Next, open the /etc/fstab file in a text editor. 
// Add a line to the end of the file, using the UUID value for the /dev/sdc1 device that was created in the previous steps, and the mountpoint of /datadrive. 
sudo nano /etc/fstab

UUID=5fb6228d-e3d4-4666-a291-8c311bbe6c7f   /datadrive   xfs   defaults,nofail   1   2
# CTRL + X and Y

# 7 Verify mount
lsblk -o NAME,HCTL,SIZE,MOUNTPOINT | grep -i "sd"

# Enter drive
cd /datadrive
pwd

# Display Usage in Megabytes and Gigabytes
df -h

```
NOTE: Later removing a data disk without editing fstab could cause the VM to fail to boot. Most distributions provide either the nofail and/or nobootwait fstab options. These options allow a system to boot even if the disk fails to mount at boot time. Consult your distribution's documentation for more information on these parameters.

The nofail option ensures that the VM starts even if the filesystem is corrupt or the disk does not exist at boot time. Without this option, you may encounter behavior as described in Cannot SSH to Linux VM due to FSTAB errors


### Restart Linux VM and verify disk

```bash

lsblk

lsblk -o NAME,HCTL,SIZE,MOUNTPOINT | grep -i "sd"

sda     0:0:0:0      30G
├─sda1             29.9G /
├─sda14               4M
└─sda15             106M /boot/efi
sdb     0:0:0:1      16G
└─sdb1               16G /mnt
sdc     1:0:0:0       8G
└─sdc1                8G /datadrive

```

0. Restart VM after mount

```bash
az vm stop --resource-group --name

az vm start --resource-group --name 

ssh user@ipaddress

sda     0:0:0:0      30G
├─sda1             29.9G /
├─sda14               4M
└─sda15             106M /boot/efi
sdb     0:0:0:1      16G
└─sdb1               16G /mnt
sdc     1:0:0:0       8G
└─sdc1                8G /datadrive

```
Linux drive letter 

Applications and users should not care what SCSI device letter a particular storage gets, because those sdX letters can change and are expected to change.
Instead, the storage should be addressed by some unique and permanent property, such as the LUN WWID or filesystem UUID.

https://access.redhat.com/discussions/6004221


1. Add some a file/folder to OS and data disk: folder1/file1, datadrive/folder2/file2
2. Restart VM
3. Verify data

```bash
cd folder1/
/folder1$ ls
file1
cd /datadrive/
/datadrive$ ls 
folder2
/datadrive$ cd folder2/
/datadrive/folder2$ ls
file2
```

4. Press redeploy VM
5. Verify data

## Tutorial: Create and Manage Linux VMs with the Azure CLI


* Create and connect to a VM
* Select and use VM images
* View and use specific VM sizes
* Resize a VM
* View and understand VM state

```bash

rgName='Rg-az-quickstarts-001'
az group create --name $rgName --location uksouth

# Create virtual machine

az vm create \
    --resource-group $rgName \
    --name vmhodor0045 \
    --image Canonical:0001-com-ubuntu-server-focal:20_04-lts:latest \
    --size Standard_B2ms \
    --admin-username azureuser \
    --generate-ssh-keys

# Take note of the publicIpAddress, this address can be used to access the virtual machine.
# Connect to VM
ssh azureuser@ip-address

# Understand VM images
# To see a list of the most commonly used images, use the az vm image list command.
az vm image list --output table

# A full list can be seen by adding the --all parameter. The image list can also be filtered by --publisher or –-offer. In this example, 
# the list is filtered for all images, published by Canonical, with an offer that matches UbuntuServer.
az vm image list --offer UbuntuServer --publisher Canonical --all --output table


```
NOTE:
Canonical has changed the Offer names they use for the most recent versions. Before Ubuntu 20.04, the Offer name is UbuntuServer. For Ubuntu 20.04 the Offer name is 0001-com-ubuntu-server-focal and for Ubuntu 22.04 it's 0001-com-ubuntu-server-jammy.

Understand VM sizes

```bash
# Find available VM sizes
az vm list-sizes --location eastus2 --output table


# Create VM with specific size
rgName='Rg-az-quickstarts-001'

az vm create \
    --resource-group $rgName \
    --name vmhodor0045 \
    --image Canonical:0001-com-ubuntu-server-focal:20_04-lts:latest \
    --size Standard_B2ms \
    --admin-username azureuser \
    --generate-ssh-keys

# After a VM has been deployed, it can be resized to increase or decrease resource allocation. 
# You can view the current of size of a VM with az vm show:
rgName='Rg-az-quickstarts-001'
az vm show --resource-group $rgName --name vmhodor0045 --query hardwareProfile.vmSize

"Standard_B2ms"

{
  "additionalCapabilities": null,
  "applicationProfile": null,
  "availabilitySet": null,
  "billingProfile": null,
  "capacityReservation": null,
  "diagnosticsProfile": null,
  "evictionPolicy": null,
  "extendedLocation": null,
  "extensionsTimeBudget": null,
  "hardwareProfile": {
    "vmSize": "Standard_B2ms",
    "vmSizeProperties": null


# Before resizing a VM, check if the desired size is available on the current Azure cluster. The az vm list-vm-resize-options command returns the list of sizes.
rgName='Rg-az-quickstarts-001'
az vm list-vm-resize-options --resource-group $rgName --name vmhodor0045 --query [].name

# If the desired size is available, the VM can be resized from a powered-on state, however it is rebooted during the operation. 
# Use the az vm resize command to perform the resize.
rgName='Rg-az-quickstarts-001'
az vm resize --resource-group $rgName --name vmhodor0045 --size Standard_B4ms

# If the desired size is not on the current cluster, the VM needs to be deallocated before the resize operation can occur. Use the az vm deallocate command to stop and deallocate the VM. Note, when the VM is powered back on, any data on the temp disk may be removed. 


```

VM power states

* Starting, Running, Stopping, Stopped.
* 
* Deallocating, Indicates that the virtual machine is being deallocated.
* Deallocated, Indicates that the virtual machine is removed from the hypervisor but still available in the control plane. Virtual machines in the Deallocated state do not incur compute charges.
* -, Indicates that the power state of the virtual machine is unknown.

```bash
# Find the power state
rgName='Rg-az-quickstarts-001'
vmName='vmhodor0045'
az vm get-instance-view \
    --name $vmName \
    --resource-group $rgName \
    --query instanceView.statuses[1] --output table

Code                Level    DisplayStatus
------------------  -------  ---------------
PowerState/running  Info     VM running

```

Management tasks

```bash

# Get IP address
rgName='Rg-az-quickstarts-001'
vmName='vmhodor0045'
az vm list-ip-addresses --resource-group $rgName --name $vmName --output table

# Stop virtual machine
az vm stop --resource-group $rgName --name $vmName

About to power off the specified VM...
It will continue to be billed. To deallocate a VM, run: az vm deallocate.

# Dealloctaed virtual machine
az vm deallocate --resource-group $rgName --name $vmName

# Start virtual machine
az vm start --resource-group $rgName --name $vmName

# Deleting a resource group also deletes all resources in the resource group, like the VM, virtual network, and disk. 
az group delete --name $rgName --no-wait --yes


```
https://learn.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-manage-vm


## Tutorial - Manage Azure disks with the Azure CLI


* OS disks and temporary disks
* Data disks
* Standard and Premium disks
* Disk performance
* Attaching and preparing data disks
* Disk snapshots


Default disks

When an Azure virtual machine is created, two disks are automatically attached to the virtual machine.
*  Operating system disk, Operating system disks can be sized up to 2 TB
* * disk is labeled /dev/sda by default. 
* Temporary disk - Temporary disks use a solid-state drive that is located on the same Azure host as the VM. Temp disks are highly performant and may be used for operations such as temporary data processing. If VM is moved, data stored is removed.
* * disks are labeled /dev/sdb and have a mountpoint of /mnt

Azure data disks
* To install applications and store data, additional data disks can be added. 

VM disk types
* Standard disks - backed by HDDs, and delivers cost-effective storage while still being performant. Standard disks are ideal for a cost effective dev and test workload.
* Standard disks - backed by HDDs, and delivers cost-effective storage while still being performant. Standard disks are ideal for a cost effective dev and test workload.

NOTE: VM sizes with an S in the size name, typically support Premium Storage. For example, DS-series, DSv2-series, GS-series, and FS-series VMs support premium storage


Create and attach disks

Attach disk at VM creation

```bash
az group create --name myResourceGroupDisk --location uksouth

az vm create \
  --resource-group myResourceGroupDisk \
  --name myVM \
  --image UbuntuLTS \
  --size Standard_DS2_v2 \
  --admin-username azureuser \
  --generate-ssh-keys \
  --data-disk-sizes-gb 128 128
```
Attach disk to existing VM

```bash
az vm disk attach \
    --resource-group myResourceGroupDisk \
    --vm-name myVM \
    --name myDataDisk \
    --size-gb 128 \
    --sku Premium_LRS \
    --new
```
Prepare data disks (mount, datadrive, fstab, restart)

Look above "Quickstart: Create an Ubuntu Linux virtual machine using a Bicep file"

```bash
ssh
parted
mkfs.xfs
partprobe
mkdir datadrive && mount
blkid
nano /etc/fstab

```

Take a disk snapshot

* Azure creates a read only, point-in-time copy of the disk. Azure VM snapshots are useful to quickly save the state of a VM before you make configuration changes.
* VM can be restored using a snapshot.
* When a VM has more than one disk, a snapshot is taken of each disk independently of the others. To take application consistent backups, consider stopping the VM before you take disk snapshots. Alternatively, use the Azure Backup service, which enables you to perform automated backups while the VM is running.

Create snapshot

```bash
rgName="Rg-iac-linux-fu-xxxxx"
myVm="simpleLinuxVM-xxxxxx"
az vm show -g $rgName -n $myVm

osdiskid=$(az vm show -g $rgName -n $myVm --query "storageProfile.osDisk.managedDisk.id" -o tsv)
echo $osdiskid

```

(

  Install nginx so we have a reference

  https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-20-04#step-6-getting-familiar-with-important-nginx-files-and-directories

  Add NSG inbound HTTP, sudo systemctl enable nginx, restart server and verify it.

  ![nginx ](https://github.com/spawnmarvel/linux-and-azure/blob/main/images/nginx.jpg)

)

Now that you have the ID, use az snapshot create to create a snapshot of the disk.

```bash
az snapshot create --resource-group $rgName --source "$osdiskid" --name osDisk-backup
# hm.... not correct, maybe some bash or windows stuff
(BadRequest) The source blob uri file:///C:/Program Files/Git/subscriptions/
# if echo it looks correct
 echo $osdiskid
/subscriptions/
```
Do the rest in the Portal.

Create snap, osDisk-backup01

 ![snap ](https://github.com/spawnmarvel/linux-and-azure/blob/main/images/snap.jpg)



Delete the vm

```bash
az vm delete --resource-group $rgName --name $myVm

```

Create disk from snapshot

```bash
az disk create --resource-group $rgName --name mySnapshotDisk --source osDisk-backup01

```

![disk ](https://github.com/spawnmarvel/linux-and-azure/blob/main/images/disk.jpg)


Restore virtual machine from snapshot

```bash
az resource list --resource-group $rgName --query [].name
[...]
"osDisk-backup01",
"mySnapshotDisk",
```

Go to portal and Public IP address-> Dissocitate

Go back to the disk and create VM

![NEW VM ](https://github.com/spawnmarvel/linux-and-azure/blob/main/images/NEWVM.jpg)

Error

![ERROR ](https://github.com/spawnmarvel/linux-and-azure/blob/main/images/error.jpg)

from the Bicep file which the initial VM was deployd

```json
var securityProfileJson = {
  uefiSettings: {
    secureBootEnabled: true
    vTpmEnabled: true
  }
  securityType: securityType
}
```
There is always something....maybe better to take a backup and restore from that.

Reattach data disk
All data disks need to be reattached to the virtual machine (datadrives etc)


https://learn.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-manage-disks



## Tutorial - How to use cloud-init to customize a Linux virtual machine in Azure on first boot


* Create a cloud-init config file
* Create a VM that uses a cloud-init file
* View a running Node.js app after the VM is created
* Use Key Vault to securely store certificates
* Automate secure deployments of NGINX with cloud-init

Cloud-init is a widely used approach to customize a Linux VM as it boots for the first time. You can use cloud-init to install packages and write files, or to configure users and security. As cloud-init runs during the initial boot process, there are no additional steps or required agents to apply your configuration.

Cloud-init also works across distributions. For example, you don't use apt-get install or yum install to install a package. Instead you can define a list of packages to install. Cloud-init automatically uses the native package management tool for the distro you select.

### (cloud-init support for virtual machines in Azure)

![Cloud init ](https://github.com/spawnmarvel/linux-and-azure/blob/main/images/cloudinit.jpg)

cloud-init support https://learn.microsoft.com/en-us/azure/virtual-machines/linux/using-cloud-init



(Examples of cloud-init :https://cloudinit.readthedocs.io/en/latest/reference/examples.html)


Continue and create cloud-init.yaml, view also the-cloud-init folder

```yaml
#cloud-config
package_update: true
package_upgrade: true
# pre update and upgrade our instance on its first boot https://docs.fuga.cloud/how-to-use-cloud-init

packages:
  - nginx
write_files:
  - owner: www-data:www-data
    path: /etc/nginx/sites-available/default
    content: |
      server {
        listen 80;
        listen 127.0.0.1;
      }
runcmd:
  - service nginx restart
  
```

```bash
az group create --name Rg-test-cloud-init-004 --location uksouth

az vm create --resource-group Rg-test-cloud-init-004 --name myAutomatedVM --image UbuntuLTS --admin-username azureuser --generate-ssh-keys --custom-data cloud-init.yaml

az vm open-port --port 80 --resource-group Rg-test-cloud-init-004 --name myAutomatedVM
```

It takes a few minutes for the VM to be created, the packages to install, and the app to start. 

There are background tasks that continue to run after the Azure CLI returns you to the prompt. It may be another couple of minutes before you can access the app. 

http://<publicIpAddress> in the address bar.

![Nginx ](https://github.com/spawnmarvel/linux-and-azure/blob/main/images/nginx2.jpg)


### Inject certificates from Key Vault

* Create an Azure Key Vault
* Generate or upload a certificate to the Key Vault
* Create a secret from the certificate to inject in to a VM
* Create a VM and inject the certificate

Create an Azure Key Vault

```bash

keyvault_name=mykeyvault01x0178qa

az group create --name Rg-test-cloud-init-005 --location uksouth

az keyvault create --resource-group Rg-test-cloud-init-005  --name $keyvault_name --enabled-for-deployment

```

Generate certificate and store in Key Vault
* For production use, you should import a valid certificate signed by trusted provider with az keyvault certificate import. 
* For this tutorial, the following example shows how you can generate a self-signed certificate with az keyvault certificate create that uses the default certificate policy:

```bash
az keyvault certificate create --vault-name $keyvault_name --name mycert01x01 --policy "$(az keyvault certificate get-default-policy --output json)"
```

![certificate ](https://github.com/spawnmarvel/linux-and-azure/blob/main/images/certificate.jpg)

https://learn.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-automate-vm-deployment


Prepare certificate for use with VM
* To use the certificate during the VM create process, obtain the ID of your certificate with az keyvault secret list-versions. The VM needs the certificate in a certain format to inject it on boot, so convert the certificate with az vm secret format. The following example assigns the output of these commands to variables for ease of use in the next steps:

```bash
secret=$(az keyvault secret list-versions --vault-name $keyvault_name --name mycert01x01 --query "[?attributes.enabled].id" --output tsv)

vm_secret=$(az vm secret format --secret "$secret" --output json)
```

Create secure VM

```bash
az vm create --resource-group Rg-test-cloud-init-005 --name myVMWithCerts --image UbuntuLTS --admin-username azureuser --generate-ssh-keys --custom-data cloud-init-secured.yaml --secrets "$vm_secret"
```

Open 443

```bash
az vm open-port \
    --resource-group Rg-test-cloud-init-005 \
    --name myVMWithCerts \
    --port 443
```

https://<publicIpAddress> in the address bar. 

![self signed ](https://github.com/spawnmarvel/linux-and-azure/blob/main/images/selfsigned.jpg)

CLIGetDefaultPolicy

![self signed ](https://github.com/spawnmarvel/linux-and-azure/blob/main/images/selfsigneddefault.jpg)


## Tutorial: Create a custom image of an Azure VM with the Azure CLI

https://learn.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-custom-images


Next Tutorial: Create and manage Azure virtual networks for Linux virtual machines with the Azure CLI

https://learn.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-virtual-network
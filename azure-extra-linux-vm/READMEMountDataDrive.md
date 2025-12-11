
## Fileshare not supported

https://learn.microsoft.com/en-us/answers/questions/1410701/linux-image-6-2-0-1016-azure-cifs-is-not-supported

## Use the portal to attach a data disk to a Linux VM

* Find the virtual machine
* Attach a new disk
* Connect to the Linux VM to mount the new disk

```bash

# Find the disk
lsblk -o NAME,HCTL,SIZE,MOUNTPOINT | grep -i "sd"

# sda     0:0:0:0       30G
# ├─sda1              29.9G /
# ├─sda14                4M
# └─sda15              106M /boot/efi
# sdb     0:0:0:1        8G
# └─sdb1                 8G /mnt
# sdc     1:0:0:0        4G

# In this example, the disk that was added was sdc. It's a LUN 0 and is 4GB.

```
Prepare a new empty disk

If you are using an existing disk that contains data, skip to mounting the disk. The following instructions will delete data on the disk.

```bash
# The following example uses parted on /dev/sdc, which is where the first data disk will typically be on most VMs. Replace sdc with the correct option for your disk. 

sudo parted /dev/sdc --script mklabel gpt mkpart xfspart xfs 0% 100%

sudo mkfs.xfs /dev/sdc1

sudo partprobe /dev/sdc1

# Use the partprobe utility to make sure the kernel is aware of the new partition and filesystem. 


```
Mount the disk

```bash
sudo mkdir /datadrive

sudo mount /dev/sdc1 /datadrive

# To ensure that the drive is remounted automatically after a reboot, it must be added to the /etc/fstab file. It's also highly recommended that the UUID (Universally Unique Identifier) is used in /etc/fstab to refer to the drive rather than just the device name (such as, /dev/sdc1).

sudo blkid
# /dev/sdc1: UUID="df5b511c-d869-48e1-8c18-3f6cd688ce9d" BLOCK_SIZE="4096" TYPE="xfs" PARTLABEL="xfspart" PARTUUID="74845b7b-0be6-44e0-86bd-161cdfb8e4b4"

# Next, open the /etc/fstab file in a text editor. Add a line to the end of the file, using the UUID value for the /dev/sdc1 device that was created in the previous steps, and the mountpoint of /datadrive. Using the example from this article, the new line would look like the following:

UUID="df5b511c-d869-48e1-8c18-3f6cd688ce9d"   /datadrive   xfs   defaults,nofail   1   2

sudo nano /etc/fstab

```
Verify the disk

```bash
lsblk -o NAME,HCTL,SIZE,MOUNTPOINT | grep -i "sd"
# sda     0:0:0:0       30G
# ├─sda1              29.9G /
# ├─sda14                4M
# └─sda15              106M /boot/efi
# sdb     0:0:0:1        8G
# └─sdb1                 8G /mnt
# sdc     1:0:0:0        4G
# └─sdc1                 4G /datadrive

# You can see that sdc is now mounted at /datadrive.

```

Create file and restart vm
```bash
cd /datadrive

sudo mkdir test01

# Reboot and verify disk

```
https://learn.microsoft.com/en-us/azure/virtual-machines/linux/attach-disk-portal?tabs=ubuntu

https://github.com/spawnmarvel/azure-automation/blob/main/azure-extra-linux-vm/READMEQuickstartsLinuxMS.md


## Resize disk (it was 4gb) and resize it on the vm also

```bash

df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/root        29G  4.2G   25G  15% /
tmpfs           2.0G     0  2.0G   0% /dev/shm
tmpfs           781M  1.1M  780M   1% /run
tmpfs           5.0M     0  5.0M   0% /run/lock
/dev/sdb15      105M  6.1M   99M   6% /boot/efi
/dev/sda1       4.0G  3.4G  628M  85% /datadrive
/dev/sdc1       7.8G   28K  7.4G   1% /mnt
tmpfs           391M  4.0K  391M   1% /run/user/1000

```
* 1.just log in your VM;
* 2.use sudo cfdisk to enter the permission of cfdisk on your VM's terminal;
* 3.choose Resize button, press enter, yes, enter
* 4.accept the default, should be used + avaliable
* 5.verify new GB
* 6.choose write button to sync the new partion to disk
* 6.choose quit
* 7.use sudo resize2fs /dev/sda1

```bash

sudo resize2fs /dev/sda1
# resize2fs 1.46.5 (30-Dec-2021)
resize2fs: Bad magic number in super-block while trying to open /dev/sda1
# Couldn't find valid filesystem superblock.

# resize2fs is not the default file system on ubuntu

df -t
# Filesystem     Type  1K-blocks    Used Available Use% Mounted on
# /dev/sda1      xfs     4182016 3539924    642092  85% /datadrive

# xfs is
# xfs file system support only extend not reduce. So if you want to resize the filesystem use xfs_growfs rather than resize2fs.

sudo xfs_growfs /dev/sda1

# [...]
data blocks changed from 1048064 to 2096891

```
* 8.Restart or reboot your virtual machine

```bash
sudo shutdown now -r

df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/sdc1       8.0G  3.5G  4.6G  43% /datadrive

sudo su -

cd /datadrive

ls
# all data is there
buildkit    engine-id  network   plugins   swarm  volumes
containers  image      overlay2  runtimes  tmp
```

https://askubuntu.com/questions/1384983/vmware-more-disk-space

![Azure resources](https://github.com/spawnmarvel/linux-and-azure/blob/main/images/resize_datadisk.jpg)
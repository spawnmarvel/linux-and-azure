#  linuxcommand.org

https://linuxcommand.org/index.php

## Learning the Shell

One of our software engineers spent a couple of hours writing a C++ program that would look through all the user's directories and add up the space they were using and make a listing of the results.


When I heard about the problem, I realized I could perform this task with this single line:

```bash
du -s * | sort -nr > $HOME/user_space_report.txt
```

## Contents

### 1 What is "the Shell"?

You're not operating as root, are you?

Unless you absolutely need administrative privileges, do not operate as the superuser.

### 2 Navigation

```bash
# work dir
pwd

# list files
ls

# go to
cd

# working dir
cd .

# parent dir
cd ..

# home 
cd ~

```

***Important facts about file names***

* .filesThatStartsWith . are hidden

```bash
# use
ls -a
```
* File1 is not file, case sensitive
* Linux has no file extension, does not care, but program does
* File names use: ., -, _ and no space

### 3 Looking Around

```bash
# list files and dirs
ls
# list files in bin
ls /bin
# list files long format
ls -l /etc

# view text files, one page at the time
# cd /var/log
less syslog
# Page Up/Down and q for quit, G = go to end of file

# classify a files content
file syslog
syslog: ASCII text, with very long lines (390)

file zabbix-agent/
zabbix-agent/: directory

file dmesg.1.gz
dmesg.1.gz: gzip compressed data, was "dmesg.0", last modified: Wed Jul  3 09:55:54 2024, max compression, from Unix, original size modulo 2^32 40595

```

![Long format](https://github.com/spawnmarvel/linux-and-azure/blob/main/images/longformat.jpg)

### 4 A Guided Tour

```bash
# It's time to take our tour. The table below lists some interesting places to explore. This is by no means a complete list, but it should prove to be an interesting adventure.

cd
ls
file
# for text files use 
less

/

file *
# list all files and types

/boot 
# kernel

state *
# show stats for each file

/etc
#configuration files

sudo su
# mys be root
/etc/passwd
# each user
/etc/fstab
# mounted drives
/etc/hosts
# network and ip that the system knows 
/etc/init.d
# scripts for boot time


/bin
# essential programs for system
/user/bin
# applications for syste users


/usr
# support for usr apps

/var
# files that change while system is running
/var/logs

/lib
# shared libraries (like dll's in win)

/home
# is where users keep their personal work. In general, this is the only place users are allowed to write files. This keeps things nice and clean :-)

/root

/tmp

/dev
# special
# devices that are available to system, in linux devices are treated like file
# you can read/write devices as if they were files
# dev/sda = first hd
# dev/root

/proc
# special
# does not exist, only virtual
# The /proc directory contains little peep holes into the kernel itself.
# Try viewing (/proc/cpuinfo) This entry will tell you what the kernel thinks of the system's CPU.
cd /proc/cpuinfo

/media
# The /media directory is used for mount points.
# This process of attaching a device to the tree is called mounting. For a device to be available, it must first be mounted.
# When your system boots, it reads a list of mounting instructions in the /etc/fstab file, which describes which device is mounted at which mount point in the directory tree.
# This takes care of the hard drives,
# but we may also have devices that are considered temporary, such as optical disks and USB storage devices. Since these are removable, they do not stay mounted all the time. 
# The /media directory is used by the automatic device mounting mechanisms found in modern desktop oriented Linux distributions. To see what devices and mount points are used, type 
mount

[...]
/dev/sda1 on /datadrive type xfs
# example

cd /boot
ls -l

[...]

# See the strange notation after the file names?
# Files such as this are called symbolic links. Symbolic links are a special type of file that points to another file. With symbolic links, it is possible for a single file to have multiple names.
lrwxrwxrwx 1 root root       27 Jul  3 10:00 initrd.img.old -> initrd.img-6.5.0-1021-azure
lrwxrwxrwx 1 root root       24 Jul  3 10:00 vmlinuz -> vmlinuz-6.5.0-1023-azure
-rw------- 1 root root 13190088 Nov 21  2023 vmlinuz-6.2.0-1018-azure
-rw------- 1 root root 13613672 Apr 30 15:15 vmlinuz-6.5.0-1021-azure
-rw------- 1 root root 13623304 Jun 12 18:56 vmlinuz-6.5.0-1023-azure
lrwxrwxrwx 1 root root       24 Jul  3 10:00 vmlinuz.old -> vmlinuz-6.5.0-1021-azure

# These programs might expect the kernel to simply be called "vmlinuz". Here is where the beauty of the symbolic link comes in. 
# By creating a symbolic link called vmlinuz that points to vmlinuz-4.0.36-3, we have solved the problem.

# To create symbolic links, we use the
ln

touch mainfile1
sudo nano mainfile1
# add txt This is the main

ln mainfile1 main
# add a sumlink to a new file
sudo nano mainfile1
# add txt update after symlink
cat main
# all changes are reflected via the link
# This is the main
# update after symlink

```

### 5 Manipulating Files

```bash
cp
# copy files and directories
mv
# move or rename files and directories
rm
# remove files and directories
mkdir

```
Wildcards

![Wildcard ](https://github.com/spawnmarvel/linux-and-azure/blob/main/images/wildcard.jpg)

Using wildcards 

![Patterns ](https://github.com/spawnmarvel/linux-and-azure/blob/main/images/pattern.jpg)


```bash
find *.yml
#compose.yml

find rmq*
# rmq-non-ssl
# rmq-non-ssl/compose.yml
# rmq-non-ssl/rabbitmq.conf
# rmq-non-ssl/Dockerfile
# [...]

find send*zabbix*
# send_2_zabbix_data.sh

# We can use wildcards with any command that accepts filename arguments.

find
cp
move
rm
#etc

# The mkdir command is used to create directories. To use it, you simply type:
mkdir testfolder

# lets make a loop and create some files

sudo nano mk_files

~/testfolder$ cat mk_files.sh
#!/bin/bash
for i in {1..25}
do
    touch "file_$i"
done

# run it
bash mk_files.sh

ls

file_1   file_11  file_13  file_15  file_17  file_19  file_20  file_22  file_24  file_3  file_5  file_7  file_9
file_10  file_12  file_14  file_16  file_18  file_2   file_21  file_23  file_25  file_4  file_6  file_8  mk_files.sh

```

***Be careful with rm!***

Before you use rm with wildcards, try this helpful trick: construct your command using ls instead. 

By doing this, you can see the effect of your wildcards before you delete files. 

After you have tested your command with ls, recall the command with the up-arrow key and then substitute rm for ls in the command.


```bash

ls *_1

# file_1

ls *_1*

# file_1  file_10  file_11  file_12  file_13  file_14  file_15  file_16  file_17  file_18  file_19

rm *_1*

# ls
file_2   file_21  file_23  file_25  file_4  file_6  file_8  mk_files.sh
file_20  file_22  file_24  file_3   file_5  file_7  file_9

```

#### Using Commands with Wildcards

```bash

# Copy all files from directory with names "*file*" to a existing directory 
cp testfolder/*file* testfolder1

# Copy all files in the current working directory with names "*file_2*" to a existing directory one folder up
cp *file_2* . ./testfolder2

```

https://linuxcommand.org/lc3_lts0050.php

### 6 Working with Commands

```bash
```
https://linuxcommand.org/lc3_lts0060.php

### 7 I/O Redirection
### 8 Expansion
### 9 Permissions
### 10 Job Control


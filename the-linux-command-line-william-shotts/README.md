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
```
Continue with more navigation

https://linuxcommand.org/lc3_lts0040.php

### 5 Manipulating Files
### 6 Working with Commands
### 7 I/O Redirection
### 8 Expansion
### 9 Permissions
### 10 Job Control


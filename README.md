# linux-and-azure all things guide

# Set Up a Firewall with UFW on Ubuntu

https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm-security/README.md

# Azure Linux Ubuntu

## Install Azure CLI on Windows

https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli

## Azure Linux joined to domain login with account

https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli

Powershell (using az cli)

```bash
az --version

```

Log in to a Linux virtual machine in Azure by using Azure AD and OpenSSH

https://learn.microsoft.com/en-us/azure/active-directory/devices/howto-vm-sign-in-azure-ad-linux#configure-role-assignments-for-the-vm


Add IAM on the VM
* IAM->Virtual Machine Administrator Login, Reader, Desktop Virtualization Power On Off Contributor
* For username@domain.com

```bash

az extension add --name ssh
az extension show --name ssh

# login as username@domain.com
az login --tenant  TENANT-ID

az account set --subscription "SUBSSCRIPTION-NAME-VIEW-VM"

az ssh vm -n vmName -g resourceGroupName

# You can now run sudo as username@domain.com

sudo mysql -u root -p

```

Upgrade AZ CLI
```bash

az --version

az upgrade --yes

```


## VSC Terminal Shell Integration

By default, the shell integration script should automatically activate on supported shells launched from VS Code.

https://code.visualstudio.com/docs/terminal/shell-integration

## Bash it, Git BASH

Git for Windows provides a BASH emulation used to run Git from the command line. *NIX users should feel right at home, as the BASH emulation behaves just like the "git" command in LINUX and UNIX environments.

https://gitforwindows.org/

## ssh ps1

```ps1
# First, verify if the OpenSSH client is installed:
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'

# If you see output like this, it's installed:
# Name  : OpenSSH.Client~~~~0.0.1.0
# State : Installed

# If it's not installed, proceed to the next step.
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

# The simplest way to connect is using the ssh command:
ssh user@10.10.10.11

```
SSH with Key-Based Authentication (Recommended)

```ps1

# Generate a Key Pair (on your PowerShell machine):
ssh-keygen

# This will ask you where to save the key (the default is usually fine:
# C:\Users\your_username\.ssh\id_rsa, and for a passphrase (optional, but recommended for extra security)

```
It creates two files

* id_rsa (private key - keep this secret!)
* id_rsa.pub (public key - this is what you'll copy to the Ubuntu machine)

There are several ways to do this. The easiest (if you have password access initially) is ssh-copy-id:

```ps1
ssh-copy-id username@ubuntu_ip_address
```
If ssh-copy-id isn't available, you can manually copy the public key:
1. Display the public key: type C:\Users\your_username\.ssh\id_rsa.pub
2. Copy the entire output.
3. SSH to the Ubuntu machine using a password.
4. Create the .ssh directory if it doesn't exist: mkdir -p ~/.ssh
5. Edit the ~/.ssh/authorized_keys file (create it if it doesn't exist): nano ~/.ssh/authorized_keys
6. Paste the public key into the file. Save and close the file.
7. Set the correct permissions: chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys

Connect without a Password

```ps1

# Now, when you run
ssh username@ubuntu_ip_address
# it should connect without asking for a password (if you used a passphrase, it will ask for that).
```



## Bash quick reference

Page1

![Quick 1 ](https://github.com/spawnmarvel/linux-and-azure/blob/main/images/page1.jpg)

Page 2
![Quick 2 ](https://github.com/spawnmarvel/linux-and-azure/blob/main/images/page2.jpg)

https://github.com/spawnmarvel/quickguides/blob/main/bash/bash.quickref.pdf

## Filesystem Hierarchy

1. Filesystem Hierarchy

| Path      | Description
|-----------| -----------------------------------------------
| /         | - The root directory of the entire filesystem hierarchy, everything is nestled under this directory.
| /bin -    | Essential ready-to-run programs (binaries), includes the most basic commands such as ls and cp.
| /boot -   | Contains kernel boot loader files.
| /dev -    | Device files.
| /etc -    | Core system configuration directory, should hold only configuration files and not any binaries.
| /home -   | Personal directories for users, holds your documents, files, settings, etc.
| /lib -    | Holds library files that binaries can use.
| /media -  | Used as an attachment point for removable media like USB drives.
| /mnt -    | Temporarily mounted filesystems.
| /opt -    | Optional application software packages.
| /proc -   | Information about currently running processes.
| /root -   | The root user's home directory.
| /run -    | Information about the running system since the last boot.
| /sbin -   | Contains essential system binaries, usually can only be ran by root.
| /srv -    | Site-specific data which are served by the system.
| /tmp -    | Storage for temporary files
| /usr -    | This is unfortunately named, most often it does not contain user files in the sense of a home folder. This is meant for user installed software and utilities, however that is not to say you can't add personal directories in there. Inside this directory are sub-directories for /usr/bin, /usr/local, etc.
| /var -    | Variable directory, it's used for system logging, user tracking, caches, etc. Basically anything that is subject to change all the time.

ref https://linuxjourney.com/lesson/filesystem-hierarchy

https://linuxjourney.com/

![File system ](https://github.com/spawnmarvel/linux-and-azure/blob/main/images/linuxfilesys2.jpg)

Unix philosphy

* Do one thing and do it well - Write programs that do one thing and do it well. Write programs to work together. Write programs to handle text streams, because that is a universal interface.
* Everything is file - Ease of use and security is offered by treating hardware as a file.
* Small is beautiful.
* Store data and configuration in flat text files - Text file is a universal interface. Easy to create, backup and move to another system.
* Use shell scripts to increase leverage and portability - Use shell script to automate common tasks across various UNIX / Linux installations.
* Chain programs together to complete complex task - Use shell pipes and filters to chain small utilities that perform one task at time.
* Choose portability over efficiency.
* Keep it Simple, Stupid (KISS).

https://bash.cyberciti.biz/guide/Unix_philosophy


## Grep it

```bash

# Get data source name for example
cat telegraf.conf | grep "data_source_name"

# Get Hostname info
cat zabbix_agentd.conf | grep "Hostname*"

# error/ fail
sudo cat zabbix_server.log | grep 'error*'
sudo cat zabbix_server.log | grep 'fail*'

```
## Log all things in one tail


To much tail with -f?

```bash

sudo tail -f grafana.log

sudo tail -20 /var/log/syslog

sudo tail -50 zabbix_server.log

# Output to new file some data from main log
sudo tail -f /var/log/zabbix/zabbix_server.log | grep -E "error|warning|Error|Warning|ERROR|WARNING" >> /home/imsdal/zabbix_errors_warnings.log
```

View logs all

```bash
# if no logs here
cd /var/logs

# Kernel, applications, system events, errors and warning
sudo tail -f /var/log/syslog

# On many modern Ubuntu systems, /var/log/messages is often a symbolic link to /var/log/syslog.
sudo tail -f /var/log/messages
```


## Check if port is exhausted

* ss: Stands for "Socket Statistics
* -l (or --listening):
* -t (or --tcp)
* -n (or --numeric):

So, ss -ltn means: "Show me all listening TCP sockets, using numeric addresses and port numbers.

Recv-Q (Receive-Queue):

Recv-Q shows the number of incoming connection requests that are currently queued by the kernel, waiting for the application


```bash
ss -ltn

```
### Linux Command Reference

This table organizes common Linux commands into logical categories to help you quickly find what you need, with corrected descriptions and clearer examples.

| Category | Command | Description | Example |
| :------- | :------ | :---------- | :------ |
| **Getting Help** | `man` | Display the manual page for a command | `man ls` |
| | `help` | Display help for shell built-in commands | `help pwd` |
| | `whatis` | Display a one-line description of a command | `whatis ls` |
| | `whereis` | Locate the binary, source, and manual pages for a command | `whereis wget` |
| | `which` | Show the full path of an executable command | `which wget` |
| **Privilege & Environment** | `sudo` | Execute a command as another user (usually root) | `sudo apt update` |
| | `sudo -i` | Start an interactive shell as the root user | `sudo -i` |
| | `su` | Switch user identity | `su - username` (switch to user's environment) |
| | `export` | Set an environment variable for the current shell session and its child processes | `export MY_VAR="some_value"` |
| | `env` | Print all environment variables | `env` |
| | `echo "$PATH"` | Print the value of a specific environment variable | `echo "$HOME"` |
| **Package Management (APT)** | `sudo apt update` | Update the local package index | `sudo apt update` |
| | `sudo apt upgrade` | Upgrade all installed packages to their latest versions | `sudo apt upgrade -y` |
| | `sudo apt install` | Install new packages | `sudo apt install zip` |
| | `sudo apt remove` | Uninstall packages, keeping configuration files | `sudo apt remove zip` |
| | `sudo apt purge` | Uninstall packages and remove all configuration files | `sudo apt purge zip` |
| | `sudo apt autoremove` | Remove automatically installed packages that are no longer needed | `sudo apt autoremove` |
| | `apt list --installed` | List all installed packages | `apt list --installed` |
| **File & Directory Management** | `ls` | List directory contents | `ls -a` (all files, including hidden), `ls -l` (long format with details), `ls -lt` (long format, sorted by modification time, newest first) |
| | `cd` | Change the current directory | `cd /home/user/documents`, `cd ..` (go up one directory), `cd /` (go to root) |
| | `pwd` | Print the current working directory's path | `/home/user` |
| | `mkdir` | Create new directories | `mkdir new_folder` |
| | `rmdir` | Remove an empty directory | `rmdir empty_folder` |
| | `touch` | Create a new empty file or update the timestamp of an existing file | `touch new_file.txt` |
| | `cp` | Copy files or directories | `cp source.txt destination.txt`, `cp -r folder1 folder2` (copy folder recursively) |
| | `mv` | Move or rename files and directories | `mv old_name.txt new_name.txt`, `mv file.txt /path/to/new/location` |
| | `rm` | Remove files or directories | `rm file.txt`, `rm -r folder_to_delete` (remove folder recursively) |
| **File Content & Manipulation** | `cat` | Display the content of files | `cat my_file.txt`, `cat data.conf \| grep "uid"` |
| | `head` | Output the first part (default 10 lines) of files | `head -n 5 data.conf` |
| | `tail` | Output the last part (default 10 lines) of files; `-f` follows new content | `tail -f logs.txt` |
| | `less` | View file contents page by page (navigate with arrow keys, exit with `q`) | `less large_log.txt` |
| | `more` | View file contents page by page (loads entire file at once, press Enter for more) | `more another_log.txt` |
| | `grep` | Search for patterns in text or files | `grep "error" /var/log/syslog`, `grep -l "pattern" file.txt` (list files containing pattern) |
| | `find` | Search for files in a directory hierarchy | `find . -name "config.conf"` (find in current dir and subdirs) |
| | `diff` | Show the differences between two files | `diff original.txt updated.txt` |
| | `cmp` | Compare two files byte by byte | `cmp file1.txt file2.txt` |
| | `comm` | Compare two sorted files line by line | `comm sorted_file1.txt sorted_file2.txt` |
| | `sort` | Sort lines of text files | `cat names.txt \| sort` (e.g., outputs: `Anna`, `Bob`, `Jim`, `Xavier`) |
| | `nano` | Simple command-line text editor | `nano my_document.txt` |
| **System Information & Resources** | `uname` | Display system information | `uname -a` (all information) |
| | `hostnamectl` | Query and change system hostname, kernel, and OS distribution | `hostnamectl` |
| | `lsblk` | List block devices (disks and partitions) | `lsblk -o NAME,SIZE,MOUNTPOINT` |
| | `df` | Report disk space usage | `df -h` (human-readable sizes) |
| | `du` | Estimate file space usage | `du -h my_folder/` |
| | `mount` | Mount a filesystem or display mounted filesystems | `sudo mount /dev/sdb1 /mnt/data` |
| **Process Management** | `ps` | Report a snapshot of current processes | `ps aux` (display all running processes for all users) |
| | `top` | Display Linux processes dynamically (real-time system activity) | `top` |
| | `htop` | Interactive process viewer (an enhanced version of `top`) | `htop` |
| | `kill` | Send a signal (usually to terminate) to processes by Process ID (PID) | `kill 12345` |
| | `killall` | Kill processes by name | `killall firefox` |
| **User & Permissions** | `whoami` | Print the effective username of the current user | `whoami` |
| | `useradd` | Create a new user account | `sudo useradd -m soloman` (creates user with home directory) |
| | `usermod` | Modify a user account | `sudo usermod -aG sudo newuser` (add user to 'sudo' group) |
| | `passwd` | Change a user's password | `sudo passwd soloman` |
| | `chmod` | Change file permissions | `chmod +x script.sh` (make executable), `chmod 755 file.txt` |
| | `chown` | Change file owner and/or group | `chown newuser:newgroup file.txt` |
| **Networking** | `ifconfig` | Display and configure network interfaces (often replaced by `ip a` on newer systems) | `ifconfig eth0` |
| | `ip a` | Display IP addresses and network interface information (modern alternative to `ifconfig`) | `ip a` (show all interfaces), `ip a show eth0` (show specific interface) |
| | `traceroute` | Trace the route packets take to a network host | `traceroute www.google.com` |
| | `telnet` | Interact with other hosts using the TELNET protocol (often used to test port connectivity) | `telnet example.com 80` |
| | `nc` (netcat) | A versatile tool for reading from and writing to network connections | `nc -zvw10 192.168.1.1 3306` (check if port 3306 is open) |
| | `wget` | Non-interactive network downloader for files from the web | `wget https://cdn.example.com/software.tar.gz` |
| | `curl` | Transfer data with URLs (supports various protocols) | `curl -O https://example.com/data.json` (download with original filename) |
| | `ssh` | OpenSSH remote login client (secure shell) | `ssh user@ipaddress` |
| **Archiving & Compression** | `tar` | Archive files and directories (create `.tar` archives) | `tar -cvf archive.tar folder/` (create), `tar -xvf archive.tar` (extract) |
| | `gzip` | Compress or expand files (creates `.gz` or `.z` files) | `gzip -dk server.sql.gz` (decompress and keep compressed file) |
| | `zip` | Package and compress files into a `.zip` archive | `zip -r my_archive.zip folder_to_compress/` |
| | `unzip` | Extract files from a `.zip` archive | `unzip my_archive.zip -d /target/directory` ||
| **System Services & Applications** | `systemctl` | Control the systemd system and service manager | `systemctl start apache2`, `systemctl status nginx`, `systemctl enable firewall` |
| | `service` | Run a System V init script (start, stop, restart services - often deprecated by `systemctl`) | `sudo service ssh stop` |
| | `git` | Distributed version control system commands | `git --version` (display Git version) |
| | `mariadb` / `mysql` | Commands for MariaDB/MySQL database operations | `sudo mysql -u root -p` (log in as root to database) |
| | `crontab` | Schedule commands to run periodically | `crontab -e` (edit user's crontab), `crontab -l` (list user's crontab) |
| | `sudo ufw enable` | Enable the Uncomplicated Firewall (UFW) | `sudo ufw enable` |
| | `sudo ufw allow` | Allow network traffic on specified ports or services via UFW | `sudo ufw allow 80/tcp`, `sudo ufw allow 'SSH'` |
| | `sudo ufw status` | Display the status and rules of UFW | `sudo ufw status` |
| | `iptables` | Administration tool for IP packet filter rules | `sudo iptables -L` (list rules) |
| | `reboot` | Restart the system | `sudo reboot` (or `sudo shutdown -r now`) |


### https://www.digitalocean.com/community/tutorials/linux-commands

## Script bash, permission and run it


1. touch myScript.sh

2. nano myScript.sh

3. which bash, /bin/bash

```bash

#!/bin/bash

echo "Start script"

sleep 3

echo "End script"

```

3. Run it
```bash

# Run it 1
bash myScript.sh
# Run it 2, Permission denied
./myScript.sh
# Get permission
ls -l
# -rw-r--r-- no execute, add it
sudo chmod +x myScript.sh
# Get permission
ls -l
# -rwxr-xr-r- 
# Run it 3
./myScript.sh

# When we write functions and shell scripts, in which arguments are passed in to be processed, 
# the arguments will be passed int numerically-named variables, e.g. $1, $2, $3
myScript.sh oil gas

# The variable reference, $0, will expand to the current script's name, e.g. my_script.sh

```
myScript.sh
```bash
  GNU nano 6.2                                                                                                          myScript.sh
#!/bin/bash


echo "Input1: $1";
echo "Input2: $2"
### Turn OFF debug mode ###
set +x
# Add more commands without debug mode
result="Combined: $1 and $2"
echo "$result"
echo "cat to var contains:"
rv=$(cat numbers.txt)
echo "$rv"
echo "check sub str in str"
str="Oil is here"
check_it="Oil"
if [[ "$str" =~ .*"$check_it".* ]]; then
   echo "It is here"
```

Example


## Linux Bash Shell Scripting Tutorial Wiki

Bash variables and command substitution

```bash

varName=someValue

# Variables
var_a=Hello # (notice no space)
var_b="Hello World"
n=10
inp="/Home/sales/data.txt"
NOW=$(date)
# Referencing the value of a variable

# # not advisable unless you know what the variable contains
echo $var_a 
# use
echo "$var_a"
echo "$var_b"
echo "$n"
echo "$inp"
echo $NOW

```

Valid variable names
* Should start with either an alphabetical letter or an underscore
* hey, x9, THESQL_STRING, _secret
* Variables names are case-sensitive, just like filenames.


```bash
vech=
echo "$vech"

vech=test
echo "$vech"
test

# Generating Output With printf command
# printf does not provide a new line. 
# You need to provide format string using % directives and escapes to format numeric and string arguments in a 
# way that is mostly similar to the C printf() function

# Format control string syntax is as follows:
printf "%w.pL\n" $varName
# w - Minimum field width.
# p - Display number of digits after the decimal point (precision).
# L - a conversion character. , s - String, d - Integer, e - Exponential, f - Floating point

vech="Car"
printf "%s\n" $vech
Car

printf "%s10.5\n" $vech
Car10.5

no=10
printf "%d\n" $no
10

big=5355765
printf "%e\n" $big
5.355765e+06

sales=25.123
printf "%.f\n" $sales
25
printf "%.2f\n" $sales
25.12

```

Default shell variables value

```bash

echo $shellvar

echo ${shellvar:-DefaultValueHere}
DefaultValueHere

# if $ name is not set use default
echo ${shellvar=Terminator 2}
Terminator 2

# if $ unset, set name to default 
echo ${shellvar:=Terminator 2}

echo $shellvar

# The := syntax
# If the variable is an empty, you can assign a default value. The syntax is:
${var:=defaultValue}

```

The internal field separator
* The global variable IFS is what Bash uses to split a string of expanded into separate words
* By default, the IFS variable is set to three characters: newline, space, and the tab. If you echo $IFS, you won't see anything because those characters


Quoting

```bash
echo "$PATH"
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

echo /etc/*.conf
/etc/adduser.conf /etc/ca-certificates.conf /etc/debconf.conf /etc/deluser.conf [...]

echo "Path: $PATH"
Path: /usr/local/sbin: [...]

echo 'Path: $PATH'
Path: $PATH

```
The Backslash

```bash
# The backslash ( \ ) alters the special meaning of the ' and " i.e. it will escape or cancel the special meaning of the next character.
\b     backspace
\e     an escape character
\n     new line
\r     carriage return
\t     horizontal tab
\v     vertical tab
\\     backslash
\'     single quote
echo "Pizza bill \$22.5"
echo "CIFS path must be \\\\NT-Server-Name\\ShareName"
echo -e "Sr.no\t DVD (price) "

```

Export

```bash
export backup="/nas10/mysql"
echo "bck $backup"
# list all vlocal vars
export
[...]
declare -x backup="/nas10/mysql"
```

Getting User Input Via Keyboard and IFS

```bash
#!/bin/bash
# Read txt
read -p "Enter db name: " name
read -s -p "Enter password: " my_password
echo "Password: $my_passsord"
echo "Db: $name. Do stuff."

# Read nr
read -p "Enter ID one: " n1
read -p "Enter ID two: " n2
read -p "Enter ID three: " n3
echo "ID : $n1, $n2, $n3"

# IFS, the IFS variable worked as token delimiter or separator.
echo "IFS: $IFS .You will see a whitespace which is nothing but a space, a tab, and a newline (default). "

nameservers="ns1.nixcraft.net ns2.nixcraft.net ns3.nixcraft.net"
echo "$nameservers"
read -r ns1 ns2 ns3 <<< "$nameservers"
echo "DNS #1: $ns1"
echo "DNS #2: $ns2"
echo "DNS #3: $ns3"

# Change IFS separator
pwd="gitevivek:x:1002:1002::/home/gitevivek:/bin/sh"
old="$IFS"
echo "$IFS"
# Set IFS to :
IFS=:
read -r login password uid gid info home shell <<< "$pwd"
echo "$login, $password, $uid, $gid, $info, $home, $shell"

# Array -a
# Set the IFS to split on whitespace
IFS=$'\n'
words="one two three"
read -r -a words <<< "$words"
echo "${words[@]}"

# Make array
arr=("one" "two" "three")
echo "${arr[1]}"


```
Perform arithmetic operations
```bash
#!/bin/bash
# Create an integer variable
declare -i sale=100
declare -i bonus=12
total=$(( sale + bonus))
echo "Total sum int = $total"

# input
# input
read -p "Enter two numbers: " x y
ans=$(( x + y ))
echo "$x + $y = $ans"

```
https://bash.cyberciti.biz/guide/Main_Page


## Setting Up Environment Variables on Ubuntu

```bash
# To view all the environment variables
printenv
# or
env

# Setting Environment Variables Temporarily
export MY_VAR="GOT"
printenv MY_VAR

# Setting Environment Variables Permanently
# For system-wide environment variables, edit the /etc/environment file.
sudo nano /etc/environment
MY_VAR="GOT"
# Save and exit the file. For the changes to take effect, either reboot the system or run:
source /etc/environment

# Verify it
printenv
MY_VAR=GOT

# Do a reboot and to be sure and verify it
sudo shutdown -r now
printenv
MY_VAR=GOT
```

![Env var](https://github.com/spawnmarvel/linux-and-azure/blob/main/images/envvar1.jpg)
https://tecadmin.net/setting-up-environment-variables-on-ubuntu/

 
## Linux disks and path/folder information
| The "thing mentioned"     | Description | Example
| -------------------------| ----------- | -------
|/dev/sda | The OS disk is labeled,/dev/sda. OS disk should not be used for applications or data. For applications and data, use data disks | https://learn.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-manage-disks *
|/dev/sdb | Temporary disks use a solid-state drive that is located on the same Azure host as the VM. Temp disks are highly performant and may be used for operations such as temporary data processing.| mountpoint of /mnt *
|/dec/sdc | Data disk(s) | Attach disk at VM creation or Attach disk to existing VM, Prepare data disks, Mount and /etc/fstab
|Linux drive letter | Applications and users should not care what SCSI device letter a particular storage gets, because those sdX letters can change and are expected to change. Instead, the storage should be addressed by some unique and permanent property, such as the LUN WWID or filesystem UUID.| https://access.redhat.com/discussions/6004221

## Initial Server Setup with Ubuntu 20.04

* Step 1 — Logging in as root

The root user is the administrative user in a Linux environment that has very broad privileges.

The next step is setting up a new user account with reduced privileges for day-to-day use.

Once you are logged in as root, you’ll be able to add the new user account. In the future, we’ll log in with this new account instead of root.

* Step 2 — Creating a New User

```bash
# become root
sudo -i
adduser username
# or
sudo adduser username
# list user
getent passwd username

```
* Step 3 — Granting Administrative Privileges

To avoid having to log out of our normal user and log back in as the root account, we can set up what is known as superuser or root privileges for our normal account. 

This will allow our normal user to run commands with administrative privileges by putting the word sudo before the command.

```bash
# become root
sudo -i
usermod -aG sudo username
# Now, when logged in as your regular user, you can type sudo before commands to run them with superuser privileges.

# change to user
su - username

# apt install
apt install zip
E: Could not open lock file /var/lib/dpkg/lock-frontend - open (13: Permission denied)
E: Unable to acquire the dpkg frontend lock (/var/lib/dpkg/lock-frontend), are you root?
sudo apt install zip

```
* Step 4 — Setting Up a Basic Firewall, UFW, or Uncomplicated Firewall

(
    
    Note: ufw by default is initially disabled. 

    ref https://ubuntu.com/server/docs/security-firewall#:~:text=ufw%20%2D%20Uncomplicated%20Firewall,by%20default%20is%20initially%20disabled

    Note: using IPV6

    ref https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-ubuntu-22-04

)

```bash
# Applications can register their profiles with UFW upon installation. These profiles allow UFW to manage these applications by name.
sudo ufw app list
Available applications:
  OpenSSH

# We need to make sure that the firewall allows SSH connections so that we can log back in next time. We can allow these connections by typing:
sudo ufw allow OpenSSH
Rules updated
Rules updated (v6)

# Afterwards, we can enable the firewall by typing:
sudo ufw enable
Command may disrupt existing ssh connections. Proceed with operation (y|n)? y
Firewall is active and enabled on system startup

#
sudo ufw status
Status: active

To                         Action      From
--                         ------      ----
OpenSSH                    ALLOW       Anywhere
OpenSSH (v6)               ALLOW       Anywhere (v6)

```
As the firewall is currently blocking all connections except for SSH, if you install and configure additional services, you will need to adjust the firewall settings to allow traffic in.

You can learn some common UFW operations in our https://www.digitalocean.com/community/tutorials/ufw-essentials-common-firewall-rules-and-commands


* Step 5 — Enabling External Access for Your Regular User

```bash
# Now that we have a regular user for daily use, we need to make sure we can SSH into the account directly.

# 1. If you logged in to your root account using a password, then password authentication is enabled for SSH. 

ssh username@ip-address

# Remember, if you need to run a command with administrative privileges, type sudo before it like this:
sudo command_to_run

# 2. If you logged in to your root account using SSH keys, then password authentication is disabled for SSH. You will need to add a copy of your local public key to the new user’s ~/.ssh/authorized_keys file to log in successfully.

```

https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-20-04

## Linux on Azure MS Learn

This comprehensive learning path reviews deployment and management of Linux on Azure. Learn about cloud computing concepts, Linux IaaS and PaaS solutions and benefits and Azure cloud services.

Discover how to migrate and extend your Linux-based workloads on Azure with improved scalability, security, and privacy.

```bash
az login --tenant TENANT-ID-HERE

```

https://github.com/spawnmarvel/azure-automation/blob/main/azure-extra-linux-vm/READMELinuxOnAzure.md

## Learn to use Bash with the Azure CLI (quick guide)

Azure CLI reference commands can execute in several different shell environments, but Microsoft Docs primarily use the Bash environment. If you are new to Bash and also the Azure CLI, you will find this article a great place to begin your learning journey. Work through this article much like you would a tutorial, and you'll soon be using the Azure CLI in a Bash environment with ease.

* Query results as JSON dictionaries or arrays
* Format output as JSON, table, or TSV
* Query, filter, and format single and multiple values
* Use if/exists/then and case syntax
* Use for loops
* Use grep, sed, paste, and bc commands
* Populate and use shell and environment variables


https://learn.microsoft.com/en-us/cli/azure/azure-cli-learn-bash


## Reference az deployment create (Manage Azure Resource Manager template deployment at subscription scope)

https://learn.microsoft.com/en-us/cli/azure/deployment?view=azure-cli-latest#az-deployment-create


## Python with cron

Install cron and make it roll :large_blue_circle:
```bash
sudo apt install cron
sudo systemctl enable cron
Synchronizing state of cron.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install enable cron
```
* Cron jobs are recorded and managed in a special file known as a crontab. Each user profile on the system can have their own crontab where they can schedule jobs, which is stored under /var/spool/cron/crontabs/.
* To schedule a job, open up your crontab for editing and add a task written in the form of a cron expression. The syntax for cron expressions can be broken down into two elements: the schedule and the command to run.
* https://www.digitalocean.com/community/tutorials/how-to-use-cron-to-automate-tasks-ubuntu-1804

script
```python
import time
from datetime import datetime as dt
import logging
import os
import signal
import sys

logging.basicConfig(
    filename="app.log", 
    filemode="a", 
    format="%(asctime)s - %(name)s - %(levelname)s - %(funcName)s - %(message)s", 
    datefmt="%Y-%m-%d %H:%M:%S",
    level=logging.INFO)

logging.info('Starting...') # all logging will be logged to app.log
CUR = dt.now()
print(str(CUR), " Starting Cron job") # this will be logged to cron log
MAIN_PID = None

def handler(signum, frame):
    msg = "signal "+ str(signum)
    logging.info(msg)
    exit(1)

signal.signal(signal.SIGINT, handler)

def test_loop():
    rool= True
    count=0
    while (rool):
        count = count +1
        cur_tmp = dt.now()
        logging.info("Python count is " + str(cur_tmp))
        time.sleep(10)
        if count > 2:
            rool=False


if __name__ == "__main__":
    MAIN_PID = os.getpid()
    logging.info(str(MAIN_PID))
    test_loop()
    logging.info("Stopping....")
    cur_tmp = dt.now()
    print(str(cur_tmp), " Ending Cron job") # this will be logged to cron log
    exit()
```

Script
* /home/imsdal/run_loop.py
* Run the script with python3 run_loop.py
* cron log, >> /home/imsdal/cronoutput.log


Set up as cron jobb

```bash
crontab -e
# This will ask you which editor choose from. I used nano since it is my favorite editor, 1 = nano.
# Choose 1-4 [1]: 1
* * * * * python3 /home/imsdal/run_loop.py >> /home/imsdal/cronoutput.log
crontab: installing new crontab
# So the first 5 stars you can mention the minute, hour, day and month etc. with command to be executed. 
# Let’s create a cronjob that run every minute with out python script.
# every minute is (indicated by the five asterisks)
```

Let's view the outpu of each log file

```bash
cat cronoutput.log

tail -f cronoutput.log
```

```log
2023-07-19 23:08:01.284403  Starting Cron job
2023-07-19 23:08:31.315305  Ending Cron job
2023-07-19 23:09:01.424502  Starting Cron job
2023-07-19 23:09:31.455406  Ending Cron job
2023-07-19 23:10:01.554321  Starting Cron job
2023-07-19 23:10:31.585370  Ending Cron job
```

```bash
cat app.log

tail -f app.log
```

```log
root - INFO - Starting...
root - INFO - 7642
root - INFO - Python count is 2023-07-19 23:08:01.284480
root - INFO - Python count is 2023-07-19 23:08:11.294639
root - INFO - Python count is 2023-07-19 23:08:21.304883
root - INFO - Stopping....
root - INFO - Starting...
root - INFO - 7659
root - INFO - Python count is 2023-07-19 23:09:01.424580
root - INFO - Python count is 2023-07-19 23:09:11.434688
root - INFO - Python count is 2023-07-19 23:09:21.444931
root - INFO - Stopping....
root - INFO - Starting...
root - INFO - 7668
root - INFO - Python count is 2023-07-19 23:10:01.554397
root - INFO - Python count is 2023-07-19 23:10:11.564552
root - INFO - Python count is 2023-07-19 23:10:21.574867
root - INFO - Stopping....
root - INFO - Starting...
root - INFO - 7679
root - INFO - Python count is 2023-07-19 23:11:01.683514
```


## MS Tutorials for Linux

All done:

https://github.com/spawnmarvel/azure-automation/blob/main/azure-extra-linux-vm/READMEQuickstartsLinuxMS.md









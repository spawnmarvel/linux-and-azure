## Module 2: Introduction to Linux Commands

Overview of Common Linux Shell Commands =

* A shell is a powerful user interface for Unix-like operating systems. It can interpret commands
and run other programs.
* Default bash (only used in this course)

```bash

# Some common shell commands for getting information
whoami
id
uname
ps
top
df
man
date

# Some common shell commands for working with files include:
cp
mv
rm
touch
chmod
wc
grep

# Very common shell commands for navigating and working with directories include:
ls
find
pwd
mkdir
cd
rmdir

# For printing file contents or strings, common commands include:
cat
more
head
tail
echo

# Shell commands related to file compression and archiving applications include:
tar
zip
unzip

# Networking applications include the following:
hostname
ping
ifconfig
curl
wget

```

In this video, you learned that:
* A shell is an interactive user interface for running commands, a scripting language, and
an interactive language.
* Shell commands are used for navigating and working with files and directories.
* Shell commands can be used for file compression.
* The curl and wget commands, respectively, can be used to display and download files from
URLs.
* The echo command prints string or variable values.
* The cat and tail commands are used to display file contents.

Informational Commands = 

User information
```bash

# John Doe
whoami

# 501
id -u

#johndoe
id -u -n

# MINGW64_NT-10.0-19045 , OS
uname

# OS and version
uname -S -R

# more details
uname -v

# disk /home dir - human readble
df -h ~

# all files
df -h

# current running pro
ps

# all proc and time
ps -e

# system health , top 3
top -n 3

# print
echo

# Strictly speaking, you don't need to add quotes around a string with spaces for echo to work as expected,
# but it's considered best practice to include quotes.
# Using echo with a quoted string returns the quoted contents, “Learning Linux is fun!"

echo "hello"

# path
echo $PATH

# display dt
date

# Format controls are indicated with the % symbol.
# In this case, “percent j” and “percent Y” output
# the numerical day of the year and the year itself, respectively.
date "+%j day of %Y"
097 day of 2023

# more format
date "+It s%A, the %j day of %Y"

# view the manual and parameters for command
man

man id

man top

man echo

```

* Get user information with the "whoami" and "id" commands,
* Get operating system information using the “uname” command,
* Check system disk usage using the "df" command,
* Monitor processes and resource usage with “ps" and "top",
* Print string or variable value using "echo",
* Print and extract information about the date with the “date" command,
* And read the manual for any command using “man”.

Reading: Getting Help for Linux Commands

```bash
# man command

# list all commands
man -k .

# see the man page for a command
man command_name


man df

```

Hands-on Lab: Informational Commands

Exercise 1 - Informational Commands

```bash
# 1.1. Display the name of the current user
whoami

# 1.2. Get basic information about the operating system
uname

# all system info
uname -a

Kernel name
Network node hostname
Kernel release date
Kernel version
Machine hardware name
Hardware platform
Operating system

# 1.3. Obtain the user and group identity information
id

# 1.4 Get available disk space
df
df -h

# 1.5. View currently running processes
ps

# display all of the processes running on the system
ps -e

# 1.6. Get information on the running processes and system resources
# The output keeps refreshing until you press q or Ctrl + c.
top

# If you want to exit automatically after a specified number of repetitions
top -n 10

# sort my memeory
top
shift + m

# 1.7. Display Messages
echo "Hi"

# These special characters help you better format your output:
# \n	Start a new line
# \t	Insert a tab
echo -e "Hi \n a new line"
echo -e "Hi \t a tab"

# 1.8. Display date and time
date
# Wed Feb 28 19:56:41 UTC 2024

# %d	Displays the day of the month (01 to 31)
# %h	Displays the abbreviated month name (Jan to Dec)
# %m	Displays the month of year (01 to 12)
# %Y	Displays the four-digit year
# %T	Displays the time in 24 hour format as HH:MM:SS
# %H	Displays the hour

date "+%D"
# 02/28/24

date "+%h"
# Feb

date "+%m"
# 02

date "+%Y"
# 2024

date "+%T"
# 19:57:12

date "+%H"
# 19

# 1.9. View the Reference Manual For a Command
man ls

# To see all available man pages with a brief description of each command, enter:
man -k .
```

File and Directory Navigation Commands

```bash

# list where you are
ls

# list dir
ls Downloads

# child files, date and premission
ls -l

# where are we
pwd

# change
cd

```

The cd command enables you to change directories with either a relative or an absolute
path.

```bash

pwd
# /var/log

# relative path
cd ..

pwd
# /var

# E.T home
cd ~

# absolute path
cd /var/log/zabbix-agent/
```
Find, Lastly, the “find” command is a powerful tool that will return the path to every file

```bash

# find all kern.log in, . = here
pwd
# /var/log
sudo find . -name "kern.log"
./kern.log

```


File and Directory Management Commands = TODO

Hands-on Lab:  Navigating and Managing Files and Directories =

Reading: Security - Managing File Permissions and Ownership =

Hands-on Lab: Access Control Commands =

Practice Quiz: Informational, Navigational and Management Commands =

Viewing File Content =

Useful Commands for Wrangling Text Files =

File Archiving and Compression Commands =

Hands-on Lab: Wrangling Text Files at the Command Line =

Reading (Optional): A Brief Introduction to Networking =

Networking Commands =

Hands-on Lab: Working with Networking Commands =

File Archiving and Compression Commands =

Hands-on Lab: Archiving and Compressing Files =

Practice Quiz: Text Files, Networking & Archiving Commands =

Summary & Highlights =

Cheat Sheet: Introduction to Linux Commands =

Practice Quiz: Linux Commands =

Graded Quiz: Linux Commands = Done



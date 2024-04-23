# Linux Commands & Shell Scripting

general purpose commands
```bash
id, date, uname, ps, top, echo, man
```
directory management commands
```bash
pwd, cd, mkdir, rmdir, find, df
```
file management commands
```bash
cat, wget, more, head, tail, cp, mv, touch, tar, zip, unzip
```
access control command
```bash
chmod
```
text processing commands
```bash
wc, grep, tr
```
networking commands
```bash
hostname, ping, ifconfig and curl.
```
## GRADING SCHEME

* The course contains 3 Graded Quizzes (1 per module) worth 6o% of the total grade. Each Graded Quiz carries an equal weight of 20% of the total grade.
* The course also includes a Final Exam worth 20% of the total grade.
* The course also includes a Final Assignment worth 20% of the total grade.
* Permitted attempts are per question:

Graded Quizzes:
* One attempt - For True/False questions
* Two attempts - For any question other than True/False

Final Assignment:
* One attempt - For ALL questions

Check your grades in the course at any time by clicking on the "Progress" tab. 70% pass.

## Module 1: Introduction to Linux

### Module Introduction & Learning Objectives

Introducing Linux and Unix = done

* Unix is a family of operating systems dating from the 1960s.
* Linux was originally developed in the 1980s as a free, open-source alternative to Unix.
* Linux is multi-user, portable, and supports multitasking.
* And Linux is widely used today in mobile devices, supercomputers, data centers, and cloud servers.

Linux Distributions = 

* Linux distros can be differentiated by their user interfaces,
their shell applications, and how the operating system is supported and built.
* The design of a Linux distro is catered toward a specific audience.
* Debian is highly regarded in the server space for its stability, reliability,
and for being open source.
* Red Hat Enterprise Linux, an IBM subsidiary, is focused completely on enterprise customers.
* And SUSE Linux Enterprise supports many architectures, such as ARM for Raspberry Pi.

Overview of Linux Architecture =

* The Linux system comprises five distinct layers.
* 1 UI, web browser
* 2 Application, software, shell, apps
* 3 Operating system, users, errros, file management
* 4 Kernel, most vital, lowest level software, bridge between 3 and 5.
* 5 Hardware, physical, CPU, RAM, Storage, screen, usb device

The Linux filesystem is the collection of files on your machine. It includes the files
needed to run the machine and applications as well as your own files containing your
work.
The top level of the filesystem is the root directory, symbolized by a forward slash (/).

* One of the key directories is /bin, which contains user binary files.
* /usr, which contains user programs
* /home, which is your personal working directory
* /boot, which contains your system boot files
* /media, which contains files related to temporary media 

***There are several other directories in the root directory, but you will not need to access them during this course.***

* A Linux system consists of five key layers.
* The user interface is the layer that enables the user to interact with applications using
control devices​.
* Applications enable users to perform certain tasks within the system.
* The operating system runs on top of the Linux kernel and is vital for system health and
stability.
* The kernel is the lowest-level software and enables applications to interact with your
hardware.
* Hardware includes all the physical or electronic components of your PC.
* And the Linux filesystem is a tree-like structure consisting of all directories and
files on the system.

Linux Terminal Overview =

* The Linux shell is an OS-level application that interprets commands.
* You interact with the Linux shell through a Linux terminal.

```bash
python myprogram.py
```
User->terminal->shell OS Kernel->Hardware and back <-

* The path is the human-readable location of a directory or file in the Linux filesystem.
* The “a slash b” structure indicates that the file
or directory named "b" is located inside the directory named "a".

* A single tilde symbol refers to the user’s home directory.
* A single slash at the beginning of a path refers to the root directory.
* Two periods refer to the parent of the current directory.
* And a single period refers to the current directory.


```bash
# cd change directory.
cd bin

# check all files in folder
ls

# navigate to home with tilda, altgr + tilda
cd ~

pwd
/home/imsdal

# change current working dir to parent dir
cd ..

pwd
/home

# navigate to a data drive
# becomde root
sudo -i
sudo cd /datadrive
ls
buildkit  containers  engine-id  image  network  overlay2  plugins  runtimes  swarm  tmp  volumes

# switch user
su - imsdal

# you can also navigate up and down in the tree
cd /var/log/
pwd
/var/log

# to navigate up to the var dir and then up to the root dir and then down to home/user
cd ../../home/imsdal/
pwd
/home/imsdal

# lets move up to home
cd ..
pwd
/home

# start opython application, make it
sudo nano myprogram.py

# run it
python3 myprogram.py
Hello World

```

A Linux shell is an OS-level application that
you can use to enter commands and view the output of those commands.
You use a terminal to send commands to the shell.
And you can use the cd command to navigate around your Linux filesystem.


Reading: Browsing Directories with the Linux Terminal =

```bash
# print path
pwd

# list content of dir
ls

```

Reading: Linux Terminal Tips - Tab completion, command history =

```bash
# Use tab completion to autocomplete commands
cd /bi + tab = cd /bin

cd Do + tab = nothing since tow dirs starts with Do
cd Doc + tab = Documents

# Use command history to quickly navigate previous commands
# Up Arrow key
```

Hands-on Lab: Getting Started with the Linux Terminal =

1. ls

* /bin, system commands and binaries
* /sbin, system administration binaries
* /usr, user programs and data
* /home, homd dir
* /media, removable media device dirs

```bash

# Interact with the Linux terminal
# Browse directories on a Linux filesystem using the ls command
# Navigate directories using the cd command
# Save time and effort by using tab completion and your command history

# browsing dir
ls

# browsing other
ls /bin

```
2.  cd

* ~, home 
* /, root dir
* ., current dir
* .. parent dir

```bash
cd /sbin

# go home
cd ~

pwd
/home/theia

# parent
cd ..
/home
# change to root
cd /

# Changing from your working directory back to your home directory
cd /sbin

cd ../home/theia/
pwd
/home/theia

# Changing from your working directory to your project directory
cd ../project/

```

Pracitice Exercise

```bash
# 1. List contents of root dir
ls /

# 2. Change directories to your default home directory.
cd ~

# 3. Verify your current working directory is /home/theia.
pwd

# 4. Use tab completion to change directories to
cd /b

# 5. Use your terminal's command history to change directories back to your home directory.
Arrow up
```
Creating and Editing Text Files =

*  Nano

```bash
# ctrl + letter

sudo nano text.txt

ctrl x
# save
y
# search ctrl + w
write search string

# quit 
ctrl x
```
Hands-on Lab: Installing and working with text editors =

Use the sudo command to enable access to "super-user" system administration tools

Use the apt system administration command to update and install two popular packages for text editing: nano and Vim

Exercise 1 - Upgrading and installing packages

```bash

# 1.1 Updating your Linux sytem's package list index
# Before installing or upgrading any packages on your Linux system, it's best practice to first update your package list index.
sudo apt update -y

# 1.2. Upgrading nano
sudo apt upgrade nano -y

# 1.3. Installing Vim
sudo apt install vim


```

Exercise 2 - Creating and editing files with nano


```bash
# 2.1 Navigating to the project directory
cd /home/project/

# 2.2 Creating and editing a text file with nano
sudo nano text.txt

# 2.3 Verifying your new text file
cat text.txt

```

Exercise 3 - Creating and editing files with Vim

Recall that Vim has two basic modes: 
* Insert mode, where you enter text, and 
* Command mode, where you do everything else. 

You can start Vim simply by entering
```bash
vim

# help
:help

#quit
:q

# 3.2 Creating and editing a text file with Vim
vim hello_world_2.txt

# Once your Vim session has started, go ahead and press i to enter Insert mode.
Hello World!

# Just like in nano, press Enter to start a new line, and then type
This is the second line.


# When you're done typing text in the buffer, press the Escape key, Esc, to exit the Insert mode. This brings you to Command mode.

```

Practice Exercises

```bash

sudo nano test.txt

# add a new line

```
Installing Software and Updates =

apt

* You use the “sudo apt update” command to find available packages for your distro.
* To install the packages, use the “sudo apt upgrade” command.
* If you want to only install a specific package, you can use “sudo apt upgrade pkg name”

yum

* yum is a command-line tool for updating RPM-based systems.
* To update all packages in your system, type "sudo yum update"
* After you enter your password,
* Yum fetches all available package updates.
* And then it displays a summary of the updates and asks you to confirm the download.

* Use the apt command with the install switch to install a package on a deb-based system.
* And use the yum command with the install switch to install software on an RPM-based system.

Python

* pip(3) install
* pip install pandas

* deb and .rpm are distinct file types used by package managers in Linux operating systems
* deb and RPM formats can be converted from one to the other
* Update Manager and PackageKit are popular GUI-based package managers
used in deb- and RPM-based distros, respectively
* And apt and yum are popular command line package managers
used in deb- and RPM-based distros, respectively.

Summary & Highlights =

Cheat Sheet: Introduction to Linux =

Practice Quiz: Introduction to Linux =

Graded Quiz: Introduction to Linux = Done


## Final Project and Final Exam

Reading: Practice Project Overview =

Hands-on Lab: Historical Weather Forecast Comparison to Actuals =

Reading: Cheat Sheet: Linux Commands and Shell Scripting =

Reading: Final Project Overview =

Hands-On Lab: Peer-Graded Final Project =

Peer-Graded Final Assignment =

Final Exam =

## Course Wrap Up

## Badge

https://www.edx.org/learn/linux/ibm-linux-commands-shell-scripting
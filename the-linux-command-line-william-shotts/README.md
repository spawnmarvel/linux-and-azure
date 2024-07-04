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

# view text files
less

# classify a files content
file

![Long format ](https://github.com/spawnmarvel/linux-and-azure/blob/main/images/longformat.jpg)

```
### 4 A Guided Tour
### 5 Manipulating Files
### 6 Working with Commands
### 7 I/O Redirection
### 8 Expansion
### 9 Permissions
### 10 Job Control


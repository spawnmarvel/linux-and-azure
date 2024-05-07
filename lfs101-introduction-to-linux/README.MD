# INTRODUCTION TO LINUX (LFS101)

https://trainingportal.linuxfoundation.org/learn/course/introduction-to-linux-lfs101/course-introduction/course-information

06.05.2024 12 months

## 01 Course Overview, Objectives and Timing

## 02 Introduction

In order to fully benefit from this course, you will need to have at least one Linux distribution installed.

3 major distros

Key Facts About the Red Hat Family

* Fedora serves as an upstream testing platform for RHEL.
* RHEL/centos
* dnf, rpm pakage mananger
* enterprise

Key Facts About the SUSE Family

* SUSE Linux Enterprise Server (SLES) is upstream for openSUSE.
* It uses the RPM-based zypper package manager
* SLES is widely used in retail and many other sectors.

Key Facts About the Debian Family

* The Debian family is upstream for Ubuntu, and Ubuntu is upstream for Linux Mint and others.
* Kernel version 5.19 is used in Ubuntu 22.04 LTS.
* It uses the DPKG-based APT package manager (using apt, apt-get, apt-cache, etc)
* Ubuntu has been widely used for cloud deployments.
* While Ubuntu is built on top of Debian and is GNOME-based under the hood, it differs visually from the interface on standard Debian, as well as other distributions.

## 03 Linux philosophy and concepts

History = Done

Philosophy =  Done

Community = Done

Terminology = Done

Distributions = Done 


## 04 Linuxc basics and system startup

BIOS - The First Step

Master Boot Record (MBR), EFI Partition, and Boot Loader

The Initial RAM Disk

* * The initramfs filesystem image contains programs and binary files that perform all actions needed to mount the proper root filesystem
* * The mount program instructs the operating system that a filesystem is ready for use and associates it with a particular point in the overall hierarchy of the filesystem (the mount point)

Text-Mode Login

* * Near the end of the boot process, init starts a number of text-mode login prompts. These enable you to type your username, followed by your password, and to eventually get a command shell. 

The Linux Kernel

* * The boot loader loads both the kernel and an initial RAM–based file system (initramfs) into memory, so it can be used directly by the kernel.
* * Once the kernel has set up all its hardware and mounted the root filesystem, the kernel runs /sbin/init. This then becomes the initial process, which then starts other processes to get the system running.

Startup Alternatives

* SysVinit viewed things as a serial process, divided into a series of sequential stages.
* Upstart, Developed by Ubuntu and first included in 2006, adopted in fedora in 9 2008
* systemd, Adopted by Fedora first (in 2011), rhel 7  and suse, replaced upstart in ubuntu 16.04

systemd Features

* Systems with systemd start up faster than those with earlier init methods.
* One thing to note is that /sbin/init now just points to /lib/systemd/systemd; i.e. systemd takes over the init process.
* One systemd command (systemctl) is used for most basic tasks. 

```bash
# apahce
sudo systemctl start|stop|restart httpd.service

sudo systemctl enable|disable httpd.service

sudo systemctl status httpd.service

```

Partitions and Filesystems

|#| Windows | Linux |
|*|******** |****** |
|Partition|Disk1|/dev/sda1


## 05-19

## 20 Course completion

Practice exam

Final task
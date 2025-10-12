# Linux mind maps

## Useful Linux Commands

![usefule cmds](https://github.com/spawnmarvel/linux-and-azure/blob/main/z-mind-maps/images/cmds.png)

## File system

* /bin is the directory that contains binaries, that is, some of the applications and programs you can run. You will find the ls program for example.
* /boot directory contains files required for starting your system. Do I have to say this? Okay, I’ll say it: DO NOT TOUCH!. 
* /dev contains device files.
* /etc is the directory where names start to get confusing. “Everything to configure,” as it contains most, if not all system-wide configuration files.
* /home is where you will find your users’ personal directories.
* /lib is where libraries live. Libraries are files containing code that your applications can use.
* /media directory is where external storage will be automatically mounted when you plug it in and try to access it.
* The /mnt directory, however, is a bit of remnant from days gone by. This is where you would manually mount storage devices or partitions. It is not used very often nowadays.
* /opt directory is often where software you compile (that is, you build yourself from source code and do not install from your distribution repositories) sometimes lands.

A slight digression: another place where applications and libraries end up in is :

* /usr/local, When software gets installed here, there will also be 
* /usr/local/bin and 
* /usr/local/lib directories. 

* /proc, like /dev is a virtual directory. It contains information about your computer, such as information about your CPU and the kernel your Linux system is running
* /root is the home directory of the superuser (also known as the “Administrator”) of the system. It is separate from the rest of the users’ home directories BECAUSE YOU ARE NOT MEANT TO TOUCH IT.
* /run is another new directory. System processes use it to store temporary data for their own nefarious reasons. This is another one of those DO NOT TOUCH folders.
* /sbin is similar to /bin, but it contains applications that only the superuser (hence the initial s) will need. You can use these applications with the sudo command that temporarily concedes you superuser powers on many distributions. /sbin typically contains tools that can install stuff, delete stuff and format stuff. 
* /usr directory was where users’ home directories were originally kept back in the early days of UNIX. However, now /home is where users kept their stuff as we saw above. 
* /srv directory contains data for servers. If you are running a web server from your Linux box, your HTML files for your sites would go into /srv/http (or /srv/www).
* /sys is another virtual directory like /proc and /dev and also contains information from devices connected to your computer.
* /tmp contains temporary files, usually placed there by applications that you are running.

You can also use /tmp to store your own temporary files — /tmp is one of the few directories hanging off / that you can actually interact with without becoming superuser.

* /var contains things like logs in the /var/log subdirectories. 

https://www.linuxfoundation.org/blog/blog/classic-sysadmin-the-linux-filesystem-explained

![file system](https://github.com/spawnmarvel/linux-and-azure/blob/main/z-mind-maps/images/filesys.png)

Basic operations

![file system](https://github.com/spawnmarvel/linux-and-azure/blob/main/z-mind-maps/images/basic.png)
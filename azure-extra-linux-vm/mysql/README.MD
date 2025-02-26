# Learning MySql

* Basic
* * Run on Linux vmdocker01
* * Insert use Python, Use example as tag table and history table
* Advanced
* Backup and restore
* Tuning and performance

How is the above steps done in Azure

https://learn.microsoft.com/en-us/azure/mysql/



## Step 1 — Installing MySQL Ubuntu

```bash

# To install it, update the package index on your server if you’ve not done so recently:
sudo apt update -y


sudo apt install mysql-server

# Ensure that the server is running using the systemctl start command:
sudo systemctl start mysql.service

# check it
sudo service mysql status

# Version
mysql -V
# mysql  Ver 8.0.40-0ubuntu0.22.04.1 for Linux on x86_64 ((Ubuntu))

```

### Step 2 — Configuring MySQL

For fresh installations of MySQL, you’ll want to run the database management system’s included security script. This script changes some of the less secure default options for things like disallowing remote root logins and removing sample users.

```bash

sudo mysql_secure_installation <<EOF

n
n
n
y
y
y
y
EOF

# The above is not a secure installation, do not do this in production

```

This program enables you to improve the security of your MySQL installation in the following ways:

* You can set a password for root accounts.
* You can remove root accounts that are accessible from outside the local host.
* You can remove anonymous-user accounts.
* You can remove the test database (which by default can be accessed by all users, even anonymous users), and privileges that permit anyone to access databases with names that start with test_.

https://dev.mysql.com/doc/refman/8.4/en/mysql-secure-installation.html

### Step 3 — Creating a Dedicated MySQL User and Granting Privileges

Upon installation, MySQL creates a root user account which you can use to manage your database. This user has full privileges over the MySQL server, meaning it has complete control over every database, table, user, and so on.

```bash

sudo mysql
# or
mysql -u root -p

# 

CREATE USER 'timmy'@'localhost' IDENTIFIED BY 'tim123456';
# Query OK, 0 rows affected (0.02 sec)


GRANT CREATE, ALTER, DROP, INSERT, UPDATE, INDEX, DELETE, SELECT, REFERENCES, RELOAD on *.* TO 'timmy'@'localhost' WITH GRANT OPTION;
# Query OK, 0 rows affected (0.01 sec)

FLUSH PRIVILEGES;

exit

mysql -u timmy -p 

```

https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix/install_mariadb.sh

https://www.digitalocean.com/community/tutorials/how-to-install-mysql-on-ubuntu-22-04




## Basic MySql and Normalization tbd

Basic

https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/mysql/README_ai_most_common.md

Next AI after basic, an you make me a tutorial in mysql with lab task for the most common scenarios with Data Normalization and Transactions (ACID Properties) ?


## Create the tag and history table tbd

https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/mysql/README_ai_timseries_db.md


## Advanced MySql tbd

## Backup and restore MySql tbd

## Tuning and performance MySql tbd

Database engines

InnoDB

As of MySQL 5.5, InnoDB is the default engine, and is highly recommended over MyISAM unless you have specific needs for features unique to that engine.


Advanced configuration

There are a number of parameters that can be adjusted within MySQL’s configuration files. This will allow you to improve the server’s performance over time.


https://ubuntu.com/server/docs/install-and-configure-a-mysql-server

## Azure Database for MySQL documentation


## Extra phpMyAdmin

How To Install and Secure phpMyAdmin on Ubuntu

https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-on-ubuntu


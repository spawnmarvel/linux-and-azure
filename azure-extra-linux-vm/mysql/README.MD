# Learning MySql

* Basic
* * Run on Linux vmdocker01
* * Insert use Telegraf
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


## Telegraf test database

Lets create a test database for telegraf

Lets assume the json file

```json
{
    "tag1": {
        "value": 100,
        "active": 1,
		"state": 0
    }
}

```

```bash

```
## Install Telegraf Ubuntu and make ETL file 2 file


```bash
sudo nano install_telegraf.sh

# add the script from telegrtaf site as-is

curl --silent --location -O \
https://repos.influxdata.com/influxdata-archive.key \
&& echo "943666881a1b8d9b849b74caebf02d3465d6beb716510d86a39f6c8e8dac7515  influxdata-archive.key" \
| sha256sum -c - && cat influxdata-archive.key \
| gpg --dearmor \
| sudo tee /etc/apt/trusted.gpg.d/influxdata-archive.gpg > /dev/null \
&& echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive.gpg] https://repos.influxdata.com/debian stable main' \
| sudo tee /etc/apt/sources.list.d/influxdata.list
sudo apt-get update && sudo apt-get install telegraf

# run it
bash install_telegraf.sh


# make in file
/var/telegraf_data

# make the inputfile
sudo nano metrics.in.json

# make out file
# Telegraf typically runs as the telegraf user. Set the ownership of the directory and file to the telegraf user and group:
sudo chown -R telegraf:telegraf /var/telegraf_data
sudo chmod 755 /var/telegraf_data
sudo touch /var/telegraf_data/metrics.out.json
sudo chown telegraf:telegraf /var/telegraf_data/metrics.out.json
sudo chmod 644 /var/telegraf_data/metrics.out.json

# conf it
cd /etc/telegraf/

# bck
sudo cp telegraf.conf telegraf.conf_bck

# edit conf
sudo nano telegraf.conf
# paste telegraf_file_file.conf content, ctrl x and yes

sudo service start telegraf
sudo systemctl enable telegraf
sudo service telegraf status
#  sudo service telegraf status
● telegraf.service - Telegraf
     Loaded: loaded (/lib/systemd/system/telegraf.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2025-02-04 22:10:04 UTC; 2s ago

# If you encounter any issues, you can check the Telegraf logs for more information
sudo journalctl -u telegraf
 
sudo chown -R telegraf:telegraf /var/telegraf_data
sudo chmod 755 /var/telegraf_data
sudo touch /var/telegraf_data/metrics.out.json
sudo chown telegraf:telegraf /var/telegraf_data/metrics.out.json
sudo chmod 644 /var/telegraf_data/metrics.out.json

sudo service telegraf stop
sudo service telegraf start
sudo service telegraf status
```

Now it should read input and append to output

```bash
pwd
# /var/telegraf_data

tail -f metrics.out.json
# 

```

Output

```json
{"fields":{"tag1_active":1,"tag1_state":0,"tag1_value":100},"name":"file","tags":{"host":"vmdocker01"},"timestamp":1738707825}
{"fields":{"tag1_active":1,"tag1_state":0,"tag1_value":100},"name":"file","tags":{"host":"vmdocker01"},"timestamp":1738707850}
{"fields":{"tag1_active":1,"tag1_state":0,"tag1_value":100},"name":"file","tags":{"host":"vmdocker01"},"timestamp":1738707875}
{"fields":{"tag1_active":1,"tag1_state":0,"tag1_value":100},"name":"file","tags":{"host":"vmdocker01"},"timestamp":1738707900}

```


https://docs.influxdata.com/telegraf/v1/install/

## Telegraf ETL MySQL tbd


Input file:

https://github.com/influxdata/telegraf/blob/master/plugins/inputs/file/README.md

We have the input file and also output file, lets make a new output to MySql

Output MySql:

https://github.com/influxdata/telegraf/blob/master/plugins/outputs/sql/README.md


## Basic MySql tbd

## Normalization tbd

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


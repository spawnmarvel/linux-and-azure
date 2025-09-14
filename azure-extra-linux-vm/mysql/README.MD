# Learning MySql with Telegraf on Linux with Grafana

* Basic
* * Run on Linux dummy01 (vmdocker01)
* * Insert use telegraf and file, possible other inputs also was done (this section is moved to misc)
* * Python as cron job and Grafana is done (this section is moved to misc)
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

### Step 2 — Configuring MySQL example

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


###  Step 2 — Configuring MySQL Secure Optional

MySql example install Digital Ocean secure this was done

Servers used:
* imsdal@dummy01:~$ ssh imsdal@192.168.3.6
* imsdal@dummy03:~$

```bash
# example
# install dummy01
sudo apt update
sudo apt install mysql-server
# when you install MySQL on Ubuntu (via apt install mysql-server), the package automatically enables the MySQL service to start **at boot**.  
sudo systemctl start mysql.service
sudo service mysql status

# check boot
systemctl is-enabled mysql
# enabled

# configure
sudo mysql

ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'pokemon';
exit
mysql -u root -p

# Then go back to using the default authentication method using this command:
ALTER USER 'root'@'localhost' IDENTIFIED WITH auth_socket;
exit

# Run the security script with sudo:
sudo mysql_secure_installation

Press y|Y for Yes, any other key for No: Y
Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG: 0
Remove anonymous users? (Press y|Y for Yes, any other key for No) : y
Disallow root login remotely? (Press y|Y for Yes, any other key for No) : y
Remove test database and access to it? (Press y|Y for Yes, any other key for No) : y
Reload privilege tables now? (Press y|Y for Yes, any other key for No) : y
Success.


# Create a test database and one table
## 1. Create the database
CREATE DATABASE db1;

## 2. Switch to the new database
USE db1;

## 3. Create a table with id and name
CREATE TABLE table1 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

INSERT INTO table1 (name) values ('row1');
select * from table1;
# create a dedicated MySql user and grating privilegs, beside root
sudo mysql
# 
#CREATE USER 'username'@'localhost' IDENTIFIED WITH authentication_plugin BY 'password';
# '%' (percent sign) is a wildcard that allows connections from **any host** (remote or local)
CREATE USER 'pika'@'%' IDENTIFIED BY 'mika12';

Your password does not satisfy the current policy requirements
mysql>
# Perfect that is what we configured
CREATE USER 'pika'@'%' IDENTIFIED BY 'pikamika12';

# After creating your new user, you can grant them the appropriate privileges.
grant all privileges on db1.* to 'pika'@'%';
FLUSH PRIVILEGES;
EXIT

# connect
mysql -u pika -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 15
Server version: 8.0.43-0ubuntu0.24.04.1 (Ubuntu)
# query
show databases;
use db1;
select * from db1;

# edit config and UFW on dummy 1
cd /etc/mysql/mysqld.conf.d/
sudo cp mysqld.cnf mysqld.cnf_bck
sudo nano mysqld.cnf
# bind-address = 0.0.0.0

sudo ufw allow 3306/tcp
ssudo service mysql stop
sudo service mysql start
sudo service mysql status

# check bind adress is 0.0.0.0
sudo ss -tlnp | grep 3306

# login remote from dummy 3 to dummy1
imsdal@dummy01:~$ ssh imsdal@192.168.3.6
imsdal@dummy03:~$

# install mysql client dummy03
sudo apt update
# This will give you the mysql command-line client, which you can use to connect to remote MySQL databases.
sudo apt install mysql-client

nc -zv 192.168.3.4 3306
# Connection to 192.168.3.4 3306 port [tcp/mysql] succeeded!
telnet 192.168.3.4 3306

mysql -u pika -h 192.168.3.4 -p

```
Result

![mysql remote ](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/mysql_remote.png)

https://www.digitalocean.com/community/tutorials/how-to-install-mysql-on-ubuntu-20-04


### Step 3 — Creating a Dedicated MySQL User and Granting Privileges

Was done above

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


### mysqld.cnf

Lets move the data directory

Check data on dummy1, sudo mysql.

```sql
use db1;

select * from table1;
-- id = 1, name=row1
```

Edit mysqld.cnf

```bash
cd /etc/mysql/mysql.conf.d/

ls
mysql.cnf  mysqld.cnf  mysqld.cnf_bck
# datadir       = /var/lib/mysql

sudo service mysql stop

# - Inside /var/lib/mysql/, you’ll find a folder for each database (including mysql, information_schema, etc.).
# - You need **root or mysql user privileges** to view or edit these files.
sudo su
cd /var/lib/mysql

mkdir mysql-data
cd
sudo rsync -av /var/lib/mysql /var/lib/mysql-data

exit # root

cd /etc/mysql/mysql.conf.d/
sudo nano mysqld.cnf
# edit mysql
datadir       = /var/lib/mysql-data/mysql

sudo chown -R mysql:mysql /var/lib/mysql-data

sudo nano /etc/apparmor.d/usr.sbin.mysqld
# Allow data dir access
#  /var/lib/mysql/ r,
#  /var/lib/mysql/** rwk,
  /var/lib/mysql-data/ r,
  /var/lib/mysql-data/** rwk,

# reload armor
sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.mysqld

sudo service mysql status
● mysql.service - MySQL Community Server
     Loaded: loaded (/usr/lib/systemd/system/mysql.service; enabled; preset: enabled)
     Active: active (running) since Sun 2025-09-14 15:28:25 UTC; 43s ago
```

```sql
-- test
-- sudo mysql
-- Welcome to the MySQL monitor.  Commands end with ; or \g

use db1;
select * from table1;

```

### Phpmyadmin app



```bash
sudo apt update -y

# Next, install the phpmyadmin package. This command will also install a web server (Apache2) and PHP with the required extensions, as they are dependencies.
sudo apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl

# Configure database for phpmyadmin with dbconfig-common?
# Abort
# ref https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-on-ubuntu-20-04

sudo mysql

UNINSTALL COMPONENT "file://component_validate_password";
exit

# Then try installing the phpmyadmin package again and it will work as expected:
sudo apt install phpmyadmin

# no just on yes and click

sudo mysql
INSTALL COMPONENT "file://component_validate_password";
exit

```
The installation process adds the phpMyAdmin Apache configuration file into the /etc/apache2/conf-enabled/ directory, where it is read automatically. To finish configuring Apache and PHP to work with phpMyAdmin, the only remaining task in this section of the tutorial is to is explicitly enable the mbstring PHP extension, which you can do by typing:

```bash
sudo phpenmod mbstring
sudo systemctl restart apache2

php -v
# upgrade php is in the link also.

```

Visit phpmyadmin

* Add NSG 80 inbound
* Edit UFW

```bash
sudo ufw allow http
```

Apache http://ip success

Apache http://ip/phpmyadmin fail

```bash
# does it exist
ls -l /var/www/html/

# no only index.html

# create it
# This command creates a symbolic link named phpmyadmin in your web root (/var/www/html), which points to the actual phpMyAdmin installation directory (/usr/share/phpmyadmin)
sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

# Sometimes, the symbolic link method isn't enough, especially if you have a non-standard Apache configuration. 
ls -l /etc/apache2/conf-enabled/phpmyadmin.conf

# If the link doesn't exist, create it:
sudo ln -s /etc/apache2/conf-available/phpmyadmin.conf /etc/apache2/conf-enabled/

sudo service apache2 restart
sudo service apache2 status

```

![phpmyadmin](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/mysql/images/phpmyadmin.png)

Create a user

sudo mysql
```sql
CREATE USER 'pikaadmin'@'%' IDENTIFIED BY ' look else where';
GRANT ALL PRIVILEGES ON *.* TO 'pikaadmin'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EXIT
```

![phpmyadmin](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/mysql/images/php_dashboard.png)


https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-on-ubuntu-20-04

### Performance tuning MySQL after installation

1. Optimize the MySQL configuration file: Adjust settings in /etc/mysql/my.cnf to optimize performance based on your system’s resources.
2. Use a suitable storage engine: Choose the most appropriate storage engine for your database, such as MyISAM for transactional workloads.
3. Index your tables: Create indexes on frequently queried columns to improve query performance.

https://dev.mysql.com/doc/refman/8.0/en/create-index.html

4. Regularly update statistics: Run ANALYZE TABLE to update table statistics and improve query optimization.

```sql

# sudo mysql

use db1;

ANALYZE TABLE table1;
```

5. Monitor performance: Use tools like mysqladmin or sysdig to monitor MySQL performance and identify bottlenecks.



# Misc

## Telegraf install and configure file in, file out and mysql out


make install_telegraf.sh from

https://docs.influxdata.com/telegraf/v1/install/

```bash
curl --silent --location -O \
https://repos.influxdata.com/influxdata-archive.key \
&& echo "943666881a1b8d9b849b74caebf02d3465d6beb716510d86a39f6c8e8dac7515  influxdata-archive.key" \
| sha256sum -c - && cat influxdata-archive.key \
| gpg --dearmor \
| sudo tee /etc/apt/trusted.gpg.d/influxdata-archive.gpg > /dev/null \
&& echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive.gpg] https://repos.influxdata.com/debian stable main' \
| sudo tee /etc/apt/sources.list.d/influxdata.list
sudo apt-get update && sudo apt-get install telegraf

```

1. **Create the MySQL Database and User**
Before running Telegraf, ensure the MySQL database and user are set up. For example:

   ```sql
   CREATE DATABASE telegraf_db;
   CREATE USER 'telegraf_user'@'%' IDENTIFIED BY 'etlaccount1';
   GRANT ALL PRIVILEGES ON telegraf_db.* TO 'telegraf_user'@'%';
   FLUSH

   ```

2. **Install MySQL Driver for Telegraf or list plugins**

Use generic sql with mysql driver

https://github.com/influxdata/telegraf/blob/master/plugins/outputs/sql/README.md

```bash
# commands
telegraf -h

# --input-list
# --output-list
telegraf -input-list

# [...]
sql

```


make telegraf file directory

```bash
/var/telegraf_data
ls
metrics.in.json  metrics.out.json

```

metric.in.json


```json
[
  {
    "measurement": "tag1",
    "value": 102,
    "active": 1,
    "state": 0,
    "quality": "good"
  },
  {
    "measurement": "tag2",
    "value": 55,
    "active": 1,
    "state": 0,
    "quality": "good"
  }
]

```

**telegraf conf**

Use generic sql with mysql driver

https://github.com/influxdata/telegraf/blob/master/plugins/outputs/sql/README.md




```bash
/etc/telegraf
ls
telegraf.conf


```

telegraf logs

```bash
/var/log/telegraf
ls
telegraf.logs

```

Test telegraf

1. Save the configuration file as `telegraf.conf`.
2. Test the configuration to ensure it's valid:

   ```bash
   sudo telegraf --config telegraf.conf --test

2025-02-27T22:35:22Z I! Loading config: telegraf.conf
> tag1 active=1,quality="good",state=0,value=102 1740695723000000000
> tag2 active=1,quality="good",state=0,value=55 1740695723000000000
   ```


Start telegraf

```bash
sudo service telegraf start

```

### View README_file_mysql_telegraf_findings.md (but fixed for now)

Fix was mainly in telegraf.conf, metrics.in.json and after that it should have created the tables
automatically, but it did not, so I did:

Use an Auto-Increment Primary Key and not time, and create the tables.

Ref telegraf.conf something here is wrong....could be mysql rights?

```conf
## Table creation behavior
  ## If true, Telegraf will automatically create tables for measurements
  table_template = "CREATE TABLE IF NOT EXISTS `%s` (time DATETIME NOT NULL, %s, PRIMARY KEY (time))"
  # the above did not work and a new table was created look below, primary key should not be time either, but id


```
But the fix was:

```sql

sudo mysql

use telegraf_db;

CREATE TABLE IF NOT EXISTS `tag1` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  time DATETIME(6) NOT NULL,
  `value` DOUBLE,
  `active` BIGINT,
  `state` BIGINT,
  `quality` TEXT
);


CREATE TABLE IF NOT EXISTS `tag2` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  time DATETIME(6) NOT NULL,
  `value` DOUBLE,
  `active` BIGINT,
  `state` BIGINT,
  `quality` TEXT
);


view logs

```logs

2025-02-27T22:38:19Z I! Loaded inputs: file
2025-02-27T22:38:19Z I! Loaded aggregators:
2025-02-27T22:38:19Z I! Loaded processors:
2025-02-27T22:38:19Z I! Loaded secretstores:
2025-02-27T22:38:19Z I! Loaded outputs: file sql
2025-02-27T22:38:19Z I! Tags enabled: host=vmdocker01
2025-02-27T22:38:19Z I! [agent] Config: Interval:25s, Quiet:false, Hostname:"vmdocker01", Flush Interval:30s
2025-02-27T22:38:19Z W! [agent] The default value of 'skip_processors_after_aggregators' will change to 'true' with Telegraf v1.40.0! If you need the current default behavior, please explicitly set the option to 'false'!
2025-02-27T22:38:19Z D! [agent] Initializing plugins
2025-02-27T22:38:19Z D! [agent] Connecting outputs
2025-02-27T22:38:19Z D! [agent] Attempting connection to [outputs.file]
2025-02-27T22:38:19Z D! [agent] Successfully connected to outputs.file
2025-02-27T22:38:19Z D! [agent] Attempting connection to [outputs.sql]
2025-02-27T22:38:19Z D! [agent] Successfully connected to outputs.sql
2025-02-27T22:38:19Z D! [agent] Starting service inputs
2025-02-27T22:38:33Z D! [outputs.sql] Buffer fullness: 0 / 10000 metrics
2025-02-27T22:38:43Z D! [outputs.sql] Buffer fullness: 0 / 10000 metrics

```

view sql

```sql
sudo mysql

use telegraf_db;

show tables;

+-----------------------+
| Tables_in_telegraf_db |
+-----------------------+
| tag1                  |
| tag2                  |
+-----------------------+

select * from tag1;
+----+----------------------------+-------+--------+-------+---------+
| id | time                       | value | active | state | quality |
+----+----------------------------+-------+--------+-------+---------+
|  1 | 2025-02-27 22:16:40.000000 |   102 |      1 |     0 | good    |
|  2 | 2025-02-27 22:16:40.000000 |   102 |      1 |     0 | good    |
|  3 | 2025-02-27 22:17:05.000000 |   102 |      1 |     0 | good    |
|  4 | 2025-02-27 22:17:30.000000 |   102 |      1 |     0 | good    |
|  5 | 2025-02-27 22:17:55.000000 |   102 |      1 |     0 | good    |
|  6 | 2025-02-27 22:18:20.000000 |   102 |      1 |     0 | good    |
|  7 | 2025-02-27 22:18:45.000000 |   102 |      1 |     0 | good    |
|  8 | 2025-02-27 22:19:10.000000 |   102 |      1 |     0 | good    |
|  9 | 2025-02-27 22:19:35.000000 |   102 |      1 |     0 | good    |
| 10 | 2025-02-27 22:20:00.000000 |   102 |      1 |     0 | good    |
| 11 | 2025-02-27 22:20:25.000000 |   102 |      1 |     0 | good    |
| 12 | 2025-02-27 22:20:50.000000 |   102 |      1 |     0 | good    |
| 13 | 2025-02-27 22:21:15.000000 |   102 |      1 |     0 | good    |

select * from tag2;
+----+----------------------------+-------+--------+-------+---------+
| id | time                       | value | active | state | quality |
+----+----------------------------+-------+--------+-------+---------+
|  1 | 2025-02-27 22:16:40.000000 |    55 |      1 |     0 | good    |
|  2 | 2025-02-27 22:17:05.000000 |    55 |      1 |     0 | good    |
|  3 | 2025-02-27 22:17:30.000000 |    55 |      1 |     0 | good    |
|  4 | 2025-02-27 22:17:55.000000 |    55 |      1 |     0 | good    |
|  5 | 2025-02-27 22:18:20.000000 |    55 |      1 |     0 | good    |
|  6 | 2025-02-27 22:18:45.000000 |    55 |      1 |     0 | good    |
|  7 | 2025-02-27 22:19:10.000000 |    55 |      1 |     0 | good    |
|  8 | 2025-02-27 22:19:35.000000 |    55 |      1 |     0 | good    |
|  9 | 2025-02-27 22:20:00.000000 |    55 |      1 |     0 | good    |
| 10 | 2025-02-27 22:20:25.000000 |    55 |      1 |     0 | good    |
| 11 | 2025-02-27 22:20:50.000000 |    55 |      1 |     0 | good    |
| 12 | 2025-02-27 22:21:15.000000 |    55 |      1 |     0 | good    |
| 13 | 2025-02-27 22:21:40.000000 |    55 |      1 |     0 | good    |

```

## Make a python cron job to update the values in the files (view py_cron)


* Pyscript for updating values in metrics.in.json
* Make cron, log to file and output

```bash

sudo apt install cron
sudo systemctl enable cron

Synchronizing state of cron.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install enable cron

# for custom scripts
/var/telegraf_data

# cp content from py_cron\run_metric_generator.py
sudo nano run_metric_generator.py

# Test it
sudo python3 run_metric_generator.py

2025-03-02 15:58:44.287365  Starting Cron job
JSON file updated successfully!
[{'measurement': 'tag1', 'value': 107, 'active': 1, 'state': 0, 'quality': 'good'}, {'measurement': 'tag2', 'value': 119, 'active': 1, 'state': 1, 'quality': 'good'}]

# make cron job, every minute (indicated by the five asterisks)

sudo crontab -e

# choose nano = 1
# add
* * * * * python3 /var/telegraf_data/run_metric_generator.py >> /var/telegraf_data/cronoutput.log
# save it and it has created the job, to delet it, just remove the line
crontab: installing new crontab
```

Wait 1 min

```bash

tail -f cronoutput.log

2025-03-02 17:05:01.614454  Starting Cron job
JSON file updated successfully!
[{'measurement': 'tag1', 'value': 70, 'active': 1, 'state': 0, 'quality': 'good'}, {'measurement': 'tag2', 'value': 82, 'active': 1, 'state': 1, 'quality': 'good'}]
2025-03-02 17:05:01.615158  Ending Cron job

tail -f rmg_app_log

cat metrics.in.json

```

View json updates

```json

[
    {
        "measurement": "tag1",
        "value": 124,
        "active": 1,
        "state": 0,
        "quality": "good"
    },
    {
        "measurement": "tag2",
        "value": 136,
        "active": 1,
        "state": 1,
        "quality": "good"
    }

[
    {
        "measurement": "tag1",
        "value": 58,
        "active": 1,
        "state": 0,
        "quality": "good"
    },
    {
        "measurement": "tag2",
        "value": 70,
        "active": 1,
        "state": 1,
        "quality": "good"
    }
]

```

Drop table mysql and do new select query

```sql

sudo mysql

use telegraf_db;

truncate table tag1
truncate table tag2;

 select * from tag1;
+----+----------------------------+-------+--------+-------+---------+
| id | time                       | value | active | state | quality |
+----+----------------------------+-------+--------+-------+---------+
|  1 | 2025-03-02 17:08:45.000000 |    50 |      1 |     0 | good    |
|  2 | 2025-03-02 17:09:10.000000 |    85 |      1 |     0 | good    |
|  3 | 2025-03-02 17:09:35.000000 |    85 |      1 |     0 | good    |
|  4 | 2025-03-02 17:10:00.000000 |    85 |      1 |     0 | good    |
|  5 | 2025-03-02 17:10:25.000000 |    29 |      1 |     0 | good    |
+----+----------------------------+-------+--------+-------+---------+
5 rows in set (0.00 sec)


select * from tag2;

 select * from tag2;
+----+----------------------------+-------+--------+-------+---------+
| id | time                       | value | active | state | quality |
+----+----------------------------+-------+--------+-------+---------+
|  1 | 2025-03-02 17:10:25.000000 |    41 |      1 |     1 | good    |
|  2 | 2025-03-02 17:10:50.000000 |    41 |      1 |     1 | good    |
|  3 | 2025-03-02 17:11:15.000000 |   123 |      1 |     1 | good    |
+----+----------------------------+-------+--------+-------+---------+
3 rows in set (0.00 sec)


```

ref https://github.com/spawnmarvel/linux-and-azure?tab=readme-ov-file#python-with-cron

## Grafana dashboard Mysql connect

Grafana ships with the MySQL plugin, so no additional installation is required.


View Readme for installtion on vmdocker01 https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/mysql/README_ai_install_grafana.md

(docs for oss open source grafana version https://grafana.com/docs/grafana/latest/setup-grafana/installation/debian/)

We must edit the admin password first time.

![Welcome grafana ](https://github.com/spawnmarvel/linux-and-azure/blob/main/images/welcome_grafana.jpg)


Docs https://grafana.com/docs/grafana/latest/datasources/mysql/

## MySQL data source basic

Lets add our mysql database and trend the tags since we now can login.

```sql
CREATE USER 'grafanaReader'@'%' IDENTIFIED BY 'Noshareing789';
GRANT SELECT ON telegraf_db.*  TO 'grafanaReader'@'%';

mysql -u grafanaReader -p 
-- privde pass
use telegraf_db;

select * from tag1;
-- 2226 rows in set (0.00 sec)

```

The go to the webpage and add mysql connection.

![Mysql ok](https://github.com/spawnmarvel/linux-and-azure/blob/main/images/mysql_ok_1.jpg)


Now lets get the data from tag1 and tag2 tables.

The code editor was better.



```sql
-- a
SELECT value, time FROM telegraf_db.tag2 ORDER BY time desc

--b 
SELECT value, time FROM telegraf_db.tag1 ORDER BY time desc

```

![Mysql data](https://github.com/spawnmarvel/linux-and-azure/blob/main/images/mysql_data.jpg)

Docs https://grafana.com/docs/grafana/latest/datasources/mysql/

## MySQL data source advanced (tbd)

Read more and view tips and tricks https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/mysql/README_mysql_grafana_editor.md


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


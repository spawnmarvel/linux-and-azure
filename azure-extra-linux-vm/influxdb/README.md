

# Influxdb

## Community

## Github and Visuals elo

https://follow-e-lo.com/tag/influxdb/


## Influxdb docs

https://docs.influxdata.com/influxdb/v2/

## Don’t have too many series

In no particular order, we recommend that you:

Encode meta data in tags
Tags are indexed and fields are not indexed. This means that queries on tags are more performant than those on fields.

In general, your queries should guide what gets stored as a tag and what gets stored as a field:

Store data in tags if they’re commonly-queried meta data
Store data in tags if you plan to use them with GROUP BY()
Store data in fields if you plan to use them with an InfluxQL function
Store data in fields if you need them to be something other than a string - tag values are always interpreted as strings


Don’t have too many series
Tags containing highly variable information like UUIDs, hashes, and random strings will lead to a large number of series in the database, known colloquially as high series cardinality. High series cardinality is a primary driver of high memory usage for many database workloads.

See Hardware sizing guidelines for series cardinality recommendations based on your hardware. If the system has memory constraints, consider storing high-cardinality data as a field rather than a tag.

https://blog.zhaw.ch/icclab/influxdb-design-guidelines-to-avoid-performance-issues/


However, there is a huge caveat – a series cardinality being a major factor that affects RAM requirements. Based on the most recent InfluxDB hardware sizing guidelines, you will need around 2-4 GB of RAM for a low load with less than 100,000 unique series. Imagine that your database consists of one measurement that has only two tags, but those values are highly dynamic, both in the thousands. This would result in the need for more than 32 GB, because InfluxDB would try to construct an inverted index in memory, which would always be growing with the cardinality.

A rule of thumb would be to persist highly dynamic values as fields and only use tags for GROUP BY clauses and InfluxQL functions, carefully designing your application around it. 

## Install influxdb

OS: Linux vmdocker01 6.5.0-1023-azure #24~22.04.1-Ubuntu

Influxdb

https://docs.influxdata.com/influxdb/v2/install/?t=Linux#install-influxdb-as-a-service-with-systemd


This seems to have changed on the install page, now it uses checksum and compare

```bash
# check what we have
dpkg --print-architecture

# amd64

# Ubuntu/Debian AMD64
curl -LO https://download.influxdata.com/influxdb/releases/influxdb2_2.7.8-1_amd64.deb
sudo dpkg -i influxdb2_2.7.8-1_amd64.deb


# start the influx db server
sudo service influxdb start

# verify services
sudo service influxdb status

# Installing the InfluxDB package creates a service file at /lib/systemd/system/influxdb.service to start InfluxDB as a background service on startup.

```

InfluxDB Downloads

```bash
# select version stable and platform (ubuntu & debian)

sudo nano influxdb_install.sh

# copy the bash lines into to the script

#!bin/bash

# influxdata-archive_compat.key GPG fingerprint:
#     9D53 9D90 D332 8DC7 D6C8 D3B9 D8FF 8E1F 7DF8 B07E
wget -q https://repos.influxdata.com/influxdata-archive_compat.key
echo '393e8779c89ac8d958f81f942f9ad7fb82a25e133faddaf92e15b16e6ac9ce4c influxdata-archive_compat.key' | sha256sum -c && cat influxdata-archive_compat.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg > /dev/null
echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg] https://repos.influxdata.com/debian stable main' | sudo tee /etc/apt/sources.list.d/influxdata.list

sudo apt-get update && sudo apt-get install influxdb2

bash influxdb_install.sh

```


https://www.influxdata.com/downloads/


## Python agent

Example write_structured_data.py

https://github.com/influxdata/influxdb-client-python/blob/master/examples/write_structured_data.py

How to ingest large DataFrame by splitting into chunks.

https://github.com/influxdata/influxdb-client-python/blob/master/examples/ingest_large_dataframe.py



config.json


```bash
mkdir influx_runner

ls

config.json  run_influx.py
```
```py
{
    "connection_information" :[
        {
        "ip" : "10.0.0.255",
        "token" : "sometok",
         "bucket" : "bucket1",
        "organization": "Liam"
        }
        
    ]
}
```

* Install Dependencies
* * pip install influxdb-client
* Get Token
* Initialize Client
* Write data


https://docs.influxdata.com/influxdb/cloud/api-guide/client-libraries/python/


## Python agent batch

https://www.influxdata.com/blog/writing-data-to-influxdb-with-python/

## Resolve high series cardinality

If reads and writes to InfluxDB have started to slow down, high series cardinality (too many series) may be causing memory issues.

InfluxDB indexes the following data elements to speed up reads:

* measurement
* tags
* not fields



https://docs.influxdata.com/influxdb/v2/write-data/best-practices/resolve-high-cardinality/

## Influxdb Key concepts before you get started


The InfluxDB data model organizes time series data into buckets and measurements. A bucket can contain multiple measurements. Measurements contain multiple tags and fields.


* Bucket: Named location where time series data is stored. A bucket can contain multiple measurements.
* * Measurement: Logical grouping for time series data. All points in a given measurement should have the same tags. A measurement contains multiple tags and fields.
* * * Tags: Key-value pairs with values that differ, but do not change often. Tags are meant for storing metadata for each point–for example, something to identify the source of the data like host, location, station, etc.
* * *  Fields: Key-value pairs with values that change over time–for example: temperature, pressure, stock price, etc.
* * *  Timestamp: Timestamp associated with the data. When stored on disk and queried, all data is ordered by time.

[...]

![Quick 1 ](https://github.com/spawnmarvel/linux-and-azure/blob/main/images/influxpoint.jpg)


https://docs.influxdata.com/influxdb/v2/get-started/#:~:text=The%20InfluxDB%20data%20model%20organizes,time%20series%20data%20is%20stored.


```py
"""
Prepare data
"""

point = Point("h2o_feet") \
    .field("water_level", 10) \
    .tag("location", "pacific") \
    .time('1996-02-25T21:20:00.001001231Z')

```

https://influxdb-client.readthedocs.io/en/latest/usage.html#nanosecond-precision

bucket

A bucket is a named location where time series data is stored. All buckets have a retention period. A bucket belongs to an organization.


By default, buckets in InfluxDB 2.7 have an implicit schema that lets you write data without restrictions on columns, fields, or data types.


https://docs.influxdata.com/influxdb/v2/reference/glossary/#bucket


Create a bucket

https://docs.influxdata.com/influxdb/v2/admin/buckets/create-bucket/?t=influx+CLI


## Functions Influxdb dashboard

* Query data
* Visualize data
* Process data
* Monitor and alerts
* Tools and integration
* Administer Influxdb
* Influxdb http api

View https://follow-e-lo.com/tag/influxdb/


## Monitor and alerts

Lets tests the monitor and alerting functions.

View https://follow-e-lo.com/tag/influxdb/

## Administer InfluxDB

TLS

```bash
sudo openssl req -x509 -nodes -newkey rsa:2048 \
  -keyout /etc/ssl/influxdb-selfsigned.key \
  -out /etc/ssl/influxdb-selfsigned.crt \
  -days <NUMBER_OF_DAYS>



sudo openssl -req x509 -nodes -newkey rsa:2048 -keyout /etc/ssl/influxdb-selfsigned.key -out /etc/ssl/influxdb-selfsigned.crt -days 3365

# The openssl command prompts you for optional fields that you can fill out or leave blank; both actions generate valid certificate files.


# 644 means you can read and write the file or directory and other users can only read it.
# 600 permissions means that only the owner of the file has full read and write access to it
sudo chmod 644 /etc/ssl/influxdb-selfsigned.crt
sudo chmod 600 /etc/ssl/influxdb-selfsigned.key


# config
# https://docs.influxdata.com/enterprise_influxdb/v1/administration/configure/security/enable_tls/
# https://docs.influxdata.com/influxdb/v2/reference/config-options/
# https://community.influxdata.com/t/influxdb-2-config-file-ssl/17088/8

cd /etc/influxdb
cat config.toml
cp config.toml config.toml_bck
sudo nano config.toml

# add
tls-cert = "/etc/ssl/influxdb-selfsigned.crt"
tls-key = "/etc/ssl/influxdb-selfsigned.key"


sudo service influxdb stop
sudo service influxdb start

# https
https://localhost:8086


# Or to test your certificates, access InfluxDB using the https:// protocol–for example, using cURL
curl --verbose https://localhost:8086/api/v2/ping

# If using a self-signed certificate, skip certificate verification–for example, in a cURL command, pass the
curl --verbose --insecure https://localhost:8086/api/v2/ping

# or visit the site on https



```
https://docs.influxdata.com/influxdb/v2/admin/security/enable-tls/#Copyright


Forgot password to user?

```bash

# list users

influxd recovery user list

# get token

sudo cat /var/lib/influxdb/influxd.bolt | strings | grep "username's Token"


influx user password -n username -t the-token
? Please type new password for "username" *********************
? Please type new password for "username" again *********************
Successfully updated password for user "username"

# remove cache in browser

```

### Config files

***InfluxDB file structure***:

Engine path: Directory path to the storage engine, where InfluxDB stores time series data, includes the following directories:

* data: Stores time-structured merge tree (TSM) files
* replicationq: Store the replication queue for the InfluxDB replication service
* wal: Stores write-ahead log (WAL) files.
 (To customize this path, use the engine-path configuration option)

Bolt path:

* File path to the Boltdb database, a file-based key-value store for non-time series data, such as InfluxDB users, dashboards, and tasks. 
(To customize this path, use the bolt-path configuration option.)

SQLite path: 
* File path to the SQLite database, an SQL database for non-time series data, such as InfluxDB notebooks and annotations. 
(To customize this path, use the sqlite-path configuration option.)

Configs path:

* File path to influx CLI connection configurations (configs).


***File system layout***

* macOs, Linux, Windows, Docker and Kubernets


Installed as a package (as above step 1 or 2)

InfluxDB 2.7 supports .deb- and .rpm-based Linux package managers. The file system layout is the same with each.

```bash
# Linux
# Engine path (data)
/var/lib/influxdb/engine/

# Bolt path
/var/lib/influxdb/influxd.bolt

# SQLite path
/var/lib/influxdb/influxd.sqlite

# Configs path
/var/lib/influxdb/configs

# Default config file path
/etc/influxdb/config.toml


sudo su

root@vmdocker01:/var/lib/influxdb# ls
engine  influxd.bolt  influxd.pid  influxd.sqlite

root@vmdocker01:/etc/influxdb# ls
config.toml  config.toml_bck

```

https://docs.influxdata.com/influxdb/v2/reference/internals/file-system-layout/#Copyright




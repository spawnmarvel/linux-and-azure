

# Influxdb and telegraf

## Community

You need to install telegraf on each server where it can collect an absolute myriad of performance data (any perfmon data). 


https://www.reddit.com/r/grafana/comments/mmvd32/how_are_you_monitoring_your_windows_servers/?rdt=46504


Grafana shows the data, Influx stores the data, and Telegraf... is a helper. If a device could send its measurements directly to Influx, you would not need Telegraf for that device.

https://www.reddit.com/r/selfhosted/comments/uaoue8/grafana_telegraf_influxdb2_question/

Telegraf, InfluxDB & Grafana is one of the way of setting up Observability which many organization is following now a days. There are other well established ways using Prometheus & Grafana. A Prometheus server pulls its data by scraping HTTP endpoints. The endpoints provide a continuous stream, allowing the Prometheus server to collect real-time data. Whereas Telegraf is a plug-in-driven agent that enables the collection of metrics from different sources and data is stored InfluxDB.

https://medium.com/@samirsaha214/observability-using-telegraf-influxdb-grafana-in-kubernetes-9aa39ee5674f


Telegraf supports both push-based and pull-based methods for these formats.

Telegraf is an agent for collecting, processing, aggregating, and writing metrics, logs, and other arbitrary data.

https://docs.influxdata.com/telegraf/v1/install/

## Youtube Infrastructure Monitoring Basics with Telegraf, Grafana and InfluxDB - Jay Clifford, InfluxData

https://www.youtube.com/watch?v=ESub4SAKouI

## Github and Visuals elo

https://follow-e-lo.com/tag/influxdb/

## Telegraf docs

https://docs.influxdata.com/telegraf/v1/


## Influxdb docs

https://docs.influxdata.com/influxdb/v2/

## Install influxdb and Telegraf on linux

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



## Telegraf

Telegraf supports both push-based and pull-based methods for these formats.

Telegraf is an agent for collecting, processing, aggregating, and writing metrics, logs, and other arbitrary data.

https://docs.influxdata.com/telegraf/v1/install/


## To connect Telegraf to an InfluxDB 2.7 instance with TLS enabled

https://docs.influxdata.com/influxdb/v2/admin/security/enable-tls/#connect-telegraf-to-a-secured-influxdb-instance


# Telegraf remote Digital Ocean tbd


```bash
#

```

https://www.digitalocean.com/community/tutorials/how-to-monitor-system-metrics-with-the-tick-stack-on-ubuntu-16-04


# Telegraf 101 

https://follow-e-lo.com/2024/08/29/influxdb-and-telegraf-agent/

## Telegraf on windows


Download binaries

```ps1

cd ~\Downloads

# https://www.influxdata.com/downloads/

# replace wget with Invoke

Invoke-WebRequest https://dl.influxdata.com/telegraf/releases/telegraf-1.32.0_windows_amd64.zip -OutFile telegraf.zip

# Next, let’s extract the archive into Program Files folder, which will create C:\Program Files\telegraf folder:

mkdir 'C:\Program Files\Telegraf'

Expand-Archive .\telegraf.zip 'C:\Program Files\Telegraf\'


cd 'C:\Program Files\Telegraf\telegraf-1.32.0\'

ls

telegraf.conf
telegraf.exe

# Then create a conf subdirectory and copy the telegraf.conf as conf\inputs.conf:

mkdir conf

cd conf

copy ..\telegraf.conf telegraf.conf


```

Cleean the file to empty


Make the json file

```json
{
    "tag1": {
        "value": 100,
        "active": 1,
		"state": 0
    }
}

```

TOML for our Agent

https://github.com/toml-lang/toml

```toml
[agent]
 interval = "30s" 
 round_interval = true
 metric_batch_size = 1000 
 metric_buffer_limit = 10000
 collection_jitter = "0s" 
 flush_interval = "30s"
 flush_jitter = "5s" precision = ""
 debug = false
 quiet = true
 logfile = "C://Program Files//Telegraf//telegraf-1.32.0//telegraf.logs"


###############################################################################
#                                  INPUTS                                     #
###############################################################################
[[inputs.file]]
  ## Files to parse each interval.  Accept standard unix glob matching rules,
  ## as well as ** to match recursive files and directories.
  files = ["C://Program Files//Telegraf//telegraf-1.32.0//metrics.in.json"]
  
  ## Data format to consume.
  ## Each data format has its own unique set of configuration options, read
  ## more about them here:
  ## https://github.com/influxdata/telegraf/blob/master/docs/DATA_FORMATS_INPUT.md
  ## data_format = "influx"
  data_format = "json"
  
###############################################################################
#                                  OUTPUTS                                     #
###############################################################################


# Send telegraf metrics to file(s)
[[outputs.file]]
  ## Files to write to, "stdout" is a specially handled file.
  files = ["C:/Program Files/Telegraf/telegraf-1.32.0//metrics.out.json"]
  
    ## Data format to consume.
  ## Each data format has its own unique set of configuration options, read
  ## more about them here:
  ## https://github.com/influxdata/telegraf/blob/master/docs/DATA_FORMATS_INPUT.md
  ## data_format = "influx"
  data_format = "json"

```

Or splitt it in two, one input.conf and one output.conf for information used in output, db, user etc

```toml
###############################################################################
#                                  OUTPUTS                                     #
###############################################################################


# Send telegraf metrics to file(s)
[[outputs.file]]
  ## Files to write to, "stdout" is a specially handled file.
  files = ["C:/Program Files/Telegraf/telegraf-1.32.0//metrics.out.json"]
  
    ## Data format to consume.
  ## Each data format has its own unique set of configuration options, read
  ## more about them here:
  ## https://github.com/influxdata/telegraf/blob/master/docs/DATA_FORMATS_INPUT.md
  ## data_format = "influx"
  data_format = "json"

```

At this point it is a good idea to test that Telegraf works correctly

```ps1

.\telegraf --config-directory 'C:\Program Files\Telegraf\telegraf-1.32.0\conf\' --test

2024-09-22T15:15:27Z I! Loading config: C:\Program Files\Telegraf\telegraf-1.32.0\conf\telegraf.conf
{"fields":{"tag1_active":1,"tag1_state":0,"tag1_value":100},"name":"file","tags":{"host":"BER-0803"},"timestamp":1727018130}
{"fields":{"tag1_active":1,"tag1_state":0,"tag1_value":100},"name":"file","tags":{"host":"BER-0803"},"timestamp":1727018160}
{"fields":{"tag1_active":1,"tag1_state":0,"tag1_value":100},"name":"file","tags":{"host":"BER-0803"},"timestamp":1727018190}

# It rolls 4 ever


# Security for user and token
# Next, let’s ensure that only the Local System user account can read the outputs.conf file to prevent unauthorized users from retrieving our access token for InfluxDB.
# https://www.influxdata.com/blog/using-telegraf-on-windows/

icacls outputs.conf /reset
icacls outputs.conf /inheritance:r /grant system:r



# We skip security for now, install it as a service

.\telegraf --service install --config-directory 'C:\Program Files\Telegraf\telegraf-1.32.0\conf\'
The use of --service is deprecated, please use the 'service' command instead!
Successfully installed service "telegraf"

# start it

net start telegraf
The Telegraf Data Collector Service service is starting.
The Telegraf Data Collector Service service was started successfully.



```





How to:

https://www.influxdata.com/blog/using-telegraf-on-windows/


Version

https://www.influxdata.com/downloads/







### File input and output ***




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

```

## Python agent


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



## Telegraf TBD

Telegraf supports both push-based and pull-based methods for these formats.

Telegraf is an agent for collecting, processing, aggregating, and writing metrics, logs, and other arbitrary data.

https://docs.influxdata.com/telegraf/v1/install/


## To connect Telegraf to an InfluxDB 2.7 instance with TLS enabled

https://docs.influxdata.com/influxdb/v2/admin/security/enable-tls/#connect-telegraf-to-a-secured-influxdb-instance
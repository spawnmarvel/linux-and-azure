

# Influxdb and telegraf

## Telegraf

https://docs.influxdata.com/telegraf/v1/install/


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

Python agent


Telegraf

https://docs.influxdata.com/telegraf/v1/install/



## Github and Visuals elo

https://github.com/spawnmarvel/linux-and-azure/tree/main/azure-extra-linux-vm/influxdb-telegraf

## Influxdb Key concepts before you get started


The InfluxDB data model organizes time series data into buckets and measurements. A bucket can contain multiple measurements. Measurements contain multiple tags and fields.


* Bucket: Named location where time series data is stored. A bucket can contain multiple measurements.
* * Measurement: Logical grouping for time series data. All points in a given measurement should have the same tags. A measurement contains multiple tags and fields.
* * * Tags: Key-value pairs with values that differ, but do not change often. Tags are meant for storing metadata for each point–for example, something to identify the source of the data like host, location, station, etc.
* * *  Fields: Key-value pairs with values that change over time–for example: temperature, pressure, stock price, etc.
* * *  Timestamp: Timestamp associated with the data. When stored on disk and queried, all data is ordered by time.

[...]


https://docs.influxdata.com/influxdb/v2/get-started/#:~:text=The%20InfluxDB%20data%20model%20organizes,time%20series%20data%20is%20stored.


bucket

A bucket is a named location where time series data is stored. All buckets have a retention period. A bucket belongs to an organization.


By default, buckets in InfluxDB 2.7 have an implicit schema that lets you write data without restrictions on columns, fields, or data types.


https://docs.influxdata.com/influxdb/v2/reference/glossary/#bucket


Create a bucket

https://docs.influxdata.com/influxdb/v2/admin/buckets/create-bucket/?t=influx+CLI



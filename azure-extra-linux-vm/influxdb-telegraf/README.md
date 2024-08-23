

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

## Github and Visuals elo

https://github.com/spawnmarvel/linux-and-azure/tree/main/azure-extra-linux-vm/influxdb-telegraf

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

https://docs.influxdata.com/influxdb/cloud/api-guide/client-libraries/python/


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




## Telegraf TBD

Telegraf supports both push-based and pull-based methods for these formats.

Telegraf is an agent for collecting, processing, aggregating, and writing metrics, logs, and other arbitrary data.

https://docs.influxdata.com/telegraf/v1/install/
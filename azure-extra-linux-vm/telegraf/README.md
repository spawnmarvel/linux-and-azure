# Telegraf

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

## Github and visuals elo

https://follow-e-lo.com/2024/08/29/influxdb-and-telegraf-agent/

## Telegraf docs

https://docs.influxdata.com/telegraf/v1/

## Telegraf

Telegraf supports both push-based and pull-based methods for these formats.

Telegraf is an agent for collecting, processing, aggregating, and writing metrics, logs, and other arbitrary data.

https://docs.influxdata.com/telegraf/v1/install/


## To connect Telegraf to an InfluxDB 2.7 instance with TLS enabled

https://docs.influxdata.com/influxdb/v2/admin/security/enable-tls/#connect-telegraf-to-a-secured-influxdb-instance



# Documentation and tutorial

## Install (in this example windows)


Download binaries

```ps1

cd ~\Downloads

# https://www.influxdata.com/downloads/

# replace wget with Invoke

Invoke-WebRequest https://dl.influxdata.com/telegraf/releases/telegraf-1.32.0_windows_amd64.zip -OutFile telegraf-1.32.0.zip

# Next, let’s extract the archive into Program Files folder, which will create C:\Program Files\telegraf folder:

mkdir 'C:\Program Files\Telegraf'

Expand-Archive .\telegraf-1.32.0.zip 'C:\Program Files\Telegraf\'


cd 'C:\Program Files\Telegraf\telegraf-1.32.0\'

ls

telegraf.conf
telegraf.exe

# Then create a conf subdirectory and copy the telegraf.conf to the new conf folder

mkdir conf

cd conf

copy ..\telegraf.conf telegraf.conf


```

TOML for our Agent

https://github.com/toml-lang/toml

view .\telegraf\telegraf_file_file.conf as example in this repository.

in conf\telegraf.conf, remove all and paste below config from telegraf_file_file.conf into telegraf.conf  in the file and save it.


Make the json file for the input

```json
{
    "tag1": {
        "value": 100,
        "active": 1,
		"state": 0
    }
}

```


For security you could:

Splitt it in two, one input.conf and one output.conf for information used in output, db, user etc, this is for security when using token and keys, you can then secure only the output.conf.

The you have two files, input.conf and output.conf in conf\, we do not have that now.


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

Yoy can now view the log file
```log
2024-09-22T15:41:27Z I! Loading config: C:\Program Files\Telegraf\telegraf-1.32.0\conf\telegraf.conf
2024-09-22T15:41:27Z I! Starting Telegraf 1.32.0 brought to you by InfluxData the makers of InfluxDB
2024-09-22T15:41:27Z I! Available plugins: 235 inputs, 9 aggregators, 32 processors, 26 parsers, 62 outputs, 5 secret-stores
2024-09-22T15:41:27Z I! Loaded inputs: file
2024-09-22T15:41:27Z I! Loaded aggregators:
2024-09-22T15:41:27Z I! Loaded processors:
2024-09-22T15:41:27Z I! Loaded secretstores:
2024-09-22T15:41:27Z I! Loaded outputs: file
2024-09-22T15:41:27Z I! Tags enabled: host=BER-0803
2024-09-22T15:41:27Z I! [agent] Config: Interval:30s, Quiet:false, Hostname:"BER-0803", Flush Interval:30s
2024-09-22T15:41:27Z D! [agent] Initializing plugins
2024-09-22T15:41:27Z D! [agent] Connecting outputs
2024-09-22T15:41:27Z D! [agent] Attempting connection to [outputs.file]
2024-09-22T15:41:27Z D! [agent] Successfully connected to outputs.file
2024-09-22T15:41:27Z D! [agent] Starting service inputs
2024-09-22T15:42:01Z D! [outputs.file] Wrote batch of 2 metrics in 0s

```


How to:

https://www.influxdata.com/blog/using-telegraf-on-windows/


Version

https://www.influxdata.com/downloads/



## Get started TODO

After you’ve downloaded and installed Telegraf, you’re ready to begin collecting and sending data. To collect and send data, do the following:

1. Configure Telegraf
2. Start Telegraf
3. Use plugins available in Telegraf to gather, transform, and output data.

### Logging and troubleshooting

Windows service commands

```ps1
.\telegraf --config-directory 'C:\Program Files\Telegraf\telegraf-1.32.0\conf\' --test # test

telegraf.exe --service install	# Install telegraf as a service
telegraf.exe --service uninstall # 	Remove the telegraf service
telegraf.exe --service start # 	Start the telegraf service
telegraf.exe --service stop	# Stop the telegraf service


# Create a configuration file with default input and output plugins
.\telegraf.exe config > telegraf.conf

# Create a configuration file with specific input and output plugins
.\telegraf.exe `
--input-filter cpu:http `
--output-filter influxdb_v2:file `
config > telegraf.conf

```



## Configure plugins TODO

## Input plugins TODO

## Output plugins TODO

## Aggregator and processor plugins TODO

## External plugins TODO

## Troubleshoot TODO


https://docs.influxdata.com/telegraf/v1/get-started/

### Telegraf Best Practices: Config Recommendations and Performance Monitoring

https://www.influxdata.com/blog/telegraf-best-practices/

In many use cases, Telegraf is being deployed to ingest data from multiple input sources and deliver that data to either InfluxDB or other enterprise platforms (as shown in the below example).


### Test telegraf.conf with a given config

```ps1

cd 'C:\Program Files\Telegraf\telegraf-1.32.0\'
.\telegraf --config-directory 'C:\Program Files\Telegraf\telegraf-1.32.0\conf\' --test

# only inputs can be tested
file,host=BER-0803 tag1_value=100 1727211303000000000


```
# Plugins input

File Input Plugin = ok

https://github.com/influxdata/telegraf/blob/master/plugins/inputs/file/README.md

```json

{
    "tag1": {
        "value": 100,
        "active": 1,
		"state": 0
    }
}

```
or 

```json
{
    "tag1": {
        "value": 100
    }
}

```
WMI Input Plugin = 

https://github.com/influxdata/telegraf/blob/master/plugins/inputs/win_wmi/README.md

# Plugins output

File Output Plugin=  ok

https://github.com/influxdata/telegraf/blob/master/plugins/outputs/file/README.md


```log

2024-09-23T20:24:39Z D! [agent] Initializing plugins
2024-09-23T20:24:39Z D! [agent] Connecting outputs
2024-09-23T20:24:39Z D! [agent] Attempting connection to [outputs.file]
2024-09-23T20:24:39Z D! [agent] Successfully connected to outputs.file
2024-09-23T20:24:39Z D! [agent] Starting service inputs
2024-09-23T20:25:11Z D! [outputs.file] Wrote batch of 1 metrics in 0s
2024-09-23T20:25:11Z D! [outputs.file] Buffer fullness: 0 / 10000 metrics
2024-09-23T20:25:45Z D! [outputs.file] Wrote batch of 1 metrics in 160.3µs
2024-09-23T20:25:45Z D! [outputs.file] Buffer fullness: 0 / 10000 metrics
```


RabbitMQ Output Plugin = ok

https://github.com/influxdata/telegraf/blob/master/plugins/outputs/amqp/README.md

```log
2024-09-23T20:36:40Z D! [agent] Initializing plugins
2024-09-23T20:36:40Z D! [agent] Connecting outputs
2024-09-23T20:36:40Z D! [agent] Attempting connection to [outputs.amqp]
2024-09-23T20:36:40Z D! [outputs.amqp] Connecting to "amqp://localhost:5672/"
2024-09-23T20:36:40Z D! [outputs.amqp] Connected to "amqp://localhost:5672/"
2024-09-23T20:36:40Z D! [agent] Successfully connected to outputs.amqp
2024-09-23T20:36:40Z D! [agent] Starting service inputs
2024-09-23T20:37:14Z D! [outputs.amqp] Wrote batch of 1 metrics in 11.0807ms
2024-09-23T20:37:14Z D! [outputs.amqp] Buffer fullness: 0 / 10000 metrics
2024-09-23T20:37:47Z D! [outputs.amqp] Wrote batch of 1 metrics in 0s
2024-09-23T20:37:47Z D! [outputs.amqp] Buffer fullness: 0 / 10000 metrics

```


Zabbix Output Plugin =

If we assume a file input on format:

````json
{
        "host":"test-vm01"
        "rmp": 32
}

and zabbix_sender.exe example would then be:

```bash

sudo apt install zabbix-sender

cd ./bin

./zabbix_sender -z localhost -s "test-vm01" -k telegraf.rpm -o 25 -vv
```
Log from shell

```log

zabbix_sender [12335]: DEBUG: answer [{"response":"success","info":"processed: 1; failed: 0; total: 1; seconds spent: 0.000092"}]
Response from "localhost:10051": "processed: 1; failed: 0; total: 1; seconds spent: 0.000092"
sent: 1; skipped: 0; total: 1

```
And we get have the value 25 in zabbix.


Lets check the output in a file to file telegraf given above json and data_format = "json":

metrics.out.json

```log 
{"fields":{"rpm":25},"name":"file","tags":{"host":"BER-0803"},"timestamp":1727474460}

```

Lets start Telegraf and check what we are sending to zabbix.

```log
2024-09-27T22:30:22Z I! Loaded inputs: file
2024-09-27T22:30:22Z I! Loaded aggregators:
2024-09-27T22:30:22Z I! Loaded processors:
2024-09-27T22:30:22Z I! Loaded secretstores:
2024-09-27T22:30:22Z I! Loaded outputs: zabbix
2024-09-27T22:30:22Z I! Tags enabled: host=BER-0803
2024-09-27T22:30:22Z I! [agent] Config: Interval:15s, Quiet:false, Hostname:"BER-0803", Flush Interval:30s
2024-09-27T22:30:22Z D! [agent] Initializing plugins
2024-09-27T22:30:22Z D! [agent] Connecting outputs
2024-09-27T22:30:22Z D! [agent] Attempting connection to [outputs.zabbix]
2024-09-27T22:30:22Z D! [agent] Successfully connected to outputs.zabbix
2024-09-27T22:30:22Z D! [agent] Starting service inputs
2024-09-27T22:30:56Z D! [outputs.zabbix] Wrote batch of 2 metrics in 77.8245ms
2024-09-27T22:30:56Z D! [outputs.zabbix] Buffer fullness: 0 / 10000 metrics

```

It is sent, but not shwoing in zabbix


Lets make two outputs in the same file

Telegraf log

```log
2024-09-27T22:37:19Z I! Loaded outputs: file zabbix
2024-09-27T22:37:19Z I! Tags enabled: host=BER-0803
2024-09-27T22:37:19Z I! [agent] Config: Interval:15s, Quiet:false, Hostname:"BER-0803", Flush Interval:30s
2024-09-27T22:37:19Z D! [agent] Initializing plugins
2024-09-27T22:37:19Z D! [agent] Connecting outputs
2024-09-27T22:37:19Z D! [agent] Attempting connection to [outputs.zabbix]
2024-09-27T22:37:19Z D! [agent] Successfully connected to outputs.zabbix
2024-09-27T22:37:19Z D! [agent] Attempting connection to [outputs.file]
2024-09-27T22:37:19Z D! [agent] Successfully connected to outputs.file
2024-09-27T22:37:19Z D! [agent] Starting service inputs
```

https://github.com/influxdata/telegraf/blob/master/plugins/outputs/zabbix/README.md

It is sending, but on what format, read above github

Ref github
Given this Telegraf metric:

```log
measurement,host=hostname valueA=0,valueB=1

```
It will generate this Zabbix metrics:

```log

{"host": "hostname", "key": "telegraf.measurement.valueA", "value": "0"}
{"host": "hostname", "key": "telegraf.measurement.valueB", "value": "1"}
```



InfluxDB Output Plugin = 

https://github.com/influxdata/telegraf/blob/master/plugins/outputs/influxdb_v2/README.md

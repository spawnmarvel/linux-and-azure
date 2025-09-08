# Telegraf

## Lightweight ETL (Extract, Transform, Load) tool

Telegraf is primarily designed as a server agent for collecting, processing, aggregating, and writing metrics and events, but it can be adapted to serve as a lightweight ETL (Extract, Transform, Load) tool in certain use cases. Here’s how Telegraf can fit into the ETL framework:


1. **Extract**:
   - Telegraf can extract data from a wide variety of sources using its input plugins. These include databases (e.g., MySQL, PostgreSQL), message queues (e.g., Kafka, MQTT), APIs, system metrics, and other services.
   - It can also extract time-series metrics, logs, and events from various systems.

2. **Transform**:
   - Telegraf has basic data transformation capabilities. Using its processor plugins, you can:
     - Modify fields and tags
     - Perform mathematical operations
     - Filter and aggregate data
   - It’s not as feature-rich as dedicated ETL tools in terms of complex transformations like joins or extensive data reshaping, but it can handle simpler transformations and filtering tasks.

3. **Load**:
   - Telegraf can write processed data to a variety of destinations, such as databases (e.g., InfluxDB, PostgreSQL), cloud-based services (e.g., AWS, Google Cloud), message queues (e.g., Kafka), and others.
   - It supports a wide range of output plugins, making it flexible for loading data into different storage systems.

### When Telegraf Can Be Used as an ETL Tool:
- **Low to Moderate Complexity**: Telegraf works well for simple to moderately complex ETL tasks, particularly in environments focused on time-series or metric-based data.
- **Real-Time Data Pipelines**: If you're dealing with real-time data (e.g., metrics from servers or applications), Telegraf excels at streaming this data from various sources, performing lightweight processing, and sending it to multiple destinations.
- **Event-Driven Workflows**: Telegraf can also be used in event-driven workflows where the data needs to be processed and moved with low latency.

### When Telegraf May Not Be the Best Fit:
- **Complex Transformations**: If you need complex data transformations (e.g., joins between datasets, complex aggregations, or restructuring of data), Telegraf’s capabilities are limited compared to full-featured ETL tools like Apache NiFi, Talend, or AWS Glue.
- **Batch Processing**: While Telegraf can handle real-time and streaming data well, it is not designed for large-scale batch processing or scheduled jobs common in traditional ETL pipelines.

### Comparison with Traditional ETL Tools:
- **Pros**:
  - Lightweight and efficient for real-time data collection and processing.
  - Easy to configure and deploy.
  - Supports a wide range of input and output plugins for seamless integration with many services.
  
- **Cons**:
  - Limited transformation capabilities.
  - Not suited for heavy-duty data cleaning, enrichment, or complex transformations.
  - Primarily optimized for metrics and event-based data rather than relational or structured data from traditional business systems.

### Example Scenario:
Let’s say you want to collect server metrics (CPU, memory, disk usage) from multiple servers, transform the data to only keep specific fields, and then load the output into an InfluxDB database for monitoring. Telegraf can easily handle this ETL pipeline by:
- Extracting the metrics using the appropriate input plugin.
- Transforming the data by filtering out unnecessary fields.
- Loading the results into InfluxDB for monitoring and alerting.

### Conclusion:
Telegraf can be used as a lightweight ETL tool for simple to moderately complex use cases, especially when dealing with real-time metric or event-based data. However, for more complex ETL pipelines requiring sophisticated data transformations, you may need to use a more robust ETL platform.
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

## Youtube Using Telegraf

https://www.youtube.com/watch?v=5udeIDpcUxM&list=PLYt2jfZorkDquBA6OHdS1cTK1bKwwMcUs

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

Let's teste the above ps1 and createa config

```ps1
PS C:\Program Files\Telegraf\telegraf-1.32.0> .\telegraf.exe --input-filter cpu --output-filter file config > telegraf.conf
```

Change the path from linux to windows:

* files = ["stdout", "/tmp/metrics.out"]
* files = ["C://Program Files//Telegraf//telegraf-1.32.0//file//file.out"]

Copy the telegraf.conf to the conf folder and test it.

```ps1

 .\telegraf.exe --config-directory 'C:\Program Files\Telegraf\telegraf-1.32.0\conf\' --test
2024-09-29T09:21:18Z I! Loading config: C:\Program Files\Telegraf\telegraf-1.32.0\conf\telegraf.conf
2024-09-29T09:21:18Z I! Starting Telegraf 1.32.0 brought to you by InfluxData the makers of InfluxDB
2024-09-29T09:21:18Z I! Available plugins: 235 inputs, 9 aggregators, 32 processors, 26 parsers, 62 outputs, 5 secret-stores
2024-09-29T09:21:18Z I! Loaded inputs: cpu
2024-09-29T09:21:18Z I! Loaded aggregators:
2024-09-29T09:21:18Z I! Loaded processors:
2024-09-29T09:21:18Z I! Loaded secretstores:
2024-09-29T09:21:18Z W! Outputs are not used in testing mode!
2024-09-29T09:21:18Z I! Tags enabled: host=BER-0803
> cpu,cpu=cpu0,host=BER-0803 usage_guest=0,usage_guest_nice=0,usage_idle=96.875,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=3.125,usage_user=0 1727601679000000000

```
Now strip the conf so you only have ageent, input and output section for now.

(The default config had a big section on processor, but smaller on aggregator )

Result

```log
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":94.95841995841995,"usage_iowait":0,"usage_irq":0.2079002079002079,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":2.130977130977131,"usage_user":2.7027027027027026},"name":"cpu","tags":{"cpu":"cpu0","host":"BER-0803"},"timestamp":1727604270}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":98.33420093701197,"usage_iowait":0,"usage_irq":0.052056220718375845,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":0.7287870900572618,"usage_user":0.8849557522123894},"name":"cpu","tags":{"cpu":"cpu1","host":"BER-0803"},"timestamp":1727604270}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":93.7077483099324,"usage_iowait":0,"usage_irq":0.10400416016640665,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":2.3920956838273533,"usage_user":3.796151846073843},"name":"cpu","tags":{"cpu":"cpu2","host":"BER-0803"},"timestamp":1727604270}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":96.9807391983342,"usage_iowait":0,"usage_irq":0,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":0.8328995314940135,"usage_user":2.1863612701717856},"name":"cpu","tags":{"cpu":"cpu3","host":"BER-0803"},"timestamp":1727604270}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":96.92868297761582,"usage_iowait":0,"usage_irq":0.052056220718375845,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":1.2493492972410203,"usage_user":1.7699115044247788},"name":"cpu","tags":{"cpu":"cpu4","host":"BER-0803"},"timestamp":1727604270}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":98.33679833679834,"usage_iowait":0,"usage_irq":0.10395010395010396,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":0.4677754677754678,"usage_user":1.0914760914760915},"name":"cpu","tags":{"cpu":"cpu5","host":"BER-0803"},"timestamp":1727604270}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":97.91666666666667,"usage_iowait":0,"usage_irq":0,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":0.5729166666666666,"usage_user":1.5104166666666667},"name":"cpu","tags":{"cpu":"cpu6","host":"BER-0803"},"timestamp":1727604270}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":99.06347554630594,"usage_iowait":0,"usage_irq":0.05202913631633715,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":0.36420395421436,"usage_user":0.5202913631633714},"name":"cpu","tags":{"cpu":"cpu7","host":"BER-0803"},"timestamp":1727604270}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":98.22916666666667,"usage_iowait":0,"usage_irq":0,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":0.2604166666666667,"usage_user":1.5104166666666667},"name":"cpu","tags":{"cpu":"cpu8","host":"BER-0803"},"timestamp":1727604270}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":98.43912591050989,"usage_iowait":0,"usage_irq":0,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":0.2081165452653486,"usage_user":1.352757544224766},"name":"cpu","tags":{"cpu":"cpu9","host":"BER-0803"},"timestamp":1727604270}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":96.30208333333333,"usage_iowait":0,"usage_irq":0,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":1.25,"usage_user":2.4479166666666665},"name":"cpu","tags":{"cpu":"cpu10","host":"BER-0803"},"timestamp":1727604270}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":97.91449426485923,"usage_iowait":0,"usage_irq":0,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":0.31282586027111575,"usage_user":1.772679874869656},"name":"cpu","tags":{"cpu":"cpu11","host":"BER-0803"},"timestamp":1727604270}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":97.8125,"usage_iowait":0,"usage_irq":0,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":0.2604166666666667,"usage_user":1.9270833333333333},"name":"cpu","tags":{"cpu":"cpu12","host":"BER-0803"},"timestamp":1727604270}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":99.53149401353461,"usage_iowait":0,"usage_irq":0,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":0.20822488287350338,"usage_user":0.2602811035918792},"name":"cpu","tags":{"cpu":"cpu13","host":"BER-0803"},"timestamp":1727604270}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":95.525494276795,"usage_iowait":0,"usage_irq":0.05202913631633715,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":1.1966701352757545,"usage_user":3.225806451612903},"name":"cpu","tags":{"cpu":"cpu14","host":"BER-0803"},"timestamp":1727604270}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":99.58333333333333,"usage_iowait":0,"usage_irq":0,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":0.3645833333333333,"usage_user":0.052083333333333336},"name":"cpu","tags":{"cpu":"cpu15","host":"BER-0803"},"timestamp":1727604270}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":97.5103329319491,"usage_iowait":0,"usage_irq":0,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":0.8005988218830344,"usage_user":1.6890682461678654},"name":"cpu","tags":{"cpu":"cpu-total","host":"BER-0803"},"timestamp":1727604270}


```
CPU Input Plugin

https://github.com/influxdata/telegraf/blob/master/plugins/inputs/cpu/README.md

Lets add disk also

Disk Input Plugin

https://github.com/influxdata/telegraf/blob/master/plugins/inputs/disk/README.md

Update the telegraf.conf with configuration and start it


```logs
{"fields":{"free":267384700928,"inodes_free":0,"inodes_total":0,"inodes_used":0,"inodes_used_percent":0,"total":510770802688,"used":243386101760,"used_percent":47.650746769225634},"name":"disk","tags":{"device":"C:","fstype":"NTFS","host":"BER-0803","mode":"rw","path":"\\C:"},"timestamp":1727603940}
{"fields":{"free":416910110720,"inodes_free":0,"inodes_total":0,"inodes_used":0,"inodes_used_percent":0,"total":500105248768,"used":83195138048,"used_percent":16.635525872393796},"name":"disk","tags":{"device":"D:","fstype":"NTFS","host":"BER-0803","mode":"rw","path":"\\D:"},"timestamp":1727603940}
{"fields":{"free":989560467456,"inodes_free":0,"inodes_total":0,"inodes_used":0,"inodes_used_percent":0,"total":1099511627776,"used":109951160320,"used_percent":9.999999776482582},"name":"disk","tags":{"device":"Z:","fstype":"MFilesFS","host":"BER-0803","mode":"rw","path":"\\Z:"},"timestamp":1727603940}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":94.07176287051482,"usage_iowait":0,"usage_irq":0.2080083203328133,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":3.172126885075403,"usage_user":2.548101924076963},"name":"cpu","tags":{"cpu":"cpu0","host":"BER-0803"},"timestamp":1727603970}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":95.0546590317543,"usage_iowait":0,"usage_irq":0.10411244143675169,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":2.8110359187922955,"usage_user":2.030192608016658},"name":"cpu","tags":{"cpu":"cpu1","host":"BER-0803"},"timestamp":1727603970}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":94.6875,"usage_iowait":0,"usage_irq":0,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":2.5,"usage_user":2.8125},"name":"cpu","tags":{"cpu":"cpu2","host":"BER-0803"},"timestamp":1727603970}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":99.73958333333333,"usage_iowait":0,"usage_irq":0.052083333333333336,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":0.052083333333333336,"usage_user":0.15625},"name":"cpu","tags":{"cpu":"cpu3","host":"BER-0803"},"timestamp":1727603970}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":98.22916666666667,"usage_iowait":0,"usage_irq":0,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":1.09375,"usage_user":0.6770833333333334},"name":"cpu","tags":{"cpu":"cpu4","host":"BER-0803"},"timestamp":1727603970}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":99.6875,"usage_iowait":0,"usage_irq":0,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":0.2604166666666667,"usage_user":0.052083333333333336},"name":"cpu","tags":{"cpu":"cpu5","host":"BER-0803"},"timestamp":1727603970}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":96.19791666666667,"usage_iowait":0,"usage_irq":0.052083333333333336,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":0.9375,"usage_user":2.8125},"name":"cpu","tags":{"cpu":"cpu6","host":"BER-0803"},"timestamp":1727603970}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":98.80270692347736,"usage_iowait":0,"usage_irq":0,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":0.20822488287350338,"usage_user":0.9890681936491411},"name":"cpu","tags":{"cpu":"cpu7","host":"BER-0803"},"timestamp":1727603970}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":95.83333333333333,"usage_iowait":0,"usage_irq":0,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":1.3541666666666667,"usage_user":2.8125},"name":"cpu","tags":{"cpu":"cpu8","host":"BER-0803"},"timestamp":1727603970}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":97.50260145681581,"usage_iowait":0,"usage_irq":0,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":1.1446409989594173,"usage_user":1.352757544224766},"name":"cpu","tags":{"cpu":"cpu9","host":"BER-0803"},"timestamp":1727603970}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":98.69791666666667,"usage_iowait":0,"usage_irq":0,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":0.6770833333333334,"usage_user":0.625},"name":"cpu","tags":{"cpu":"cpu10","host":"BER-0803"},"timestamp":1727603970}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":98.95833333333333,"usage_iowait":0,"usage_irq":0,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":0.20833333333333334,"usage_user":0.8333333333333334},"name":"cpu","tags":{"cpu":"cpu11","host":"BER-0803"},"timestamp":1727603970}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":97.8125,"usage_iowait":0,"usage_irq":0,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":0.3125,"usage_user":1.875},"name":"cpu","tags":{"cpu":"cpu12","host":"BER-0803"},"timestamp":1727603970}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":99.73944762897342,"usage_iowait":0,"usage_irq":0,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":0.05211047420531527,"usage_user":0.20844189682126107},"name":"cpu","tags":{"cpu":"cpu13","host":"BER-0803"},"timestamp":1727603970}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":98.02083333333333,"usage_iowait":0,"usage_irq":0,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":0.6770833333333334,"usage_user":1.3020833333333333},"name":"cpu","tags":{"cpu":"cpu14","host":"BER-0803"},"timestamp":1727603970}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":98.95779051589369,"usage_iowait":0,"usage_irq":0,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":0.5732152162584679,"usage_user":0.46899426784783743},"name":"cpu","tags":{"cpu":"cpu15","host":"BER-0803"},"timestamp":1727603970}
{"fields":{"usage_guest":0,"usage_guest_nice":0,"usage_idle":97.6496630749699,"usage_iowait":0,"usage_irq":0,"usage_nice":0,"usage_softirq":0,"usage_steal":0,"usage_system":1.0026368045834826,"usage_user":1.347700120446629},"name":"cpu","tags":{"cpu":"cpu-total","host":"BER-0803"},"timestamp":1727603970}

```

So now we generated a conf from ps1 and we added a configuration from github also.

For the simplicity lest remove cpu and use only disk for the tutorial

## Configure plugins Collect data with input plugins TODO

https://docs.influxdata.com/telegraf/v1/configure_plugins/input_plugins/

## Input plugins 

View below tested

## Output plugins

View below tested


### Test telegraf.conf with a given config

```ps1

cd 'C:\Program Files\Telegraf\telegraf-1.32.0\'
.\telegraf --config-directory 'C:\Program Files\Telegraf\telegraf-1.32.0\conf\' --test

# only inputs can be tested
file,host=BER-0803 tag1_value=100 1727211303000000000


```
## Troubleshoot TODO

Best tip, add a good agent section after running --test (view above)

```toml
[agent]
 interval = "30s" 
 round_interval = true
 metric_batch_size = 1000 
 metric_buffer_limit = 10000 
 collection_jitter = "0s" 
 flush_interval = "30s"
 flush_jitter = "5s" precision = ""
 debug = true
 quiet = false # quiet: Log only error level messages.
 logfile = "C://Program Files//Telegraf//telegraf-1.32.0//telegraf.logs"
 logfile_rotation_max_size = "200KB"
 logfile_rotation_max_archives = 10

```


### Telegraf Best Practices: Config Recommendations and Performance Monitoring

https://www.influxdata.com/blog/telegraf-best-practices/


# Plugins input

## File Input Plugin = ok

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

## HTTP Input Plugin = ok

Json from url

```json
{
    "data": {
        "stations": [
            {
                "num_ebikes_available": 0,
                "num_docks_disabled": 0,
                "is_renting": 0,
                "last_reported": 1725888418,
                "num_docks_available": 3,
                "legacy_id": "3896",
                "station_id": "26cae473-0e59-4af7-bad5-bb6fec85c8bc",
                "is_installed": 0,
                "eightd_has_available_keys": false,
                "is_returning": 0,
                "num_bikes_available": 0,
                "num_bikes_disabled": 0
            },
            [...]
```

Telegraf log

```log
024-09-30T20:43:12Z I! [agent] Config: Interval:30s, Quiet:false, Hostname:"BER-0803", Flush Interval:30s
2024-09-30T20:43:12Z D! [agent] Initializing plugins
2024-09-30T20:43:12Z D! [agent] Connecting outputs
2024-09-30T20:43:12Z D! [agent] Attempting connection to [outputs.file]
2024-09-30T20:43:12Z D! [agent] Successfully connected to outputs.file
2024-09-30T20:43:12Z D! [agent] Starting service inputs
2024-09-30T20:43:31Z D! [outputs.file] Wrote batch of 1000 metrics in 14.9989ms
2024-09-30T20:43:31Z D! [outputs.file] Buffer fullness: 1226 / 10000 metrics

```

File out

```log
{"fields":{"eightd_has_available_keys":false,"is_installed":1,"is_renting":1,"is_returning":1,"legacy_id":"5036","num_bikes_available":19,"num_bikes_disabled":1,"num_docks_available":4,"num_docks_disabled":0,"num_ebikes_available":1,"num_scooters_available":0,"num_scooters_unavailable":0},"name":"citibike","tags":{"station_id":"0cb63737-64c9-42a9-9479-280d49ed015a"},"timestamp":1727728988}
{"fields":{"eightd_has_available_keys":false,"is_installed":1,"is_renting":1,"is_returning":1,"legacy_id":"3704","num_bikes_available":17,"num_bikes_disabled":0,"num_docks_available":2,"num_docks_disabled":0,"num_ebikes_available":13,"num_scooters_available":0,"num_scooters_unavailable":0},"name":"citibike","tags":{"station_id":"c72970e7-7f1a-4671-bf55-fc34be7c9413"},"timestamp":1727728984}
```

## CPU Input Plugin = ok

Use telegraf github input template

## Disk Input Plugin = ok

Use telegraf github input template

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


## RabbitMQ Output Plugin = ok

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

Influxdb v2 output plugin = ok

```log

2024-09-29T19:22:03Z I! Tags enabled: host=BER-0803
2024-09-29T19:22:03Z I! [agent] Config: Interval:30s, Quiet:false, Hostname:"BER-0803", Flush Interval:30s
2024-09-29T19:22:03Z D! [agent] Initializing plugins
2024-09-29T19:22:03Z D! [agent] Connecting outputs
2024-09-29T19:22:03Z D! [agent] Attempting connection to [outputs.influxdb_v2]
2024-09-29T19:22:03Z D! [agent] Successfully connected to outputs.influxdb_v2
2024-09-29T19:22:03Z D! [agent] Starting service inputs
2024-09-29T19:22:37Z D! [outputs.influxdb_v2] Wrote batch of 3 metrics in 88.0961ms
2024-09-29T19:22:37Z D! [outputs.influxdb_v2] Buffer fullness: 0 / 10000 metrics
2024-09-29T19:23:10Z D! [outputs.influxdb_v2] Wrote batch of 3 metrics in 51.4511ms
2024-09-29T19:23:10Z D! [outputs.influxdb_v2] Buffer fullness: 0 / 10000 metrics
2024-09-29T19:23:41Z D! [outputs.influxdb_v2] Wrote batch of 3 metrics in 48.6497ms
2024-09-29T19:23:41Z D! [outputs.influxdb_v2] Buffer fullness: 0 / 10000 metrics

```

## Zabbix Output Plugin = ok

If we assume a file input on format:

```json
{
        
        "rpm": 33,
		"speed": 200
}
```


Lets check the output in a file to file telegraf given above json and data_format = "json":

metrics.out.json

```log 
{"fields":{"rpm":33,"speed":200},"name":"file","tags":{"host":"BER-0803"},"timestamp":1728081750}
{"fields":{"rpm":33,"speed":200},"name":"file","tags":{"host":"BER-0803"},"timestamp":1728081765}
{"fields":{"rpm":33,"speed":200},"name":"file","tags":{"host":"BER-0803"},"timestamp":1728081780}

```

Lets start Telegraf and check what we are sending to zabbix.

```log
2024-10-04T22:44:38Z I! Loading config: C:\Program Files\Telegraf\telegraf-1.32.0\conf\telegraf.conf
2024-10-04T22:44:38Z I! Starting Telegraf 1.32.0 brought to you by InfluxData the makers of InfluxDB
2024-10-04T22:44:38Z I! Available plugins: 235 inputs, 9 aggregators, 32 processors, 26 parsers, 62 outputs, 5 secret-stores
2024-10-04T22:44:38Z I! Loaded inputs: file
2024-10-04T22:44:38Z I! Loaded aggregators:
2024-10-04T22:44:38Z I! Loaded processors:
2024-10-04T22:44:38Z I! Loaded secretstores:
2024-10-04T22:44:38Z I! Loaded outputs: file zabbix
2024-10-04T22:44:38Z I! Tags enabled: host=BER-0803
2024-10-04T22:44:38Z I! [agent] Config: Interval:15s, Quiet:false, Hostname:"BER-0803", Flush Interval:30s
2024-10-04T22:44:38Z D! [agent] Initializing plugins
2024-10-04T22:44:38Z D! [agent] Connecting outputs
2024-10-04T22:44:38Z D! [agent] Attempting connection to [outputs.zabbix]
2024-10-04T22:44:38Z D! [agent] Successfully connected to outputs.zabbix
2024-10-04T22:44:38Z D! [agent] Attempting connection to [outputs.file]
2024-10-04T22:44:38Z D! [agent] Successfully connected to outputs.file
2024-10-04T22:44:38Z D! [agent] Starting service inputs
2024-10-04T22:45:09Z D! [outputs.zabbix] Wrote batch of 2 metrics in 84.2378ms
2024-10-04T22:45:09Z D! [outputs.zabbix] Buffer fullness: 0 / 10000 metrics
2024-10-04T22:45:11Z D! [outputs.file] Wrote batch of 2 metrics in 0s
2024-10-04T22:45:11Z D! [outputs.file] Buffer fullness: 0 / 10000 metrics

```

It is sent, but not showing in zabbix


Lets test the telegraf config


```ps1
PS C:\Program Files\Telegraf\telegraf-1.32.0> .\telegraf --config-directory 'C:\Program Files\Telegraf\telegraf-1.32.0\conf\' --test

2024-10-04T22:45:52Z I! Loading config: C:\Program Files\Telegraf\telegraf-1.32.0\conf\telegraf.conf
> file,host=BER-0803 rpm=33,speed=200 1728081953000000000

```
So now we know the format

https://github.com/influxdata/telegraf/blob/master/plugins/outputs/zabbix/README.md

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
Ok, lets configure that in zabbix

* Host: BER-0803
* Items: telegraf.file.rpm and speed (since we added a key prefix (telegraf.))



```json
{
    "zabbix_export": {
        "version": "6.0",
        "date": "2024-10-06T18:15:04Z",
        "groups": [
            {
                "uuid": "137f19e6e2dc4219b33553b812627bc2",
                "name": "Virtual machines"
            }
        ],
        "hosts": [
            {
                "host": "BER-0803",
                "name": "BER-0803",
                "groups": [
                    {
                        "name": "Virtual machines"
                    }
                ],
                "interfaces": [
                    {
                        "port": "10051",
                        "interface_ref": "if1"
                    }
                ],
                "items": [
                    {
                        "name": "telegraf.file.rpm",
                        "type": "TRAP",
                        "key": "telegraf.file.rpm",
                        "delay": "0"
                    },
                    {
                        "name": "telegraf.file.speed",
                        "type": "TRAP",
                        "key": "telegraf.file.speed",
                        "delay": "0"
                    },
                    {
                        "name": "telegraf.file.tourq",
                        "type": "TRAP",
                        "key": "telegraf.file.tourq",
                        "delay": "0"
                    }
                ],
                "inventory_mode": "DISABLED"
            }
        ]
    }
}


```
![Telegraf to zabbix](https://github.com/spawnmarvel/linux-and-azure/blob/main/images/telegraf_zabbix.jpg)



## Processor plugins TODO

* Transform
* Decorate
* Filter

* A tag to all metrics

Processor plugins process metrics as they pass through and immediately emit results based on the values they process. For example, this could be printing all metrics or adding a tag to all metrics that pass through. For a list of processor plugins and links to their detailed configuration options, see

https://docs.influxdata.com/telegraf/v1/plugins/#processor-plugins

Example with disk input and file output


## Aggregator plugins TODO

* Transform
* Decorate
* Filter

* All aggrs have a ., . = size of window
* drop_original = emit only aggr

Aggregators are typically for emitting new aggregate metrics, such as a running mean, minimum, maximum, quantiles, or standard deviation. For this reason, all aggregator plugins are configured with a period. The period is the size of the window of metrics that each aggregate represents. 

Since many users will only care about their aggregates and not every single metric gathered, there is also a drop_original argument, which tells Telegraf to only emit the aggregates and not the original metrics.

For a list of aggregator plugins and links to their detailed configuration options, see

https://docs.influxdata.com/telegraf/v1/plugins/#aggregator-plugins

https://docs.influxdata.com/telegraf/v1/configure_plugins/aggregator_processor/

## External plugins TODO

https://docs.influxdata.com/telegraf/v1/get-started/

# Purdue Telegraf - Amqp - Telegraf - Zabbix

Ref purdue, level1->level3->level3 (not skip a level).

For AMQP, use a shovel if needed to bridge network.

Set up:

* Logfile
* Telegraf input Log file and disk, Telegraf output file and Amqp
* Telegraf input Amqp, Telegraf output file and Zabbix

Environment

* Windows: Logfile, Telegraf and Amqp.
* Linux: Zabbix

Main log section:

```toml
[agent]
 interval = "30s" 
 round_interval = true
 metric_batch_size = 1000 
 metric_buffer_limit = 10000 
 collection_jitter = "0s" 
 flush_interval = "30s"
 flush_jitter = "5s" precision = ""
 debug = true
 quiet = false # quiet: Log only error level messages.
 logfile = "C://Program Files//Telegraf//telegraf-1.32.0//telegraf.logs"
 logfile_rotation_max_size = "10MB"
 logfile_rotation_max_archives = 10
 
# Readme
# https://github.com/influxdata/telegraf/blob/master/docs/CONFIGURATION.md#agent
```



## Telegraf input: File and disk. Telegraf output Amqp

We added a logfile to telegraf, two inputs: file and disk and two outputs: file and Amqp.


```toml
###############################################################################
#                                  INPUTS                                     #
###############################################################################
[[inputs.file]]
  ## Files to parse each interval.  Accept standard unix glob matching rules,
  ## as well as ** to match recursive files and directories.
  files = ["C://Program Files//Telegraf//telegraf-1.32.0//file//metrics.in.json"]
  
  ## Data format to consume.
  ## Each data format has its own unique set of configuration options, read
  ## more about them here:
  ## https://github.com/influxdata/telegraf/blob/master/docs/DATA_FORMATS_INPUT.md
  ## data_format = "influx"
  data_format = "json"

# Read metrics about disk usage by mount point
[[inputs.disk]]
  ## By default stats will be gathered for all mount points.
  ## Set mount_points will restrict the stats to only the specified mount points.
  # mount_points = ["/"]
```

```toml
###############################################################################
#                                  OUTPUTS                                     #
###############################################################################

# https://github.com/influxdata/telegraf/blob/master/plugins/outputs/amqp/README.md

# Publishes metrics to an AMQP broker
[[outputs.amqp]]
  ## Brokers to publish to.  If multiple brokers are specified a random broker
  ## will be selected anytime a connection is established.  This can be
  ## helpful for load balancing when not using a dedicated load balancer.
  brokers = ["amqp://localhost:5672/"]

  ## Maximum messages to send over a connection.  Once this is reached, the
  ## connection is closed and a new connection is made.  This can be helpful for
  ## load balancing when not using a dedicated load balancer.
  # max_messages = 0

  ## Exchange to declare and publish to.
  exchange = "telegraf"

  ## Exchange type; common types are "direct", "fanout", "topic", "header", "x-consistent-hash".
  exchange_type = "topic"

  ## If true, exchange will be passively declared.
  # exchange_passive = false

  ## Exchange durability can be either "transient" or "durable".
  exchange_durability = "durable"
  
  ## Authentication credentials for the PLAIN auth_method.
  username = "admin2"
  password = "Linuxrules45Yea"
  
  ## Data format to output.
  ## Each data format has its own unique set of configuration options, read
  ## more about them here:
  ## https://github.com/influxdata/telegraf/blob/master/docs/DATA_FORMATS_INPUT.md
  ## data_format = "influx"
  data_format = "json"
  
# Send telegraf metrics to file(s)
[[outputs.file]]
  ## Files to write to, "stdout" is a specially handled file.
  files = ["C:/Program Files/Telegraf/telegraf-1.32.0//file//metrics.out.json"]
  
  ## Data format to output.
  ## Each data format has its own unique set of configuration options, read
  ## more about them here:
  ## https://github.com/influxdata/telegraf/blob/master/docs/DATA_FORMATS_INPUT.md
  ## data_format = "influx"
  data_format = "json"
```

Telegraf runs as a service.

* Telegraf input Log file and disk, Telegraf output file and Amqp


![telegraf service](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/telegraf/images/telegraf_service.jpg)


Format is json.

Example message:

```json
{"fields":{"tag1_active":1,"tag1_state":0,"tag1_value":100},"name":"file","tags":{"host":"BER-0803"},"timestamp":1757274720}
{"fields":{"free":195134099456,"inodes_free":0,"inodes_total":0,"inodes_used":0,"inodes_used_percent":0,"total":510770802688,"used":315636703232,"used_percent":61.79615231938072},"name":"disk","tags":{"device":"C:","fstype":"NTFS","host":"BER-0803","mode":"rw","path":"\\C:"},"timestamp":1757274720}
{"fields":{"free":421260537856,"inodes_free":0,"inodes_total":0,"inodes_used":0,"inodes_used_percent":0,"total":500105248768,"used":78844710912,"used_percent":15.765623557487645},"name":"disk","tags":{"device":"D:","fstype":"NTFS","host":"BER-0803","mode":"rw","path":"\\D:"},"timestamp":1757274720}
{"fields":{"free":989560467456,"inodes_free":0,"inodes_total":0,"inodes_used":0,"inodes_used_percent":0,"total":1099511627776,"used":109951160320,"used_percent":9.999999776482582},"name":"disk","tags":{"device":"Z:","fstype":"MFilesFS","host":"BER-0803","mode":"rw","path":"\\Z:"},"timestamp":1757274720}
```

![purdue_file_disk_amqp_file](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/telegraf/images/purdue_file_disk_amqp_file.jpg)


NOTE!! you can use: Secret-store secrets in Telegraf.
- Avoid putting sensitive credentials (like password = "Linuxrules45Yea") in plain text in telegraf.conf.- Pull secrets from systems like Vault, AWS Secrets Manager, GCP Secret Manager, Azure Key Vault, or even from environment variables.

Secrets in Telegraf configs can be referenced as:

```toml
password = 'secret://<secretstore>/<path>'
```

Telegraf will look in the OS environment store for TELEGRAF_RABBITMQ_PASSWORD when starting.

In PowerShell / Windows CMD

```ps1
set TELEGRAF_RABBITMQ_PASSWORD=Linuxrules45Yea
```

```toml
[[outputs.amqp]]
  brokers = ["amqp://localhost:5672/"]
  exchange = "telegraf"
  exchange_type = "topic"
  exchange_durability = "durable"
  username = "admin2"
  password = 'secret://environment/TELEGRAF_RABBITMQ_PASSWORD'
  data_format = "json"
```


## Telegraf input: Amqp. Telegraf output File and Zabbix

Next up is reading the data from Amqp using a a different Telegraf and insert it to Zabbix.

The Telegraf Amqp input service would be on a differt machine, and we would maybe use a Amqp shovel to move the data.

For this tutorial, it is about the concept, so we will we just change the Telegraf.conf in C:\Program Files\Telegraf\telegraf-1.32.0\conf

* Telegraf input Amqp, Telegraf output file and Zabbix






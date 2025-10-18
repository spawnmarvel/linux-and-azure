# F-E-K (Filebeat, Elasticsearch, Kibana)

Combination of Filebeat, Elasticsearch, and Kibana (a common variation of the Elastic Stack, formerly known as the ELK stack, with Logstash) is an excellent, popular, and robust solution for centralized log collection, storage, and analysis.

Kibana and Grafana are both powerful, open-source data visualization tools, but they were built for different primary purposes and excel in different areas. Kibana is the log analysis champion, tightly coupled with Elasticsearch, while Grafana is the metrics and multi-source visualization expert

This set of tools provides a complete pipeline for transforming raw log data into actionable insights in real-time

## Why This Combination Works So Well

| Component | Role in Log Pipeline | Core Function | Why It's Good |
| :--- | :--- | :--- | :--- |
| **Filebeat** 📦 | **Collection/Shipping (Agent)** | A lightweight agent installed on your servers to monitor log files and forward them to Elasticsearch or Logstash. | **Reliable & Lightweight:** Low resource consumption; ensures *at-least-once delivery* of logs and uses a backpressure mechanism to prevent overwhelming the pipeline. |
| **Elasticsearch** 💾 | **Storage & Indexing (Engine)** | A distributed, scalable search and analytics engine that stores the collected log data as searchable JSON documents. | **Fast & Scalable:** Handles massive volumes of data and provides near real-time search, complex queries, and powerful aggregations. |
| **Kibana** 📊 | **Analysis & Visualization (UI)** | A web interface that allows you to explore, search, and visualize the data stored in Elasticsearch. | **Intuitive Insights:** Enables creation of custom dashboards, charts, and graphs for monitoring, troubleshooting, and spotting trends or anomalies. |


## Elasticsearch

https://www.elastic.co/docs/deploy-manage/deploy/self-managed/install-elasticsearch-with-debian-package

### Elasticsearch install 22.04 (24.04)

dummy3 (elasticsearch, kibana)
zabbix agent vm active
ssh imsdal@192.168.3.6

1 Install and 2 configure

```bash
# To begin, use cURL, the command line tool for transferring data with URLs, to import the Elasticsearch public GPG key into APT
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elastic.gpg

# Next, add the Elastic source list to the sources.list.d directory, where apt will search for new sources:
echo "deb [signed-by=/usr/share/keyrings/elastic.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list

# Next, update your package lists so APT will read the new Elastic source:
sudo apt update -y

# install it 
sudo apt install elasticsearch


# Configure
sudo nano /etc/elasticsearch/elasticsearch.yml

# /etc/elasticsearch/elasticsearch.yml
# 
network.host: localhost

# start
sudo systemctl start elasticsearch
# wait 1-2 min

# enable
sudo systemctl enable elasticsearch

# verify
sudo systemctl status elasticsearch.service
● elasticsearch.service - Elasticsearch
     Loaded: loaded (/usr/lib/systemd/system/elasticsearch.service; enabled; preset: enabled)
     Active: active (running) since Mon 2025-10-06 21:23:18 UTC; 38s ago
       Docs: https://www.elastic.co
   Main PID: 5831 (java)
      Tasks: 72 (limit: 4602)
     Memory: 2.3G (peak: 2.3G)
        CPU: 53.964s


```
3 Securing Elasticsearch

```bash
# If you need to allow remote access to the HTTP API, you can limit the network exposure with Ubuntu’s default firewall, UFW.
```

4 Testing Elasticsearch

```bash
curl -X GET 'http://localhost:9200'
```

```json
{
  "name" : "dummy03",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "6Ll71GVASECa3eIsCX0Q-A",
  "version" : {
    "number" : "7.17.29",
    "build_flavor" : "default",
    "build_type" : "deb",
    "build_hash" : "580aff1a0064ce4c93293aaab6fcc55e22c10d1c",
    "build_date" : "2025-06-19T01:37:57.847711500Z",
    "build_snapshot" : false,
    "lucene_version" : "8.11.3",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
 
```

5 Using Elasticsearch TBD

https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-elasticsearch-on-ubuntu-22-04

## Elasticsearch Reference

https://www.elastic.co/docs/reference/elasticsearch/


## Kibana


### Kibana install 24.04


According to the official documentation, you should install Kibana only after installing Elasticsearch. Installing in this order ensures that the components each product depends on are correctly in place.


If you're deploying the Elastic Stack in a self-managed cluster, then install the Elastic Stack products you want to use in the following order:

* Elasticsearch
* Kibana
* (Logstash)
* Elastic Agent or Beats

https://www.elastic.co/docs/deploy-manage/deploy/self-managed/installing-elasticsearch

Because you’ve already added the Elastic package source in the previous step, you can just install the remaining components of the Elastic Stack using apt:

```bash
sudo apt install kibana

sudo systemctl enable kibana

sudo systemctl start kibana

sudo systemctl status kibana
● kibana.service - Kibana
     Loaded: loaded (/etc/systemd/system/kibana.service; enabled; preset: enabled)
     Active: active (running) since Mon 2025-10-06 21:26:39 UTC; 6s ago
       Docs: https://www.elastic.co
   Main PID: 6557 (node)
      Tasks: 11 (limit: 4602)
     Memory: 112.6M (peak: 112.8M)
        CPU: 4.340s


# Check Configuration: Ensure you set server.host correctly in /etc/kibana/kibana.yml.
sudo nano /etc/kibana/kibana.yml

#server.host: "localhost"
server.host: "0.0.0.0"

sudo systemctl restart kibana

sudo systemctl status kibana
● kibana.service - Kibana
     Loaded: loaded (/etc/systemd/system/kibana.service; enabled; preset: enabled)
     Active: active (running) since Mon 2025-10-06 21:31:22 UTC; 2min 29s ago

     
```

Visit

http://192.168.3.6:5601/

```log
Kibana server is not ready yet
```

```bash

sudo ufw status
Status: inactive

# check
sudo systemctl status elasticsearch

# verify
curl -X GET 'http://localhost:9200'

# The URLs of the Elasticsearch instances to use for all your queries.
elasticsearch.hosts: ["http://localhost:9200"]
```

If Kibana is failing to connect due to security, you need to use the token method or in this case elasticsearch-setup-passwords

```bash

sudo systemctl status elasticsearch
● elasticsearch.service - Elasticsearch
     Loaded: loaded (/usr/lib/systemd/system/elasticsearch.service; enabled; preset: enabled)
     Active: active (running) since Mon 2025-10-06 21:41:23 UTC; 29s ago


sudo /usr/share/elasticsearch/bin/elasticsearch-setup-passwords interactive

# Unexpected response code [500] from calling GET http://127.0.0.1:9200/_security/_authenticate?pretty
# It doesn't look like the X-Pack security feature is enabled on this Elasticsearch node.
# Please check if you have enabled X-Pack security in your elasticsearch.yml configuration file.

# ERROR: X-Pack Security is disabled by configuration.

# enable it
sudo nano /etc/elasticsearch/elasticsearch.yml

# Add or uncomment these lines to enable security
xpack.security.enabled: true
xpack.security.transport.ssl.enabled: true

# restart
sudo systemctl restart elasticsearch

sudo systemctl status elasticsearch

sudo /usr/share/elasticsearch/bin/elasticsearch-setup-passwords interactive

# Changed password for user [apm_system]
# Changed password for user [kibana_system]
# Changed password for user [kibana]
# Changed password for user [logstash_system]
# Changed password for user [beats_system]
# Changed password for user [remote_monitoring_user]
# Changed password for user [elastic]

sudo nano /etc/kibana/kibana.yml

elasticsearch.username: "kibana_system"
elasticsearch.password: "Kibana.user17"

# restart
sudo systemctl restart kibana

```
Verification
After Kibana restarts (wait about 30 seconds), access the web interface at:

http://<Your_Server_IP>:5601

You should now see the Kibana login page. Log in using the elastic username and the password you generated for the elastic user. Your full Elastic Stack should now be running and connected!

```bash
# Changed password for user [elastic]
Kibana.user17
```
![login](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/kibana-elasticsearch-file-beat/images/login_kibana.png)

Success

![success](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/kibana-elasticsearch-file-beat/images/kibana_success.png)

https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elastic-stack-on-ubuntu-22-04


https://www.elastic.co/docs/deploy-manage/deploy/self-managed/install-kibana-with-debian-package

### Kibana what is Included for Free (Basic Tier)

The free Basic license tier allows you to use the core components with essential functionality, which now includes critical features that used to be paid:

* Component	Free Features Included
* Elasticsearch	Search, Indexing, REST APIs, and most core functionality.
* Kibana	All core visualization tools (Discover, Visualize, Lens, Maps, Dev Tools) and dashboards.
* Security (X-Pack)	Basic authentication (like the username/password you just set up), TLS/SSL encryption, and role-based access control (RBAC).
* Monitoring	Basic stack monitoring to ensure Elasticsearch and Kibana are healthy.

## Filebeat

Filebeat is a lightweight shipper for forwarding and centralizing log data. Installed as an agent on your servers, Filebeat monitors the log files or locations that you specify, collects log events, and forwards them either to Elasticsearch or Logstash for indexing.

https://www.elastic.co/docs/reference/beats/filebeat


### Step 1: Install Filebeat
Lets install for windows on dmzwindows07

This guide describes how to get started quickly with log collection. You’ll learn how to:

* install Filebeat on each system you want to monitor
* specify the location of your log files
* parse log data into fields and send it to Elasticsearch
* visualize the log data in Kibana


Download the Filebeat Windows zip file.

Extract the contents of the zip file into C:\Program Files.

Rename the filebeat-[version]-windows-x86_64 directory to Filebeat.

Open a PowerShell prompt as an Administrator (right-click the PowerShell icon and select Run As Administrator).

From the PowerShell prompt, run the following commands to install Filebeat as a Windows service:


```ps1
PS C:\Program Files\filebeat> Set-ExecutionPolicy Unrestricted
PS C:\Program Files\filebeat> .\install-service-filebeat.ps1

```
### Step 2: Connect to the Elastic Stack

Edit the filebeat.yaml to connect to elstaicsearch

```yml
output.elasticsearch:
  # Array of hosts to connect to.
  hosts: ["192.168.3.6:9200"]

  # Performance preset - one of "balanced", "throughput", "scale",
  # "latency", or "custom".
  preset: balanced

  # Protocol - either `http` (default) or `https`.
  #protocol: "https"

  # Authentication credentials - either API key or username/password.
  #api_key: "id:api_key"
  username: "elastic"
  password: "Kibana.user17"
```


Test the config

```cmd
PS C:\Program Files\filebeat> .\filebeat.exe test config -e -c "C:\Program Files\filebeat\filebeat.yml"

Config OK

```

Start filebeat service

```ps1
# check modules to monitor
PS C:\Program Files\filebeat> .\filebeat.exe modules list


```
### Step 3: Collect log data

***Powershell log script***

Create a ps1 script that just logs each min

```ps1
# Define the log file path
$LogFilePath = "C:\Logs\ps1.log"

# Log an informational message
"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [INFO] - Script started." | Out-File -FilePath $LogFilePath -Append

# Perform some operations
Write-Host "Performing task 1..."
# ... (your script logic) ...

# Log a success message
"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [SUCCESS] - Task 1 completed." | Out-File -FilePath $LogFilePath -Append


```
Use filestream input

Stop filebeat service

Take a backup of filebeat.yaml and edit the orginal file

```yml
filebeat.inputs:

# Each - is an input. Most options can be set at the input level, so
# you can use different inputs for various configurations.
# Below are the input-specific configurations.

# filestream is an input for collecting log messages from files.
- type: filestream

  # Unique ID among all inputs, an ID is required.
  id: my-filestream-id

  # Change to true to enable this input configuration.
  enabled: true

  # Paths that should be crawled and fetched. Glob based paths.
  paths:
      - C:\Logs\ps1.log
    # - /var/log/*.log
    #- c:\programdata\elasticsearch\logs\*
```

Test the config on windows

```cmd
PS C:\Program Files\filebeat> .\filebeat.exe test config -e -c "C:\Program Files\filebeat\filebeat.yml"

{"log.level":"info","@timestamp":"2025-10-15T09:08:35.750+0200","log.logger":"modules","log.origin":{"function":"github.com/elastic/beats/v7/filebeat/fileset.newModuleRegistry","file.name":"fileset/modules.go","file.line":135},"message":"Enabled modules/filesets: ","service.name":"filebeat","ecs.version":"1.6.0"}
Config OK

```
### Step 4: Set up assets


```cmd
PS C:\Program Files\filebeat> .\filebeat.exe setup -e

No connection could be made because the target machine actively refused it.]","service.name":"filebeat","ecs.version":"1.6.0"}
Exiting: couldn't connect to any of the configured Elasticsearch hosts. Errors: [error connecting to Elasticsearch at http://192.168.3.6:9200: Get "http://192.168.3.6:9200": dial tcp 192.168.3.6:9200: connectex: No connection could be made because the target machine actively refused it.]

```

Edit the elasticsearch.yml

```bash

sudo nano /etc/elasticsearch/elasticsearch.yml

```

```yml
# By default Elasticsearch is only accessible on localhost. Set a different
# address here to expose this node on the network:
#
#network.host: 192.168.0.1
network.host: 0.0.0.0

#cluster.initial_master_nodes: ["node-1", "node-2"]
cluster.initial_master_nodes: node-1
```

Stop and start elastic search and view status 
```log
sudo systemctl status elasticsearch
● elasticsearch.service - Elasticsearch
     Loaded: loaded (/usr/lib/systemd/system/elasticsearch.service; enabled; preset: enabled)
     Active: active (running) since Wed 2025-10-15 07:53:01 UTC; 56s ago
```

```cmd
PS C:\Program Files\filebeat> .\filebeat.exe setup -e
Exiting: error connecting to Kibana: fail to get the Kibana version: HTTP GET request to http://localhost:5601/api/status fails: fail to execute the HTTP GET request: Get "http://localhost:5601/api/status": dial tcp 127.0.0.1:5601: connectex: No connection could be made because the target machine actively refused it. (status=0). Response:
```

Changed kibana in filebeat

```bash
sudo nano /etc/kibana/kibana.yml

```

```yml
# =================================== Kibana ===================================

# Starting with Beats version 6.0.0, the dashboards are loaded via the Kibana API.
# This requires a Kibana endpoint configuration.
setup.kibana:

  # Kibana Host
  # Scheme and port can be left out and will be set to the default (http and 5601)
  # In case you specify and additional path, the scheme is required: http://localhost:5601/path
  # IPv6 addresses should always be defined as: https://[2001:db8::1]:5601
  host: "192.168.3.6:5601"
```

```bash
sudo service kibana stop
sudo service kibana start
sudo service kibana status
```

Test again

```ps1

PS C:\Program Files\filebeat> .\filebeat.exe setup -e

```

Log

```log
Index setup finished.
Loading dashboards (Kibana must be running and reachable)
{"log.level":"info","@timestamp":"2025-10-15T09:59:27.714+0200","log.logger":"kibana","log.origin":{"function":"github.com/elastic/elastic-agent-libs/kibana.NewClientWithConfigDefault","file.name":"kibana/client.go","file.line":181},"message":"Kibana url: http://192.168.3.6:5601","service.name":"filebeat","ecs.version":"1.6.0"}
{"log.level":"info","@timestamp":"2025-10-15T09:59:28.265+0200","log.logger":"kibana","log.origin":{"function":"github.com/elastic/elastic-agent-libs/kibana.NewClientWithConfigDefault","file.name":"kibana/client.go","file.line":181},"message":"Kibana url: http://192.168.3.6:5601","service.name":"filebeat","ecs.version":"1.6.0"}
```

### Step 5: Start Filebeat

Start the service, if we need more logs from the app we must run the ps1 script again.


### Step 6: View your data in Kibana


* Point your browser to http://localhost:5601, replacing localhost with the name of the Kibana host.

* In the side navigation, click Discover. To see Filebeat data, make sure the predefined filebeat-* data view is selected.

* In the side navigation, click Dashboard, then select the dashboard that you want to open.


![Setup ok](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/kibana-elasticsearch-file-beat/images/setup_ok.png)


From the Kibana main menu, navigate to Observability > Logs.

![Stream logs](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/kibana-elasticsearch-file-beat/images/stream_logs.png)


https://www.elastic.co/docs/reference/beats/filebeat/filebeat-installation-configuration

### Add more logging and learn the navigation and search

Use filestream input again add a second stream, Each - is an input.

Stop filebeat service

Take a backup of filebeat.yaml and edit the orginal file, change the id

```yml
# ============================== Filebeat inputs ===============================

filebeat.inputs:

# Each - is an input. Most options can be set at the input level, so
# you can use different inputs for various configurations.
# Below are the input-specific configurations.

# filestream is an input for collecting log messages from files.
- type: filestream

  # Unique ID among all inputs, an ID is required.
  id: my-filestream-ps1-1

  # Change to true to enable this input configuration.
  enabled: true

  # Paths that should be crawled and fetched. Glob based paths.
  paths:
      - C:\Logs\ps1.log
    # - /var/log/*.log
    #- c:\programdata\elasticsearch\logs\*
  encoding: utf-16le
  fields: 
    my-app-id: "app-1"
    
# filestream is an input for collecting log messages from files.
- type: filestream

  # Unique ID among all inputs, an ID is required.
  id: my-filestream-ps1-2

  # Change to true to enable this input configuration.
  enabled: true

  # Paths that should be crawled and fetched. Glob based paths.
  paths:
      - C:\Logs\ps2.log
    # - /var/log/*.log
    #- c:\programdata\elasticsearch\logs\*
  encoding: utf-16le
  fields: 
    my-app-id: "app-2"
```

Test the config on windows use space 2 or 4 spaces.

```cmd
PS C:\Program Files\filebeat> .\filebeat.exe test config -e -c "C:\Program Files\filebeat\filebeat.yml"

{"log.level":"info","@timestamp":"2025-10-15T15:12:29.784+0200","log.logger":"modules","log.origin":{"function":"github.com/elastic/beats/v7/filebeat/fileset.newModuleRegistry","file.name":"fileset/modules.go","file.line":135},"message":"Enabled modules/filesets: ","service.name":"filebeat","ecs.version":"1.6.0"}
Config OK

```

Start the filebeat services


Copy the script and alter the log statment so we can know the difference between them and send some more data.

```ps1
PS C:\Users\imsdal\Desktop> & '.\ps1_logger.ps1'
Task 1
Performing task 1...
PS C:\Users\imsdal\Desktop> & '.\ps1_logger2.ps1'
Task 2
Performing task 2...

```
Verify that we now have both logs

![Two ps1 scripts](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/kibana-elasticsearch-file-beat/images/ps_2_scripts.png)

### Data Ingestion with Filebeat: Ingesting JSON data from APIs with Filebeat

https://www.youtube.com/watch?v=zjw6bCxG_j4

## Data streams type filestream

A data stream acts as a layer of abstraction over a set of indices that are optimized for storing append-only time series data. 

Data streams are well-suited for logs, events, metrics, and other continuously generated data.

https://www.elastic.co/docs/manage-data/data-store/data-streams

We now have both logs in the stream

![Two logs](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/kibana-elasticsearch-file-beat/images/two_logs.png)


Lets filter on this new field and view visual

Add field in discover

![Add field](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/kibana-elasticsearch-file-beat/images/add_field.png)

We can now select and view visuals

![visual 1](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/kibana-elasticsearch-file-beat/images/visual1.png)

Lets edit the filter and select only app-1

![app 1](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/kibana-elasticsearch-file-beat/images/app1.png)

Then we have the statistics for app1

![app 1 stats](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/kibana-elasticsearch-file-beat/images/app1_stats.png)

Lets go and view the log content and search for some content

message : task

![search 1](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/kibana-elasticsearch-file-beat/images/search1.png)


If you want to search by hostname.

"agent.hostname":"dmzwindows07"


![mark field](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/kibana-elasticsearch-file-beat/images/mark.png)


https://discuss.elastic.co/t/how-to-filter-filebeat-output-by-input-id/329603/3



Lets add a third log file, zabbix

Stop filebeat service

```yml
filebeat.inputs:

# Each - is an input. Most options can be set at the input level, so
# you can use different inputs for various configurations.
# Below are the input-specific configurations.

# filestream is an input for collecting log messages from files.
- type: filestream

  # Unique ID among all inputs, an ID is required.
  id: my-filestream-ps1-1

  # Change to true to enable this input configuration.
  enabled: true

  # Paths that should be crawled and fetched. Glob based paths.
  paths:
      - C:\ps1Logs\ps1.log
    # - /var/log/*.log
    #- c:\programdata\elasticsearch\logs\*
  encoding: utf-16le
  fields: 
    my-app-id: "app-1"
    
# filestream is an input for collecting log messages from files.
- type: filestream

  # Unique ID among all inputs, an ID is required.
  id: my-filestream-ps1-2

  # Change to true to enable this input configuration.
  enabled: true

  # Paths that should be crawled and fetched. Glob based paths.
  paths:
      - C:\ps1Logs\ps2.log
    # - /var/log/*.log
    #- c:\programdata\elasticsearch\logs\*
  encoding: utf-16le
  fields: 
    my-app-id: "app-2"
    
# filestream is an input for collecting log messages from files.
- type: filestream

  # Unique ID among all inputs, an ID is required.
  id: my-filestream-zabbix

  # Change to true to enable this input configuration.
  enabled: true

  # Paths that should be crawled and fetched. Glob based paths.
  paths:
      - "C:\\Program Files\\Zabbix Agent 2\\zabbix_agent2.log"
    # - /var/log/*.log
    #- c:\programdata\elasticsearch\logs\*
  # encoding: utf-16le
  fields: 
    my-app-id: "app-zabbix"
```

Config check

```ps1
PS C:\Program Files\filebeat> .\filebeat.exe test config -e -c "C:\Program Files\filebeat\filebeat.yml"

{"log.level":"info","@timestamp":"2025-10-15T22:08:52.030+0200","log.logger":"modules","log.origin":{"function":"github.com/elastic/beats/v7/filebeat/fileset.newModuleRegistry","file.name":"fileset/modules.go","file.line":135},"message":"Enabled modules/filesets: ","service.name":"filebeat","ecs.version":"1.6.0"}
Config OK

```
Add the same user to security on the zabbix agent services as running the filebeat service to allow read file.

* Filebeat service users, local system
* Zabbix agent 2 user, local system, on security tab, add SYSTEM user if you do not get harvest message from filebeat.

![system user](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/kibana-elasticsearch-file-beat/images/system_user.png)

Runng in task schduler

![task scheduler](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/kibana-elasticsearch-file-beat/images/task_scheduler.png)

Go to discover end refresh.

![3 discover](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/kibana-elasticsearch-file-beat/images/3_discover.png)

Now go to stream and logs:


![3 loggers](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/kibana-elasticsearch-file-beat/images/3_loggers.png)

Filter for CPU

![Filter cpu](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/kibana-elasticsearch-file-beat/images/filter_cpu.png)



https://www.elastic.co/docs/manage-data/data-store/data-streams

## Other beats

Beats are open source data shippers that you install as agents on your servers to send operational data to Elasticsearch

https://www.elastic.co/docs/reference/beats

## Elastic fundamentals

Use case

* Full-text search: Build a fast, relevant full-text search solution using inverted indexes, tokenization, and text analysis.

Observability

* Logs, metrics, and traces: Collect, store, and analyze logs, metrics, and traces from applications, systems, and services.

![components](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/kibana-elasticsearch-file-beat/images/components.png)

Ingest

* Elastic Agent is a single, unified way to add monitoring for logs, metrics, and other types of data to a host. It can also protect hosts from security threats, query data from operating systems, forward data from remote services or hardware, and more.
* Fleet enables you to centrally manage Elastic Agents and their policies. 

APM

* Elastic APM is an application performance monitoring system built on the Elastic Stack. It allows you to monitor software services and applications in real-time,

Beats

* Beats are data shippers that you install as agents on your servers to send operational data to Elasticsearch. Beats are available for many standard observability data scenarios,

Elasticsearch ingest pipelines

* Ingest pipelines let you perform common transformations on your data before indexing them into Elasticsearch. You can configure one or more "processor" tasks .

Logstash

* 

Store

* Elasticsearch is the distributed search and analytics engine at the heart of the Elastic Stack.

Consume

* Use Kibana to query and visualize the data that’s stored in Elasticsearch. Or, use the Elasticsearch clients to access data in Elasticsearch directly from common programming languages.

Version compatibility

* When installing the Elastic Stack, you must use the same version across the entire stack.

Installation order

* Elastic search with the update apt.sources
* Kibana

Then we can deploy beats agents on remote hosts.


https://www.elastic.co/docs/get-started

## Elasticsearch manage data

https://www.elastic.co/docs/manage-data/

## Elasticsearch data store

The documentation in this section details how Elasticsearch works as a data store starting with the fundamental unit of storage in Elasticsearch: the index.

### Index basics

An index is a fundamental unit of storage in Elasticsearch. It is a collection of documents uniquely identified by a name or an alias

Index components
An index is made up of the following components.

* Elasticsearch serializes and stores data in the form of JSON documents
* An indexed document contains data and metadata.
* Each index has a mapping or schema for how the fields in your documents are indexed. A mapping defines the data type for each field, how the field should be indexed, and how it should be stored.

Index management

* Elastic's Index Management
* Convenient way to manage your cluster’s indices, data streams, templates, and enrich policies. 

Search for Index

Example our stream, where we can view health and storage.

![index_yellow](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/kibana-elasticsearch-file-beat/images/index_yellow.png)

Health Status Colors: Green, Yellow, and Red

* Green Status: All primary and replica shards are allocated. This indicates that the cluster is ready for use.
* Yellow Status: All primary shards are allocated, but few replica shards are not. This indicates that the cluster is partially functional.
* Red Status: One or more primary shards are not allocated. This indicates that the cluster may experience significant issues.

Get status using curl

```bash
curl -X GET "http://localhost:9200/_cluster/health?pretty"

curl -u elastic:password -X GET "http://localhost:9200/_cluster/health?pretty"

```

Json returnd.

```json
{
  "cluster_name" : "elasticsearch",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 14,
  "active_shards" : 14,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 1,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 93.33333333333333
}
```

if you run a cluster with number_of_data_nodes: 1, the cluster health will almost always be Yellow by default.

You can do this by setting the number of replicas to zero ("index.number_of_replicas": 0) for all indices.

***Single Server Single Node vs Single Server Multiple Node***

* If you only have one physical machine, a replica is kind of a waste of resources so "no replica" is an advantage IMO, and "no fail tolerance" applies to both options.

https://discuss.elastic.co/t/single-server-single-node-vs-single-server-multiple-node/324081/2


The most reliable, dynamic, and version-agnostic way to set index.number_of_replicas: 0 for all new indices is by creating a global index template. This template is stored in the cluster state and applies automatically.

```bash

# Set number_of_replicas to 0 for all existing indices
curl -X PUT "http://localhost:9200/_settings" -H 'Content-Type: application/json' -d '{"index.number_of_replicas": 0}'

curl -u elastic:passsword -X PUT "http://localhost:9200/_settings" -H 'Content-Type: application/json' -d '{"index.number_of_replicas": 0}'

{"acknowledged":true}

```

To change the number of replicas for an existing index (or all existing indices), you must use the Index Update Settings API

```bash
# Create a template to set number_of_replicas to 0 for all future indices
curl -X PUT "http://localhost:9200/_index_template/global_no_replicas" -H 'Content-Type: application/json' -d '{"index_patterns": ["*"], "priority": 10, "template": {"settings": {"number_of_replicas": 0}}}'

curl -u elastic:passsword -X PUT "http://localhost:9200/_index_template/global_no_replicas" -H 'Content-Type: application/json' -d '{"index_patterns": ["*"], "priority": 10, "template": {"settings": {"number_of_replicas": 0}}}'

{"acknowledged":true}

```

Now get the node status again.

```bash
curl -X GET "http://localhost:9200/_cluster/health?pretty"

curl -u elastic:password -X GET "http://localhost:9200/_cluster/health?pretty"

```

Json returnd.

```json
{
  "cluster_name" : "elasticsearch",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 14,
  "active_shards" : 14,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}
```


![index_green](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/kibana-elasticsearch-file-beat/images/index_green.png)


Available index operations:

* Show overview, settings, mapping, stats
* Close, open, force merge
* Refresh, clear cache, flush, delete
* Add life cycle policy

![hot](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/kibana-elasticsearch-file-beat/images/hot.png)

https://www.elastic.co/docs/manage-data/data-store/perform-index-operations

### Index lifecycle management

An index lifecycle management (ILM) policy defines how your indices are managed over time, automating when and how they transition as they age. 

In the Hot phase, by default an ILM-managed index rolls over when either:

* It reaches 30 days of age.
* One or more primary shards reach 50 GB in size.

https://www.elastic.co/docs/manage-data/lifecycle/index-lifecycle-management

On debian or ubuntu

```bash
sudo su

/var/lib/elasticsearch/nodes/0/indices
```

***Method 1: Relocating the Entire Node's Data Path (Least Downtime)***

Prerequisites
* The new drive must be mounted and formatted.


We added a disk from the portal, 8GB

![disk](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/kibana-elasticsearch-file-beat/images/disk.png)

Now mount and format.

![disk ok](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/kibana-elasticsearch-file-beat/images/disk_ok.png)


https://learn.microsoft.com/en-us/azure/virtual-machines/linux/attach-disk-portal

Check and fix access

```bash
imsdal@dummy03:/datadrive$ ls -ld
drwxr-xr-x 2 root root 6 Oct 18 09:39 .

```

The permissions are set to drwxr-xr-x. This means:

* d: It is a directory.
* rwx (Owner): The root user (the owner) has read, write, and execute permissions.
* r-x (Group): The root group has read and execute permissions.
* r-x (Others): All other users have read and execute permissions

Allow other users to read/ write:

```bash
# list all users
cat /etc/passwd

# [...]
imsdal:x:1000:1000:Ubuntu:/home/imsdal:/bin/bash
zabbix:x:110:114::/var/lib/zabbix/:/usr/sbin/nologin
elasticsearch:x:111:115::/nonexistent:/bin/false
kibana:x:112:116::/nonexistent:/bin/false

```

Add elasticsearch as owner

```bash
sudo chown elasticsearch:elasticsearch /datadrive/
ls -ld /datadrive/
drwxr-xr-x 2 elasticsearch elasticsearch 6 Oct 18 09:39 /datadrive/

# The standard and most secure permission for this type of application directory is often $\mathbf{775}$ (rwxrwxr-x), which grants full read/write access to both the Owner and the Group.
sudo chmod 775 /datadrive

```

* The Elasticsearch user must have full read/write permissions to the new directory.
* Crucial: Take a Snapshot of your cluster first as a backup.

```bash
# Example for Systemd
sudo systemctl stop elasticsearch
```
Copy Data to the New Location: Use a reliable copy command

```bash
# Replace /old/data/path with your current path.data
# Replace /new/data/path with the mount point of your new drive
sudo rsync -aHv --progress /old/data/path/ /new/data/path/
sudo rsync -aHv --progress /var/lib/elasticsearch /datadrive
```

Update path.data in elasticsearch.yml

```bash
# /etc/elasticsearch/elasticsearch.yml (or similar)

# path.data: /var/lib/elasticsearch
path.data: /datadrive/elasticsearch
```

Start the Elasticsearch service.

```bash
sudo service elasticsearch start
sudo service elasticsearch status
● elasticsearch.service - Elasticsearch
     Loaded: loaded (/usr/lib/systemd/system/elasticsearch.service; enabled; preset: enabled)
     Active: active (running) since Sat 2025-10-18 10:20:06 UTC; 15s ago

```

Verify path

```bash
curl -X GET "localhost:9200/_nodes/_local?filter_path=nodes.*.settings.path&pretty"

curl -u elastic:password -X GET "localhost:9200/_nodes/_local?filter_path=nodes.*.settings.path&p
retty"

```

Log
```json
{
  "nodes" : {
    "yMIzPqnNRMKAcZSRwmSQxA" : {
      "settings" : {
        "path" : {
          "data" : "/datadrive/elasticsearch",
          "logs" : "/var/log/elasticsearch",
          "home" : "/usr/share/elasticsearch"
        }
      }
    }
  }
}
```

https://www.elastic.co/docs/manage-data/data-store


## KQL

https://www.elastic.co/docs/explore-analyze/query-filter/languages/kql

## Docker elasticsearch and kibana, filebeat on vm's

### Kibana set up https

https://www.elastic.co/docs/deploy-manage/security/set-up-basic-security-plus-https#encrypt-kibana-https

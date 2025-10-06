# F-E-G (Filebeat, Elasticsearch, Grafana)

This is a highly popular and robust stack for log monitoring, often referred to as F-E-G (Filebeat, Elasticsearch, Grafana). It's a modern and lighter-weight alternative to the traditional ELK stack (Elasticsearch, Logstash, Kibana) when you replace Logstash and Kibana with direct Filebeat-to-Elasticsearch and Grafana.


## The F-E-G Log Stack Breakdown
| Component | Role | Key Function |
|---|---|---|
| Filebeat | Log Shipper | A lightweight agent installed on your servers to monitor log files, collect the log data, and forward it to a destination. It is optimized for handling log files, managing state, and backpressure. |
| Elasticsearch | Log/Data Store | The central database that stores the log events as searchable documents. Filebeat often ships data in a structured format (JSON), making it easy for Elasticsearch to index and query. |
| Grafana | Visualization | The front-end tool used to query the data in Elasticsearch and present it on dashboards, allowing for log analysis, filtering, and visualization of log metrics (e.g., error rate, request volume). |

## Elasticsearch

https://www.elastic.co/docs/deploy-manage/deploy/self-managed/install-elasticsearch-with-debian-package

### How To Install and Configure Elasticsearch on Ubuntu 22.04 (24.04)

dummy1 (grafana management and elastic search)
http://192.168.3.4:3000/

1 Install and 2 configure

```bash
# To begin, use cURL, the command line tool for transferring data with URLs, to import the Elasticsearch public GPG key into APT
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elastic.gpg

# Next, add the Elastic source list to the sources.list.d directory, where apt will search for new sources:
echo "deb [signed-by=/usr/share/keyrings/elastic.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list

# Next, update your package lists so APT will read the new Elastic source:
sudo apt update -y

# sudo apt install elasticsearch


# Configure
sudo nano /etc/elasticsearch/elasticsearch.yml

# /etc/elasticsearch/elasticsearch.yml
# 
network.host: localhost

# start
sudo systemctl start elasticsearch

# enable
sudo systemctl enable elasticsearch

# verify
sudo systemctl status elasticsearch
● elasticsearch.service - Elasticsearch
     Loaded: loaded (/usr/lib/systemd/system/elasticsearch.service; disabled; preset: enabled)
     Active: active (running) since Mon 2025-10-06 18:52:44 UTC; 27s ago
       Docs: https://www.elastic.co
   Main PID: 4109 (java)
      Tasks: 68 (limit: 4616)
     Memory: 2.3G (peak: 2.3G)
        CPU: 56.085s

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
  "name" : "dummy01",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "7QTPLV3MR7WtlafB5dO6nQ",
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

## Filebeat

https://www.elastic.co/docs/reference/beats/filebeat


## Grafana Zabbix

Url

* https://192.168.3.5/zabbix/api_jsonrpc.php

https://grafana.com/grafana/plugins/alexanderzobnin-zabbix-app/


dummy1 (grafana management)
http://192.168.3.4:3000/


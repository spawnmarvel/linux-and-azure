# F-E-K (Filebeat, Elasticsearch, Kibana)

Combination of Filebeat, Elasticsearch, and Kibana (a common variation of the Elastic Stack, formerly known as the ELK stack, with Logstash) is an excellent, popular, and robust solution for centralized log collection, storage, and analysis.

This set of tools provides a complete pipeline for transforming raw log data into actionable insights in real-time

## Why This Combination Works So Well

| Component | Role in Log Pipeline | Core Function | Why It's Good |
| :--- | :--- | :--- | :--- |
| **Filebeat** 📦 | **Collection/Shipping (Agent)** | A lightweight agent installed on your servers to monitor log files and forward them to Elasticsearch or Logstash. | **Reliable & Lightweight:** Low resource consumption; ensures *at-least-once delivery* of logs and uses a backpressure mechanism to prevent overwhelming the pipeline. |
| **Elasticsearch** 💾 | **Storage & Indexing (Engine)** | A distributed, scalable search and analytics engine that stores the collected log data as searchable JSON documents. | **Fast & Scalable:** Handles massive volumes of data and provides near real-time search, complex queries, and powerful aggregations. |
| **Kibana** 📊 | **Analysis & Visualization (UI)** | A web interface that allows you to explore, search, and visualize the data stored in Elasticsearch. | **Intuitive Insights:** Enables creation of custom dashboards, charts, and graphs for monitoring, troubleshooting, and spotting trends or anomalies. |


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


## Grafana Elasticsearch

dummy1 (grafana management)
http://192.168.3.4:3000/

![elasticsearch plugin](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/grafana-elasticsearch-file-beat/images/elasti_plug.png)


https://grafana.com/grafana/plugins/elasticsearch/

### Configure the Elasticsearch data source

https://grafana.com/docs/grafana/latest/datasources/elasticsearch/configure-elasticsearch-data-source/#configure-the-elasticsearch-data-source


## Filebeat

https://www.elastic.co/docs/reference/beats/filebeat
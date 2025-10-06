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

What is Included for Free (Basic Tier)

The free Basic license tier allows you to use the core components with essential functionality, which now includes critical features that used to be paid:

* Component	Free Features Included
* Elasticsearch	Search, Indexing, REST APIs, and most core functionality.
* Kibana	All core visualization tools (Discover, Visualize, Lens, Maps, Dev Tools) and dashboards.
* Security (X-Pack)	Basic authentication (like the username/password you just set up), TLS/SSL encryption, and role-based access control (RBAC).
* Monitoring	Basic stack monitoring to ensure Elasticsearch and Kibana are healthy.

## Filebeat

https://www.elastic.co/docs/reference/beats/filebeat
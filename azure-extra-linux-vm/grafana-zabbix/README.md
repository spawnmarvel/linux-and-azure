# F-E-G (Filebeat, Elasticsearch, Grafana)

This is a highly popular and robust stack for log monitoring, often referred to as F-E-G (Filebeat, Elasticsearch, Grafana). It's a modern and lighter-weight alternative to the traditional ELK stack (Elasticsearch, Logstash, Kibana) when you replace Logstash and Kibana with direct Filebeat-to-Elasticsearch and Grafana.


## The F-E-G Log Stack Breakdown
| Component | Role | Key Function |
|---|---|---|
| Filebeat | Log Shipper | A lightweight agent installed on your servers to monitor log files, collect the log data, and forward it to a destination. It is optimized for handling log files, managing state, and backpressure. |
| Elasticsearch | Log/Data Store | The central database that stores the log events as searchable documents. Filebeat often ships data in a structured format (JSON), making it easy for Elasticsearch to index and query. |
| Grafana | Visualization | The front-end tool used to query the data in Elasticsearch and present it on dashboards, allowing for log analysis, filtering, and visualization of log metrics (e.g., error rate, request volume). |
dummy1 (grafana management)


http://192.168.3.4:3000/

## Grafana Zabbix

Url

* https://192.168.3.5/zabbix/api_jsonrpc.php

https://grafana.com/grafana/plugins/alexanderzobnin-zabbix-app/


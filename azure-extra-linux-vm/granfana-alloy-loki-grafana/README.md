# Stack for log monitoring, Grafana Alloy, Loki and Grafana

Telegraf as your log collector instead of Logstash, you'll still need a backend storage and indexing solution, as well as a visualization tool.
If you are already using Grafana and are looking for a cost-effective and relatively simple setup, Telegraf + Grafana Loki is a great option.



## Grafana Alloy

Grafana Alloy is a versatile observability collector that can ingest logs in various formats and send them to Loki. We recommend Alloy as the primary method for sending logs to Loki, as it provides a more robust and feature-rich solution for building a highly scalable and reliable observability pipeline.

https://grafana.com/docs/loki/latest/send-data/alloy/

grafana_alloy

![grafana_alloy] (https://github.com/spawnmarvel/linux-and-azure/blob/main/images/grafana_alloy.jpg)

## Loki

Grafana Loki is a set of open source components that can be composed into a fully featured logging stack. A small index and highly compressed chunks simplifies the operation and significantly lowers the cost of Loki.

https://grafana.com/docs/loki/latest/

## Grafana
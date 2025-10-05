# Stack for log monitoring, Grafana Alloy, Loki and Grafana

The combination of Grafana Alloy, Loki, and Grafana forms a powerful and widely recommended stack for comprehensive log monitoring across various environments. 
This is often referred to as part of a "LGTM" (Loki, Grafana, Tempo, Mimir) stack.

## Grafana Alloy

Log Collector/Agent: Collects, transforms, and ships logs from your servers, applications, and containers (local files, systemd, Kubernetes, etc.). It is the new generation of collector, replacing the deprecated Promtail and Grafana Agent.

* Grafana Alloy has native pipelines for leading telemetry signals, such as Prometheus and OpenTelemetry, and databases such as Loki and Pyroscope. This permits logs, metrics, traces, and even mature support for profiling.

https://grafana.com/docs/loki/latest/send-data/alloy/

grafana_alloy

![grafana_alloy](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/granfana-alloy-loki-grafana/images/grafana_allow.jpg)

## Loki

Log Aggregation System: Stores and indexes the collected log data. Loki is unique because it indexes metadata (labels) about the logs, not the log content itself, making it highly cost-effective and scalable.

* Grafana Loki is a set of open source components that can be composed into a fully featured logging stack. A small index and highly compressed chunks simplifies the operation and significantly lowers the cost of Loki.

https://grafana.com/docs/loki/latest/

![loki](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/granfana-alloy-loki-grafana/images/loki.png)

## Grafana

Visualization/Analysis Platform: Provides the user interface for querying, visualizing, and analyzing the logs stored in Loki using its LogQL query language.

dummy1 (grafana management)
http://192.168.3.4:3000/
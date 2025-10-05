# Stack for log monitoring, Grafana Alloy, Loki and Grafana

The combination of Grafana Alloy, Loki, and Grafana forms a powerful and widely recommended stack for comprehensive log monitoring across various environments. 
This is often referred to as part of a "LGTM" (Loki, Grafana, Tempo, Mimir) stack.

## Grafana Alloy

Log Collector/Agent: Collects, transforms, and ships logs from your servers, applications, and containers (local files, systemd, Kubernetes, etc.). It is the new generation of collector, replacing the deprecated Promtail and Grafana Agent.

* Grafana Alloy has native pipelines for leading telemetry signals, such as Prometheus and OpenTelemetry, and databases such as Loki and Pyroscope. This permits logs, metrics, traces, and even mature support for profiling.

https://grafana.com/docs/loki/latest/send-data/alloy/

grafana_alloy

![grafana_alloy](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/granfana-alloy-loki-grafana/images/grafana_alloy.jpg)

## Loki

Log Aggregation System: Stores and indexes the collected log data. Loki is unique because it indexes metadata (labels) about the logs, not the log content itself, making it highly cost-effective and scalable.

* Grafana Loki is a set of open source components that can be composed into a fully featured logging stack. A small index and highly compressed chunks simplifies the operation and significantly lowers the cost of Loki.

https://grafana.com/docs/loki/latest/

![loki](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/granfana-alloy-loki-grafana/images/loki.png)

dummy1 (grafana management)
http://192.168.3.4:3000/


### Install manually

```bash


# Browse to the release page.
# https://github.com/grafana/loki/releases/
# Find the Assets section for the version that you want to install.
# Download the Loki and Promtail archive files that correspond to your system.
# https://github.com/grafana/loki/releases/

```
https://grafana.com/docs/loki/latest/setup/install/local/loki-3.5.5.tar.gz

### Update the script

```bash
# set correct loki version
sudo bash install_loki.sh
```
| Step | Command | Purpose |
| :--- | :--- | :--- |
| **Setup** | `mkdir loki-local-install && cd loki-local-install` | Creates the working directory and changes the current location to it. |
| **Download Binaries** | `wget "https://github.com/grafana/loki/releases/download/v3.5.3/loki-linux-amd64.zip"`<br>`wget "https://github.com/grafana/loki/releases/download/v3.5.3/promtail-linux-amd64.zip"` | Downloads the Loki and Promtail zip archives for **Linux x64 (amd64)**. |
| **Extraction** | `unzip loki-linux-amd64.zip`<br>`unzip promtail-linux-amd64.zip` | Extracts the executable binaries (`loki-linux-amd64` and `promtail-linux-amd64`) from the archives. |
| **Permissions** | `chmod +x loki-linux-amd64`<br>`chmod +x promtail-linux-amd64` | Grants **execute permission** to the downloaded binaries. |
| **Download Configs** | `wget https://raw.githubusercontent.com/grafana/loki/v3.5.3/cmd/loki/loki-local-config.yaml -O loki-local-config.yaml`<br>`wget https://raw.githubusercontent.com/grafana/loki/v3.5.3/clients/cmd/promtail/promtail-local-config.yaml -O promtail-local-config.yaml` | Downloads the necessary **version-specific** local configuration files. |
| **Run Loki** | `./loki-linux-amd64 -config.file=loki-local-config.yaml` | Executes the **Loki binary**, pointing it to the downloaded local configuration file to start the log aggregation service. |


## Grafana

Visualization/Analysis Platform: Provides the user interface for querying, visualizing, and analyzing the logs stored in Loki using its LogQL query language.

dummy1 (grafana management)
http://192.168.3.4:3000/
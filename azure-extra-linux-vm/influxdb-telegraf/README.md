

# Influxdb and telegraf

## Telegraf

https://docs.influxdata.com/telegraf/v1/install/


## Install influxdb and Telegraf on linux

OS: Linux vmdocker01 6.5.0-1023-azure #24~22.04.1-Ubuntu

Influxdb

https://docs.influxdata.com/influxdb/v2/install/?t=Linux#install-influxdb-as-a-service-with-systemd


```bash
# check what we have
dpkg --print-architecture

# amd64

# Ubuntu/Debian AMD64
curl -LO https://download.influxdata.com/influxdb/releases/influxdb2_2.7.8-1_amd64.deb
sudo dpkg -i influxdb2_2.7.8-1_amd64.deb


# start the influx db server
sudo service influxdb start

# verify services
sudo service influxdb status

```
Telegraf

https://docs.influxdata.com/telegraf/v1/install/



## Github and Visuals elo

https://github.com/spawnmarvel/linux-and-azure/tree/main/azure-extra-linux-vm/influxdb-telegraf


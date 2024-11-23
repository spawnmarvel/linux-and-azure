# InfluxDB template

https://www.zabbix.com/integrations/influxdb

## Zabbix 6 montor influxdb

* VNET, vnet-uks-central/Vms03
* Zabbix VM, 192.168.3.5
* InfluxDB VM, 192.168.3.4

```bash

# Check influxdb
sudo service influxdb status

influxdb.service - InfluxDB is an open-source, distributed, time series database
     Loaded: loaded (/lib/systemd/system/influxdb.service; enabled; vendor preset: enabled)
     Active: active (running) since Sat 2024-11-23 15:12:00 UTC; 3min 4s ago
```

login influxdb, hm removed self signed

http://ip-address:8086/signin

login zabbix

http://ip-address/zabbix/zabbix.php?action=dashboard.view

# New host

![Influxdb host](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/influxdb/images/influxdb_host.jpg)


# Setup

his template works with self-hosted InfluxDB instances. Internal service metrics are collected from InfluxDB /metrics endpoint. For organization discovery template need to use Authorization via API token. See docs: https://docs.influxdata.com/influxdb/v2.0/security/tokens/

Don't forget to change the macros {$INFLUXDB.URL}, {$INFLUXDB.API.TOKEN}. Also, see the Macros section for a list of macros used to set trigger values. NOTE. Some metrics may not be collected depending on your InfluxDB instance version and configuration.











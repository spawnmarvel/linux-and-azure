## stack with proxy and differnt architectures

## architectures

Architecture:
- Singel vm database and zabbix, size small
- Two vm database and zabbix, size small, medium  or large
- Azure database and zabbix vm, size s, m or l
- Single vm and docker, s, m not l

Architecture  with proxy:

- Source zabbix on of the above, size l or m
- Replica proxy on site with linki to source, size s, l or m
- Could add grafana-zabbix plugin on the proxy
- Zabbix plugin for Grafana, https://grafana.com/grafana/plugins/alexanderzobnin-zabbix-app/

# How Does the Zabbix Proxy Roll Out Plan Work?

* Zabbix proxy is an optional, lightweight, server-side component that collects monitoring data (performance and availability) from devices on behalf of a main Zabbix server, reducing load and enabling distributed monitoring. It buffers data locally and transfers it to the central server, making it ideal for remote sites or networks with unreliable connections. 
* Proxies require a dedicated database (SQLite or MySQL/PostgreSQL) and, as of v7.0, support high-availability and load-balancing via proxy groups. 

Key Features and Benefits

* Reduced Server Load: Offloads the central server by handling data collection, reducing CPU and disk I/O usage.
* Remote/Distributed Monitoring: Ideal for monitoring networks behind firewalls or remote locations with low bandwidth.
* Data Buffering: Local storage prevents data loss during temporary network interruptions between the proxy and the server.
* High Availability (v7.0+): Proxy groups allow for automatic failover and load balancing, where hosts are redistributed if a proxy goes offline. 

Operational Details

* Requirements: A separate database (e.g., MySQL, PostgreSQL, SQLite for small, non-intensive setups).
* Configuration: The Hostname in the proxy config file must match the name defined in the Zabbix frontend.
* Active vs. Passive: Proxies can operate in active mode (pulling config from the server) or passive mode (waiting for the server to connect).
* Limitations: Proxies cannot perform actions (e.g., sending alerts) on their own, as all trigger logic is processed on the main server.

## Zabbix Proxy in "push only" mode

To set up a Zabbix Proxy in "push only" mode, you are looking for what Zabbix formally calls an Active Proxy. In this configuration, the proxy initiates all communication, "pushing" data to the Zabbix Server and "pulling" its own configuration from the server.

This is ideal for monitoring remote networks behind firewalls or NAT, as it requires zero open inbound ports on the proxy’s side.

1. Proxy Configuration (zabbix_proxy.conf)

On the proxy server, edit your configuration file (usually /etc/zabbix/zabbix_proxy.conf) with these key parameters:

 * ProxyMode=0: This is the critical setting. 0 sets the proxy to Active (push) mode.
 * Server=<Zabbix_Server_IP_or_FQDN>: The IP or address of your central Zabbix Server.
 * Hostname=<Proxy_Name>: This must exactly match the "Proxy name" you enter in the Zabbix Web UI.

2. Web Interface Configuration

You must register the proxy in the Zabbix frontend so the server knows to accept its data.

 * Go to Administration → Proxies (or Reports → Proxies in newer versions).
 * Click Create proxy.
 * Proxy name: Match the Hostname from your config file.
 * Proxy mode: Select Active.
 * (Optional) Proxy address: You can list the IP of the proxy here for extra security, but for a true "push" setup from a dynamic IP, you can leave this blank.

3. Communication Flow

In this mode, the port requirements are unidirectional:

 * Proxy → Server: The proxy connects to the server on port 10051.
 * Server → Proxy: No connection is made. The server remains passive and waits for the proxy to check in.

[!IMPORTANT]
Data Buffering: One of the biggest perks of this setup is that if the connection to the Zabbix Server drops, the proxy will store the collected data in its local database and "push" it all at once when the connection is restored.
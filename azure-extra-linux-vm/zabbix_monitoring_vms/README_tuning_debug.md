# Tuning debug


## How a Single Agent Can Jam Port 10051


1. Flooding with Data

- If an agent is misconfigured or buggy and sends data at a very high frequency (much more than needed), it can quickly fill the receive queue (`recv-q`) for port 10051.
- This can overwhelm the Zabbix server’s trapper processes.

2. Large Data Packets

- An agent sending unusually large payloads or too many items at once might cause processing delays, making it harder for trappers to keep up.

3. Rapid Reconnects

- If an agent repeatedly connects/disconnects (e.g., in a crash loop or bad script), it can consume TCP connections and fill the queue.

4. Network Issues

- If the agent’s network path is flaky, it might keep retrying, further increasing load on the port.

---

Symptoms of a Jammed Port


- High `recv-q` value for port 10051 (observed using `ss -ltn` or `netstat`).
- Trapper utilization spikes or trappers become 100% busy.
- Zabbix server log shows errors like:
  - `Zabbix trapper processes more than 75% busy`
  - `cannot accept new connection: [104] Connection reset by peer`
- Other agents/proxies cannot send data; their connections are delayed or refused.
- Dropped or delayed monitoring data in Zabbix frontend.

---

How to Investigate and Mitigate


1. Identify the Offending Source

- Use `ss -antp | grep 10051` or `netstat -anp | grep 10051` to see which IPs have many or frequent connections.
- Check Zabbix server log for clues about rapidly connecting hosts.

2. Throttling or Blocking

- If necessary, use firewall rules (e.g., `iptables`, `firewalld`) to temporarily block the offending agent’s IP.
- Contact the system owner to fix or reconfigure the problematic agent.

3. Server Hardening

- Increase `StartTrappers` (number of trapper processes) if appropriate.
- Ensure your server and database can handle the expected load.
- Limit maximum connections via OS-level settings if needed.

4. Agent Configuration

- On the agent side, check `Hostname`, item update intervals, and ensure it’s not set to send huge amounts of data.

---

Summary Table


| Scenario                      | Effect on Port 10051 | Solution                      |
|-------------------------------|----------------------|-------------------------------|
| One agent floods with data     | Port jammed, recv-q fills | Block agent, fix config        |
| One agent sends huge packets   | Port slow, possibly jammed | Fix agent, limit payload size  |
| Many rapid connects/disconnects| Port jammed, trappers busy | Block or fix agent             |

---

In short:  
Yes, a single rogue Zabbix agent can jam port 10051 by sending too much or too frequent data. Identify and fix the agent; if necessary, block it temporarily to restore server function. Always monitor your Zabbix server’s connections and trapper utilization for early warnings.

## Tune agents

es, you can tune how **Zabbix agents** connect, reconnect, and handle timeouts—both on the **agent** and the **server** side. Below are the main parameters you can adjust and where to find them.

---

## **On the Zabbix Agent Side (zabbix_agentd.conf or zabbix_agent2.conf):**
### **1. Active Check Intervals**
- **RefreshActiveChecks**: How often the agent requests the list of active checks from the server (default: 120 seconds).
- **ServerActive**: The address of the Zabbix server or proxy for active checks.

### **2. Connection/Timeout Settings**
- **Timeout**: Maximum number of seconds for agent checks (default: 3 seconds, can be increased if checks are slow).
- **StartAgents**: Number of pre-forked instances for passive checks (for handling concurrent requests).
- **HostnameItem**: Which system value to use as agent hostname (not related to connections, but can help avoid duplicate/confused hosts).

### **3. Buffer/Queue Controls (Agent 2)**
- **BufferSend**: How often the agent sends buffered data in seconds.
- **BufferSize**: How many values are buffered before being sent.
- **MaxLinesPerSecond**: Throttle how many log lines are sent per second for log monitoring.

### **4. Debugging**
- **LogRemoteCommands**: Can help identify command or connection issues.

---

### **Example Tuning in zabbix_agentd.conf:**
```ini

Server=your.zabbix.server
ServerActive=your.zabbix.server

RefreshActiveChecks=60
Timeout=5
BufferSend=5
BufferSize=100
StartAgents=3


### Option: Timeout
#	Specifies how long to wait (in seconds) for establishing connection and exchanging data with Zabbix proxy or server.
#
# Mandatory: no
# Range: 1-30
# Default:
# Timeout=3
Timeout=30
```

## **On the Zabbix Server Side (zabbix_server.conf):**
### **1. Trapper/Connection Handling**
- **StartTrappers**: Number of trapper processes to handle incoming agent/connections.
- **Timeout**: How long the server waits for agent or proxy responses.

### **2. Incoming Connection Limits (OS-level)**
- You can further tune connection queue sizes and timeouts at the OS/network stack level (e.g., net.core.somaxconn, tcp_tw_reuse, tcp_fin_timeout in /etc/sysctl.conf).
---

## **Other Tips:**

- **Reduce agent data frequency** if not all data is needed as often.
- **Avoid massive log monitoring** with loose patterns, as this can flood the server.
- **Distribute agent check times** (avoid all agents sending at the same second).
- **Upgrade agents** to the latest version for performance and bug fixes.

---

## **References:**

- [Zabbix Agent parameters (official)](https://www.zabbix.com/documentation/current/en/manual/appendix/config/zabbix_agentd)
- [Zabbix Agent 2 parameters](https://www.zabbix.com/documentation/current/en/manual/concepts/agent/agent2)

---

## **In summary:**

You can tune Zabbix agent connection, reconnection, and timeout behavior directly in the agent’s config file (zabbix_agentd.conf or zabbix_agent2.conf). You can also adjust server and OS parameters for better handling of connections and timeouts. Most common settings to tweak are Timeout, RefreshActiveChecks, BufferSend, and BufferSize.
If you want a sample config for your environment, just let me know your use case!


## We have seen it before


If ss -ltn shows that the recv-q is full for port :10051 (which is the default listening port for Zabbix server’s trapper process), it means the socket’s receive queue is full. This is a sign that the Zabbix server is not processing incoming connections or data fast enough, and messages sent to the server are piling up.
---

## What does this mean?

- **Port 10051**: This is where Zabbix server listens for incoming **trapper** and **active agent** data (including zabbix_sender and Zabbix proxies).- **recv-q full**: The receive queue is full, so new incoming data is being delayed or dropped.
- **Likely cause**: The Zabbix server’s trapper (or sometimes poller) processes are overloaded and can’t keep up with the rate of incoming data.

---

## Why is this bad?

- Some incoming data will be dropped or delayed.
- Monitored metrics may be missing or appear late.
- Zabbix senders or agents may show errors like "Connection refused" or "Connection timeout".

---

## Common Reasons

- **Too few trapper processes** (see StartTrappers in zabbix_server.conf).- **Server underpowered** (CPU, disk, memory bottlenecks).
- **Sudden spike in incoming data** (many hosts sending at the same time). 
- **Slow database performance** (Zabbix can’t write to DB fast enough).

---

## What should you do?

### 1. **Check Zabbix internal metrics**
- Look at Trapper processes utilization (%) and Poller processes utilization (%).- If either is consistently high (over 75-80%), you need to scale.

### 2. **Increase StartTrappers**
- Edit zabbix_server.conf and raise the value of StartTrappers.- Example:  
output

  StartTrappers=10

  (Default is often 5. Increase to 10, 20, or more as needed.)

### 3. **Check system resources**
- Ensure the server has enough CPU and RAM.
- Monitor disk and database performance.

### 4. **Database performance**
- If the database is slow, Zabbix can’t insert new values quickly, causing a backlog.
- Tune your database (indexes, disk speed, connections).

### 5. **Check for network issues**
- Ensure there’s no network bottleneck or firewall dropping packets.

### 6. **Restart Zabbix server**
- After changing configuration, restart the Zabbix server.

---

## Summary Table

| Problem                      | Cause                                         | Solution                        |
|------------------------------|-----------------------------------------------|----------------------------------|
| recv-q full on :10051      | Trapper queue overloaded, not enough trappers | Increase StartTrappers, optimize DB || Delayed/missing data         | Server can't process incoming data fast enough| Add resources, tune DB, more trappers|

---

**In short:**  
A full recv-q on port 10051 means your Zabbix server’s trapper processes are overloaded. Increase StartTrappers, check server and database performance, and monitor internal Zabbix queues for bottlenecks. If you need step-by-step instructions for your environment, let me know your Zabbix version and server specs!


## Config

 sudo cat zabbix_server.conf | grep 'Start*'
### Option: StartPollers
StartPollers=30
### Option: StartIPMIPollers
# StartIPMIPollers=0
### Option: StartPreprocessors
StartPreprocessors=5
### Option: StartPollersUnreachable
StartPollersUnreachable=5
### Option: StartHistoryPollers
StartHistoryPollers=5
### Option: StartTrappers
StartTrappers=20
### Option: StartPingers
StartPingers=5
### Option: StartDiscoverers
StartDiscoverers=5
### Option: StartHTTPPollers
StartHTTPPollers=5
### Option: StartTimers
StartTimers=2
### Option: StartEscalators
StartEscalators=1
### Option: StartAlerters
StartAlerters=5
### Option: StartJavaPollers
# StartJavaPollers=0
### Option: StartVMwareCollectors
# StartVMwareCollectors=0
### Option: StartSNMPTrapper
# StartSNMPTrapper=0
### Option: StartDBSyncers
StartDBSyncers=10
### Option: StartProxyPollers
# StartProxyPollers=1
### Option: StartLLDProcessors
# StartLLDProcessors=2
### Option: StartReportWriters
# StartReportWriters=0
## Option: StartODBCPollers
# StartODBCPollers=1

## **Factors Affecting StartTrappers**

1. **Number of hosts sending data via trapper** (active agents, zabbix_sender, proxies)
2. **Data arrival rate** (metrics per second/minute/hour)
3. **Server hardware** (CPU, RAM, disk speed)
4. **Database performance**
5. **Network latency**

- Use the Zabbix internal item:  
  zabbix[process,trapper,avg,busy]- If the value is consistently above 75–80%, you need more trappers.

If your recv-q is filling up, or you see Zabbix trapper processes more than 75% busy in logs, **increase** StartTrappers.- If utilization is always low (e.g., below 10%), you can **reduce** the value to save resources.


For most environments:
- Small: **5–10**
- Medium: **10–20**
- Large (hundreds of hosts, proxies): **20–50** (or even higher)



## ss- ltn  recvQ size is not decreasing

- The proxy and server are set up on the vm machines based on openstack, and someone changed the security group that caused the problem. After restore the security group setting, everything is fine now.


https://www.zabbix.com/forum/zabbix-troubleshooting-and-problems/408334-can-t-connect-to-the-proxy-s-10051-from-agent-sometimes


We had a similar situation years ago and it was due to the number and frequency of connections.

This turned out to be an issue with the zabbix server/proxy instead of the settings on the OS side

The Zabbix issue on this can be found here. ListenBacklog is now a parameter and can be set in the configuration file.

https://support.zabbix.com/browse/ZBX-7933?_gl=1%2A3osmch%2A_gcl_au%2AODY2MzI1MDAzLjE3NDk2NDIyODE.%2A_ga%2AMTA2MTg0NDAyMi4xNzQ5NjQyMjgx%2A_ga_1F6WJN99ZG%2AczE3NDk2NDIyODAkbzEkZzEkdDE3NDk2NDI1NzMkajgkbDAkaDA.

https://www.zabbix.com/forum/zabbix-for-large-environments/421171-proxy-connections-unstable-on-large-environments

## Zabbix server parameters


ListenBacklog
* The maximum number of pending connections in the TCP queue.
* The default value is a hard-coded constant, which depends on the system.
* The maximum supported value depends on the system, too high values may be silently truncated to the 'implementation-specified maximum'.

* Default: SOMAXCONN
* Range: 0 - INT_MAX


https://www.zabbix.com/documentation/current/en/manual/appendix/config/zabbix_server

## CLOSE-WAIT	11432


```bash
ss -tn | grep ':10051'

```
state	      recv-q	send-q	local	remote
CLOSE-WAIT	11432	0	10.10.10.10:10051	10.10.10.140:63015


If you have lots of connections staying in CLOSE_WAIT it means that the process responsible is not closing the socket once it goes into CLOSE_WAIT. 

You could use tcpdump, or other network traffic capture tools, to look at the packets.

lot of connections stuck in CLOSE-WAIT

https://serverfault.com/questions/65944/running-lsof-i-shows-a-lot-of-connections-in-close-wait-should-i-worry

Or something with windows agents on the top hosts?

## When we restart the Zabbix agent the issue is resolved, but reoccurs after a period of time.



```bash

2025/06/12 07:14:13.005504 Detected performance counter with negative denominator the second time after retry, giving up...
2025/06/12 07:14:14.007742 Detected performance counter with negative denominator the second time after retry, giving up...
2025/06/12 07:15:20.005585 Detected performance counter with negative denominator the second time after retry, giving up...

```

As temporary workaround, an automatic service restart on failure can be implemented on Windows level.

1. Open run, type "services.msc"
2. Find Zabbix agent, click on it
3. Go to "Recovery" tab
4. Configure agent to be restarted on failure.


https://support.zabbix.com/browse/ZBX-21703



## [Z3008] query failed due to primary key constraint:

we have
```ini

4028678:20250613:204626.381 executing housekeeper
4028694:20250613:204718.158 [Z3008] query failed due to primary key constraint: [1062] Duplicate entry '52189-1749840437-776661741' for key 'history.PRIMARY'
4028694:20250613:204718.161 skipped 1 duplicates
4028678:20250613:204756.578 housekeeper [deleted 240402 hist/trends, 0 items/triggers, 31 events, 4 problems, 63 sessions, 0 alarms, 0 audit, 0 autoreg_host, 0 records in 90.160465 sec, idle for 1 hour(s)]
4028695:20250613:205337.661 [Z3008] query failed due to primary key constraint: [1062] Duplicate entry '52189-1749840816-444865391' for key 'history.PRIMARY'
4028695:20250613:205337.681 skipped 1 duplicates
4028691:20250613:205748.270 [Z3008] query failed due to primary key constraint: [1062] Duplicate entry '52189-1749841067-936851269' for key 'history.PRIMARY'
4028691:20250613:205748.273 skipped 1 duplicates
4028694:20250613:205955.871 [Z3008] query failed due to primary key constraint: [1062] Duplicate entry '58852-1749841194-820270211' for key 'history_uint.PRIMARY'
4028694:20250613:205955.873 skipped 1 duplicates

```
52189

You have itemid (from error message) - go to edit page of any item and replace the itemid number in browser url.


https://www.zabbix.com/forum/zabbix-troubleshooting-and-problems/498278-z3008-query-failed-due-to-primary-key-constraint

## Agent log Interrogate

```ini
2025/06/13 23:49:15.832551 unsupported windows service command 'Interrogate' received
```

Also have same problem on WinServ2019 with Agent2

https://www.zabbix.com/forum/zabbix-troubleshooting-and-problems/414831-agent2-on-windows-server-unsupported-windows-service-command-recieved
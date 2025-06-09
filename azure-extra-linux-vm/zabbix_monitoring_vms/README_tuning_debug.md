# Tuning debug


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
- **Sudden spike in incoming data** (many hosts sending at the same time). !!!!!!
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


# Recv-Q

## Zabbix server 6.0.40 Recv-Q is full tcp 10051


net.netfilter.nf_conntrack_max

https://www.zabbix.com/forum/zabbix-help/504021-zabbix-server-6-0-40-recv-q-is-full-tcp-10051

##


net.netfilter.nf_conntrack_max is a Linux kernel parameter that controls the maximum number of tracked network connections (conntrack entries) using the **Netfilter connection tracking system** (commonly known as "conntrack"). This is particularly important for systems using **iptables** or **firewallD** with connection tracking enabled (e.g., NAT, stateful firewall rules).
---

## **What Does It Do?**

- **nf_conntrack_max** sets the upper limit on the number of simultaneous tracked connections.- Each connection (TCP, UDP, etc.) passing through the firewall is tracked, consuming system memory.
- When this limit is reached, new connections will **not be tracked** and may be dropped or ignored by firewall rules that depend on conntrack.

---

net.netfilter.nf_conntrack_max is a Linux kernel parameter that controls the **maximum number of tracked connections** (network flows) by the netfilter connection tracking system (commonly called "conntrack"). This setting is crucial for systems acting as firewalls, NAT gateways, or routers, but it also affects any system using connection tracking for stateful packet inspection.
---

## **What is it?**

- **nf_conntrack**: Kernel module that tracks the state of network connections (TCP, UDP, etc.).- **nf_conntrack_max**: Maximum number of simultaneous connections that can be tracked.
---

## **How to View the Current Value**

```bash
cat /proc/sys/net/netfilter/nf_conntrack_max

# or

sysctl net.netfilter.nf_conntrack_max

```
---

## **How to Change the Value**

- **Temporarily (until reboot):**

```bash

echo 262144 | sudo tee /proc/sys/net/netfilter/nf_conntrack_max

# or

sudo sysctl -w net.netfilter.nf_conntrack_max=262144
```

- **Permanently (survives reboot):**
  Add to /etc/sysctl.conf or a file in /etc/sysctl.d/:
output
```ini
  net.netfilter.nf_conntrack_max=262144
```
  Then reload with:
bash
```bash
  sudo sysctl -p
```

---

## **Why Change It?**

- **Symptoms of too low a value:**  
  - Dropped connections
  - Log messages like:  
output
```ini
    nf_conntrack: table full, dropping packet
```
- **Set a higher value if:**  
  - You have a high-traffic server or firewall
  - You see dropped packets or connection tracking table full messages

---

## **Check Current Usage**

To see current usage and maximum:
bash

cat /proc/sys/net/netfilter/nf_conntrack_count
cat /proc/sys/net/netfilter/nf_conntrack_max


---

**Summary:**  
net.netfilter.nf_conntrack_max sets the maximum number of connections the Linux kernel will track. Increase it if you have many concurrent connections and run into limits.
Let me know if you want tuning tips or want to monitor actual usage!

## ss -ltn

Proto Recv-Q Send-Q Local Address Foreign Address State PID/Program name
tcp 0 0 127.0.0.1:12563 0.0.0.0:* LISTEN -
tcp 4097 4096 0.0.0.0:10051 0.0.0.0:* LISTEN -


Does nf_conntrack_max Help With This?

* NO, increasing nf_conntrack_max will NOT help with high Recv-Q/Send-Q values for a LISTEN socket.
* nf_conntrack_max is about the maximum number of tracked connections (i.e., how many connections the kernel will keep state for). It is relevant for:  - Firewall/NAT stateful rules
  - High connection churn (lots of new/closing connections)
  - Dropped packets with "nf_conntrack: table full" errors

- **High Recv-Q/Send-Q values** mean:
  - The application listening on port 10051 is **not accepting connections or not reading data fast enough**.
  - Clients may be trying to connect or send data, but the server is not processing them promptly.
  - It could indicate the application is overloaded, stuck, or crashed.


## nf_conntrack: table full, dropping packet.

To know if your system is experiencing **nf_conntrack: table full, dropping packet** errors (i.e., the conntrack table is full and packets are being dropped), you can check your system logs and monitor connection tracking usage.

How to check

```bash
grep nf_conntrack /var/log/syslog

```

You can check how full your conntrack table is:

```bash
cat /proc/sys/net/netfilter/nf_conntrack_count
cat /proc/sys/net/netfilter/nf_conntrack_max
```

If nf_conntrack_count is equal to or very close to nf_conntrack_max, you are at risk of hitting the limit and dropping packets.


What to Do If You See These Errors

* Increase nf_conntrack_max (if your system has enough RAM).- Investigate why so many connections are being tracked (e.g., attack, misconfiguration, legitimate high traffic).
* Tune connection tracking timeouts if appropriate.



| Setting/Parameter       | Affects Recv-Q/Send-Q? | What it affects                    |
|------------------------ |:----------------------:|------------------------------------|
| `nf_conntrack_max`      |           No           | Number of tracked connections      |
| Application read/write  |          Yes           | Recv-Q/Send-Q                     |
| Network issues          |          Yes           | Recv-Q/Send-Q                     |


In short:  
`nf_conntrack_max` does not control the size of socket queues. High Recv-Q/Send-Q is an application or network problem, not a conntrack setting problem.



## Recv-Q

Application Behavior = 

- Recv-Q:  
  - Increases if the application is not reading data fast enough from the socket.
  - Example: If a server is slow to process incoming requests, the data will accumulate here.


Network Conditions = 

- Recv-Q:  
  - If incoming data arrives faster than the application can process it, Recv-Q grows.


Peer (Remote Side) Behavior = 

Recv-Q:  
  - If the remote side sends data too quickly for your application to process, Recv-Q will increase.


Socket Buffer Sizes = 

- The maximum amount of data that can be held in Recv-Q and Send-Q is determined by socket buffer sizes (controlled by sysctl or application settings, e.g., `SO_RCVBUF` and `SO_SNDBUF`).


System Resource Constraints =

- CPU/memory/disk bottlenecks: If your server is overloaded, it might not process incoming or outgoing data fast enough.
- Threading or event loop issues: If the application is blocked or single-threaded, queues can grow.


Application Bugs/Deadlocks = 

- If the application stops reading or writing due to a bug or deadlock, queues will fill up.


Summary Table

| Factor                        | Affects Recv-Q | Affects Send-Q |
|-------------------------------|:-------------:|:-------------:|
| Application (slow read)       |      Yes      |      No       |
| Application (slow write)      |      No       |      Yes      |
| Network congestion/latency    |      No       |      Yes      |
| Remote side (slow read)       |      No       |      Yes      |
| Remote side (fast send)       |      Yes      |      No       |
| Socket buffer size            |      Yes      |      Yes      |
| System resource limits        |      Yes      |      Yes      |
| App bug/deadlock              |      Yes      |      Yes      |


In summary:  
- High Recv-Q: Application is not reading data fast enough, or peer is sending too quickly.
- High Send-Q: Application is writing data faster than the network or peer can handle.






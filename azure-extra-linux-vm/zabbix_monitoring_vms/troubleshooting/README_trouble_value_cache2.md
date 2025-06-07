## 01:00


Zabbix server

```bash
404096:20250606:181549.689 failed to accept an incoming connection: connection rejected, getpeername() failed: [107] Transport endpoint is not connected
404096:20250606:181549.689 failed to accept an incoming connection: connection rejected, getpeername() failed: [107] Transport endpoint is not connected
404096:20250606:181549.689 failed to accept an incoming connection: connection rejected, getpeername() failed: [107] Transport endpoint is not connected
404096:20250606:181549.689 failed to accept an incoming connection: connection rejected, getpeername() failed: [107] Transport endpoint is not connected
404096:20250606:181549.689 failed to accept an incoming connection: connection rejected, getpeername() failed: [107] Transport endpoint is not connected
404096:20250606:181549.689 failed to accept an incoming connection: connection rejected, getpeername() failed: [107] Transport endpoint is not connected
```

```bash
sudo cat zabbix_server.conf | grep 'StartTr*'
### Option: StartTrappers
StartTrappers=20
```
 
Agent Example log from 01:00 to 03:30
```log
2025/06/04 01:02:07.716157 [101] cannot receive data from [10.75.160.132:10051]: Cannot read message: 'read tcp 10.10.12.12:63648->10.75.160.132:10051: i/o timeout'
2025/06/04 01:02:07.716157 [101] active check configuration update from host [SERVER-TRC123] started to fail
2025/06/04 01:04:38.717094 [101] cannot receive data from [10.75.160.132:10051]: Cannot read message: 'read tcp 10.10.12.12:64028->10.75.160.132:10051: i/o timeout'

```

```bash
on zabbix server the ss -ltn = recv-q is full for :10051

```



* In this case was terminated by the firewall.
* I managed to fix this error in my zabbix proxy just enabling the parameter "StartTrappers=17" in zabbix_proxy.conf and restarting the service
* DNS, and they have confirmed that our DNS was down.
* We upgraded to the latest available version of zabbix
* I had the same problem, turned out the firewall was doing content filtering on port 10051 and 10050
* * An indication of this is that both the proxy and the agent report the connection terminated by the peer.
* * In this case was terminated by the firewall.

https://www.zabbix.com/forum/zabbix-troubleshooting-and-problems/426772-zabbix-proxy-getpeername-failed-107-transport-endpoint-is-not-connected


## Answer

These log entries are very clear and directly confirm the issues we've been discussing:

`404096:20250606:181549.689 failed to accept an incoming connection: connection rejected, getpeername() failed: [107] Transport endpoint is not connected`

This message, repeating multiple times at the same timestamp (which is within the problematic time window), indicates a critical failure on your Zabbix server's part to establish new connections.

Let's break it down:

* **`404096`**: This is the Process ID (PID) of a Zabbix server process that is attempting to accept an incoming connection.
* **`20250606:181549.689`**: The exact timestamp of the error, aligning with the periods when your server experiences heavy load.
* **`failed to accept an incoming connection: connection rejected`**: This is the core problem. The Zabbix server is actively trying to `accept()` a new TCP connection (i.e., pull a connection from the `ListenBacklog` queue), but it's failing. The connection is being rejected.
* **`getpeername() failed: [107] Transport endpoint is not connected`**: This is the specific error code from the operating system (Linux, in this case).
    * `getpeername()` is a system call that the server makes to get the address of the client that just connected.
    * `[107] Transport endpoint is not connected` means that by the time the Zabbix server process tried to accept the connection and inquire about the client's address, the connection that was *supposed* to be there was already gone or was never fully established from the client's perspective.

### What This Error Confirms:

This error is a **direct and severe symptom of your Zabbix server being heavily overloaded and unable to keep up with the rate of incoming connection attempts.**

Even with your large `ListenBacklog` of 4096, if the server is so busy that its Zabbix trapper processes cannot:

1.  **Quickly accept connections from the `ListenBacklog` queue,** or
2.  **Even initiate the `accept()` process in time** before the client gives up or the connection state on the network is lost,

...then you will see these `connection rejected` errors. The `Transport endpoint is not connected` part implies that the client-side of the connection attempt might have already timed out or been reset before the server could fully take ownership of it.

Essentially, your server is so bogged down that it's failing at the very fundamental step of accepting new incoming connections, leading to the various agent-side timeouts and disconnections you've reported.

The next logical step would be to **thoroughly examine the Zabbix server's overall resource utilization** (CPU, memory, disk I/O, network I/O) and, most importantly, the **busy rates of its Zabbix internal processes, especially the trappers**, during these problematic periods. This will help confirm precisely which resource is the bottleneck.


## sudo service zabbix-stop start

the only thing that helps is sudo service zabbix-server stop and start. Then all is fine again

That's a very common and critical piece of information when troubleshooting applications that become unresponsive under load!

When a simple `sudo service zabbix-server stop` followed by `start` temporarily resolves all the issues (connections, data processing, agent errors), it strongly indicates that the Zabbix server process is getting into a **stuck, deadlocked, or resource-exhausted state that it cannot recover from on its own.**

Here's what that suggests:

1.  **Resource Accumulation/Leak:** The Zabbix server processes (especially trappers, pollers, history syncers, etc.) might be accumulating memory, open file descriptors, or other resources over time without releasing them. A restart clears all these accumulated resources.
2.  **Stuck/Deadlocked Processes:** Some of the Zabbix server's internal processes (like the trappers you saw at 0% utilization) might be getting stuck, deadlocked, or entering an unresponsive state due to the high load or a specific data pattern. A restart forces these processes to terminate and restart cleanly.
3.  **Internal Queue Issues:** While `ListenBacklog` is for the OS TCP queue, Zabbix has its own internal queues (e.g., for history data, alerts). If these internal queues become clogged or corrupted under extreme stress, a restart clears them.
4.  **Database Connection Issues:** The Zabbix server maintains persistent connections to its database. If these connections become stale, corrupted, or hit database-side limits (e.g., max connections per user), a restart forces a fresh set of database connections.

**This behavior significantly narrows down the problem to an internal Zabbix server issue (or interaction with the database) that is triggered by the high load.** The server isn't recovering gracefully from the stress.

### Next Steps to Pinpoint the Internal Problem:

To understand *why* the Zabbix server gets into this state, you need to gather more detailed information just before it becomes unresponsive:

1.  **Increase Zabbix Server Debug Level:**
    * Edit your `zabbix_server.conf` file.
    * Change `DebugLevel=3` (or whatever it is currently) to `DebugLevel=4` or even `DebugLevel=5`.
    * Restart the Zabbix server (`sudo service zabbix-server restart`).
    * **Caution:** Higher debug levels generate a lot of log data very quickly, so monitor your disk space. You should revert it to a lower level (`DebugLevel=3` or `DebugLevel=2`) after you've captured logs during an incident.
    * After the server becomes unresponsive, immediately check the **Zabbix server log file** (e.g., `/var/log/zabbix/zabbix_server.log`). Look for any new warnings, errors, or repeated messages in the minutes leading up to the server becoming stuck.

2.  **Monitor Zabbix Internal Process Busy Rates Continuously:**
    * As mentioned before, use the Zabbix frontend (Monitoring > Hosts > Your Zabbix Server Host > Latest data/Graphs) to monitor **`zabbix[process,<type>,avg,busy]`** for *all* Zabbix processes: `trapper`, `poller`, `unreachable poller`, `discoverer`, `history syncer`, `housekeeper`, `alerter`, `httppoller`, etc.
    * Observe which specific process types start to climb to 100% busy or drop to 0% (indicating they've become unresponsive) just before the server requires a restart. This will tell you *which part* of Zabbix is struggling.

3.  **Monitor System Resources During Load:**
    * Use tools like `top`, `htop`, `iostat`, `netstat`, `vmstat`, `lsof` (to check open file descriptors) on your Zabbix server.
    * Specifically watch:
        * **CPU usage:** Is it maxing out?
        * **Memory usage:** Is it nearing exhaustion? Are there processes consuming excessive RAM?
        * **Disk I/O (iostat):** Is the disk where history data is written becoming a bottleneck?
        * **Open File Descriptors (`lsof -p <zabbix_server_pid>` or `cat /proc/<zabbix_server_pid>/limits`):** Is the Zabbix server hitting its maximum allowed open files?
        * **Swap usage:** Is the server swapping heavily?

4.  **Check Your Database Server's Performance and Logs:**
    * The Zabbix server relies heavily on its database. If the database is too slow or becomes unresponsive, the Zabbix server will also struggle.
    * Check your database server's CPU, memory, I/O, and specifically its **log files** for slow queries, deadlocks, or connection issues occurring at the same time Zabbix hangs.

By gathering this detailed information, you should be able to pinpoint the exact bottleneck or internal issue that necessitates the Zabbix server restart.



## TODO


Zabbix server: Utilization of http poller data collector process, in % = 42.3

Zabbix server: Utilization of unreacable poller data collector process, in % = 300

Zabbix server: Utilization of trapper data collector process, in % = 0

!(Poller 3)[https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/poller_3.jpg]

Okay, the fact that the **"Utilization of poller data collector process"** is also high during the same period (01:00-03:00) as the stuck trappers and busy unreachable pollers paints a clearer picture of a widespread issue within the Zabbix server itself.

Here's what this combination suggests:

* **Systemic Problem:** The problem isn't isolated to just the trappers. If both trappers (handling active checks) and pollers (handling passive checks) are experiencing issues (either being stuck at 0% or highly utilized), it indicates a more fundamental problem within the Zabbix server process itself or its interaction with the database or operating system.
* **Database Bottleneck:** A common cause for both pollers and trappers to struggle is a slow or unresponsive database. If the database cannot quickly accept incoming data or serve requests for passive checks, both pollers and trappers will get blocked waiting for database operations.
* **Resource Exhaustion:** The Zabbix server process might be running into resource limits (CPU, memory, I/O, file descriptors). If the server is starved for resources, both pollers and trappers will be affected.
* **Internal Deadlock or Bug:** There might be an internal deadlock or bug within the Zabbix server code that is triggered by the high load, causing various processes to become stuck or unresponsive.

Given this new information, the next steps are even more critical:

1.  **Prioritize Zabbix Server and System Logs:** The Zabbix server logs (`/var/log/zabbix/zabbix_server.log`) and the system logs (e.g., `/var/log/syslog`, `/var/log/messages`, `journalctl`) are your primary sources of information. Examine these logs very carefully for any errors, warnings, or unusual patterns that occur around the 01:00-03:00 timeframe. Look for anything that might explain why both pollers and trappers are failing.
2.  **Database Performance Analysis:** Thoroughly investigate your Zabbix database server's performance during the problematic periods. Check its CPU, memory, I/O, and especially its slow query log. Look for any database-side issues (slow queries, deadlocks, connection problems) that might be impacting the Zabbix server.
3.  **Resource Monitoring:** Closely monitor your Zabbix server's CPU, memory, disk I/O, and open file descriptors during the 01:00-03:00 window. Use tools like `top`, `htop`, `iostat`, `vmstat`, and `lsof`. Identify any resource bottlenecks.
4.  **Review Zabbix Configuration:** Double-check your `zabbix_server.conf` for any misconfigurations or unusual settings, especially those related to database connections, cache sizes, and the number of processes (pollers, trappers, history syncers).
5.  **Consider Upgrading Zabbix:** If you're running an older version of Zabbix, consider upgrading to the latest stable release. Newer versions often contain bug fixes and performance improvements.
6.  **Check for Custom Scripts:** If you have any custom external checks or scripts that run on the Zabbix server, review them for potential performance issues or resource leaks.

## This is an extremely important piece of information and provides a strong lead!

The fact that your OS was upgraded from **Ubuntu 20.04 to 24.04** approximately three months ago, correlating with a noticeable drop in **Zabbix cache hits**, is highly significant.


!(Cache hits)[https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/cach_hits.jpg]

You are running **Zabbix 6.0.40**, which is the latest patch version for the 6.0 LTS series. While this is good, a major OS upgrade can profoundly affect application performance, even if the application version remains the same.

### Understanding "Lower Value Cache Hits"

* **Zabbix Caching:** Zabbix heavily relies on various internal caches (e.g., configuration cache, history cache, value cache, index cache) to store frequently accessed data in RAM. This drastically reduces the number of expensive database queries, which is critical for performance.
* **Impact of Low Cache Hits:** When cache hit rates drop, it means Zabbix processes (like trappers, pollers, history syncers) are spending much more time:
    * **Querying the database directly:** This is slower and puts more load on the database server.
    * **Waiting for database responses:** This increases the busy time of Zabbix processes, making them appear "stuck" or highly utilized, even if they aren't CPU-bound themselves.
    * **Leading to Queue Growth:** The inability to quickly process data due to slower database interactions causes Zabbix's internal queues to grow, ultimately leading to the symptoms you're observing (connection rejections, agents going unreachable).

### Possible Reasons for Lower Cache Hits After OS Upgrade:

A major OS upgrade from 20.04 to 24.04 can change several underlying factors that impact Zabbix's database interaction and caching efficiency:

Okay, that's excellent news!

Having the Zabbix server and the MySQL/MariaDB database on **separate machines** means that the **12 GiB `innodb_buffer_pool_size` is a very good allocation for your database server's dedicated memory cache.** This configuration typically provides optimal performance for database operations, as the buffer pool isn't competing with the Zabbix server's own RAM requirements.

This strongly reinforces that the **"lower value cache hits" you're observing in Zabbix are likely NOT due to your database's memory cache being undersized.** The bottleneck lies elsewhere, given that your database has a substantial amount of its own RAM dedicated to caching.

### Where to Focus Your Troubleshooting Next:

***Dont forget***

```bash
on zabbix server the ss -ltn = recv-q is full for :10051

```

I have a monitoring application (Zabbix proxy) installed on RHEL 7.8 and since we have a very large environment, we have 2500+ agents connecting to this one server. We're seeing frequent errors while trying to connect to the sever from the agent. The telnet seems to be working but only intermittently.

https://superuser.com/questions/1636379/tcp-packet-drops-on-application-server

## zabbix generate TCP queue overflow

From time to time generates zabbix a TCP queue overflow.
Then is no traffic from / to ZABBIX more possible, only zabbix restart help here.

https://support.zabbix.com/browse/ZBX-7933

## 01:00 Summary

Thank you for providing that last piece of information:

Your `innodb row lock waits` goes from **2-3 (normal) to 8 (high) at 01:00.**

### The Complete Picture: Your Database is Overwhelmed

This final metric perfectly aligns with all the other observations and solidifies the diagnosis. You are now seeing a combination of:

* **More frequent waits (`innodb row lock waits` increasing from 2-3 to 8):** Transactions are encountering locked rows much more often.
* **Longer waits (`innodb row lock times` increasing from 3ms to 18ms):** When transactions *do* have to wait, they are waiting for a significantly longer duration.

This tells us that not only are transactions frequently colliding, but the database is so burdened that it cannot quickly resolve these contentions, causing operations to stall.

### Summary of Database Bottlenecks at 01:00:

Let's put all the database-side symptoms together that you've observed, all peaking at 01:00:

1.  **High Connection Count:** Spiking from ~400 to **1000 connections**.
2.  **Massive I/O Load:** "IO count" (likely IOPS or cumulative ops) jumping from 10k to **40k**, far exceeding your **600 provisioned IOPS**. This indicates severe disk I/O saturation.
3.  **Severe Row Lock Contention:** `innodb row lock times` increasing from 3ms to **18ms**, and `innodb row lock waits` increasing from 2-3 to **8**. This is direct evidence of transactions being blocked and waiting on each other due to the database's inability to process operations quickly.
4.  **Increased Query Load:** `Com_select` (number of SELECT queries) tripling from 1.5k to **4.5k**, adding significant CPU and memory pressure.

### The Clear Conclusion: Database Server is the Bottleneck

Your Zabbix server (with ample CPU, RAM, and no swap usage) is not the problem. Its processes (like your 0% utilized trappers and 60% busy pollers) are acting as they would when they are **blocked, waiting for an unresponsive database**.

The Azure Database for MySQL - Flexible Server, despite its `Standard_D4ds_v4` VM size's *potential* capacity, is critically **under-provisioned and overwhelmed** by the peak workload your Zabbix system demands.

### The Immediate and Essential Solution: Scale Your Database

To resolve this issue, you must **scale up your Azure Database for MySQL - Flexible Server instance**. This is the single most important action to take. You need to provide it with the resources necessary to handle the peak 01:00 workload.

Specifically, you need to increase:

1.  **Provisioned IOPS (by increasing Storage Size):** This is paramount to handle the 40k I/O demand and reduce transaction commit times. You will need to significantly increase your provisioned storage to raise the underlying IOPS limit.
2.  **vCores:** To provide more CPU power to process the 1000 concurrent connections, parse and execute 4.5k SELECTs, and manage other queries, thereby reducing transaction processing time and freeing up locks faster.
3.  **RAM:** To eliminate any potential memory pressure or swapping on the DB server, ensuring all operations run efficiently, especially with such high concurrency.

After scaling, continue to monitor these key database metrics in the Azure Portal (CPU, IOPS, Connections, `innodb row lock times`, `innodb row lock waits`) to confirm that the database can now handle the workload without contention.


## zabbix generate TCP queue overflow

https://support.zabbix.com/browse/ZBX-7933


This bug report is highly relevant to your observed problem! You specifically mentioned:

Your Recv-Q was filling up on Zabbix server port 10051.
Your trapper processes were showing 0% utilization at 01:00.


ZBX-7933 reinforces everything we've discussed: the Recv-Q overflow and the 0% trapper utilization are symptoms of your database being the bottleneck, not necessarily a bug in Zabbix itself that needs a patch (though such patches often improve Zabbix's resilience to slow databases).


Resolution: The issue was marked as "Fixed" and the solution was included in Zabbix versions:
* 5.0.15rc1
* 5.4.4rc1
* 6.0.0alpha1 and later versions (including Zabbix 6.0)

You are running Zabbix 6.0. This means that the fix for ZBX-7933 is already included in your Zabbix server version.

As we've diagnosed, your trappers are at 0% utilization, meaning they are not consuming incoming data.


This is happening because the database is the bottleneck (due to high connections, IOPS saturation, CPU/RAM limits, and severe row lock contention). Zabbix processes are waiting on the database to commit data or retrieve configuration, which leaves the TCP queues to build up.


The solution remains focused on scaling your Azure Database for MySQL - Flexible Server. Once the database can keep up, your Zabbix processes will become active again, consume the incoming TCP queue, and the Recv-Q issue should resolve itself.


## It seesm like db slow, zabbix wait, agent fast or the other way around?

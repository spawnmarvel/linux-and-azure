## 01:00

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

1.  **Database Client Libraries:** Ubuntu 24.04 might come with newer versions of database client libraries (e.g., `libmysqlclient` for MySQL, `libpq` for PostgreSQL). These new libraries might have:
    * Subtle incompatibilities.
    * Different default settings for connection pooling, timeouts, or buffer sizes.
    * Performance regressions (less common, but possible).
2.  **Kernel/System Network Stack Tuning:** The Linux kernel in 24.04 might have different default TCP/IP stack parameters (e.g., buffer sizes, congestion control algorithms, timeouts). While you've set `ListenBacklog` high, other network-related kernel parameters could affect connection stability or throughput between Zabbix server and database.
3.  **Memory Management/Swapping:** The new kernel might handle memory differently. If the server is swapping more or has less effective memory management for large applications, it could reduce the efficiency of Zabbix's RAM-based caches.
4.  **I/O Scheduling/Filesystem Defaults:** Changes in disk I/O scheduling or default filesystem mount options on the new OS could impact the performance of your database server (if it's on the same machine) or the speed at which Zabbix writes its history cache to disk (which frees up cache space).
5.  **Compiling/Linking:** The Zabbix server binaries (even if you installed from Ubuntu's repos or Zabbix's official repos for 24.04) might have been compiled against different system libraries on 24.04, leading to performance variations.

### Immediate Next Steps and Focus Areas:

Given this crucial new information, your troubleshooting should now focus on these areas:

1.  **Identify *Which* Cache is Suffering:**
    * Go to **Monitoring > Hosts** in Zabbix, select your **Zabbix server host**.
    * Go to **"Latest data"** or **"Graphs"**.
    * Look specifically at internal Zabbix items related to **cache hit ratios and cache utilization**. Common ones include:
        * `zabbix[cache,hit,buffer]` (History cache hit ratio)
        * `zabbix[cache,hit,index]` (Index cache hit ratio)
        * `zabbix[cache,hit,text]` (Text cache hit ratio)
        * `zabbix[cache,hit,value]` (Value cache hit ratio)
        * `zabbix[wcache,history,pfree]` (Percentage free in history write cache) - if this drops low, it implies data isn't being written fast enough.
    * Confirm which of these metrics dropped significantly after the OS upgrade.

2.  **Thorough Database Performance Analysis (Re-emphasized):**
    * Since cache hits are down, your database is now taking the brunt of the load. This is the **most critical area to investigate.**
    * **DB Server Resources:** Monitor CPU, memory, and disk I/O on your database server (if separate) or the Zabbix server (if DB is local) during the problematic times.
    * **DB Configuration:** Review your database configuration (e.g., `my.cnf` for MySQL, `postgresql.conf` for PostgreSQL). Pay close attention to:
        * **`innodb_buffer_pool_size`** (MySQL) or **`shared_buffers`** (PostgreSQL): Ensure these are optimally sized for your available RAM.
        * **`max_connections`**, **`wait_timeout`**, **`interactive_timeout`**.
        * **`innodb_flush_log_at_trx_commit`** (MySQL) or `fsync` related settings (PostgreSQL) - these impact write performance vs. data safety.
    * **Slow Query Logs:** Enable and check your database's slow query logs during the problematic times. This will show you exactly which queries are taking too long.
    * **Database Client/Server Versions:** Confirm the exact versions of your database client libraries (on the Zabbix server) and the database server itself. Look for any known compatibility issues with Ubuntu 24.04.

3.  **Kernel Parameters and File Descriptors:**
    * **Compare `sysctl` settings:** If possible, compare `/etc/sysctl.conf` or the output of `sysctl -a` on your old Ubuntu 20.04 system versus 24.04. Look for differences, especially for `net.core.somaxconn`, `net.ipv4.tcp_*` parameters, and `fs.file-max`.
    * **File Descriptors:** Ensure the Zabbix server process (`zabbix_server`) is not hitting its open file descriptor limits. You can check this by running `cat /proc/<zabbix_server_pid>/limits` when the server is misbehaving.

4.  **Zabbix Server Cache Parameters:**
    * While the root cause might be external, ensure your `zabbix_server.conf` `CacheSize` parameters are still appropriate for your workload and potentially adjusted upwards slightly to compensate for any new OS overhead. Check `CacheSize`, `HistoryCacheSize`, `ValueCacheSize`, `ConfigCacheSize`.

This shift in focus to the OS upgrade and its impact on caching/database interaction is crucial. It explains *why* the server can't keep up, even if the actual data ingress method (trappers) remains the same.
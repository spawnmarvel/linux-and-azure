## 18:00 TODO

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

Zabbix server: Utilization of unreacable poller data collector process, in % = 56.1

Zabbix server: Utilization of trapper data collector process, in % = 0

!(Poller 3)[https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/poller_3.jpg]
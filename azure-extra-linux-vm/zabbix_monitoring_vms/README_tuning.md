# Zabbix tuning

## Sudden peaks in inbound flows to Zabbix from Agents, halting Zabbix

We have been here before.
* Updated to new agents on hosts.

https://www.zabbix.com/forum/zabbix-help/479547-sudden-peaks-in-inbound-flows-to-zabbix-from-agents-halting-zabbix

Steps

```bash


sudo tail -f zabbix_server.log
# 1357:20240130:133326.485 failed to accept an incoming connection: connection rejected, getpername() faild: [107] Transport endpoint is not connected.

# tmp fix
sudo service zabbix-server stop
sudo service zabbix-server start
```

The utilization of the trapper data collector was in 100% also.

After I found this post, I have checked with my team, and they have confirmed that our DNS was down.

When they fixed the DNS, the utilization of the trapper data collector fell to 0%, and Zabbix resumed to work properly.

https://github.com/phothet/zabbix/issues/11

```bash
netstat -tulpn

Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 127.0.0.1:12563         0.0.0.0:*               LISTEN      -
tcp      951      0 0.0.0.0:10051           0.0.0.0:*               LISTEN      -
tcp        0      0 0.0.0.0:10050           0.0.0.0:*               LISTEN      -

# turns out...... it was a host that was sending much data.
# Host/ Agent logs, is is pilling up and doing to much.

2024/01/11 00:49:27.024498 Detected performance counter with negative denominator the second time after retry, giving up...
2024/01/11 00:49:28.024616 Detected performance counter with negative denominator the second time after retry, giving up...
2024/01/11 00:49:29.025564 Detected performance counter with negative denominator the second time after retry, giving up...
2024/01/11 00:49:30.026362 Detected performance counter with negative denominator the second time after retry, giving up...
2024/01/11 00:49:27.024499 [101] cannot receive data from [ZABBIX-IP:10051]: Cannot read message: 'read tcp HOST-IP21:64868->ZABBIX-IP21:10051: i/o timeout'
2024/01/11 00:49:27.024500 [101] active check configuration update from host [HOST-IP-FQDN] started to fail

# Checked:
# Network Watcher | Traffic Analytics
# Traffic distrubution IP21:Checked Top 20 IPs with respect to network traffic flow count
# NSG hits: Checked: view analytics for NSG and NSG rules across your envornment units in Flows
# Total traffic

# Stopped Zabbix agent2 on the host..
# Better for 1.5 hours
# turns out...... it was also one more host that was sending much data.
# Stopped Zabbix agent2 on the other host..
# better for 2 hours an counting.....se after the night.
# It looks good in the morning (+ 7h) the last stopped agent was even started up again, and it seems stabil.
# Maybe just agent hang and in need of a restart, looks ok after starting it again.
# Os was upgraded some days before, kernel but that did not influence it.
# The agent was crazy, update the agent to new version.

# If you still see the same error, try to upgrade to agent new version, not agent2 new version.

# Last it was OF

```

Again

```bash
# Now it was AE that had the same error above, agent was upgraded. Will upgrade the rest of the list also

# on zabbix server the 
ss -ltn
# recv-q is full for :10051

```


## Environment requirements

* The more physical memory you have, the faster the database (and therefore Zabbix) works.
* CPU, Zabbix and especially Zabbix database may require significant CPU resources depending on number of monitored parameters and chosen database engine.

Examples of hardware configuration
The table provides examples of hardware configuration, assuming a Linux/BSD/Unix platform.

These are size and hardware configuration examples to start with. Each Zabbix installation is unique. Make sure to benchmark the performance of your Zabbix system in a staging or development environment, so that you can fully understand your requirements before deploying the Zabbix installation to its production environment.

![Requirements matrix ](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/environment.jpg)

1 1 metric = 1 item + 1 trigger + 1 graph
2 Example with Amazon general purpose EC2 instances, using ARM64 or x86_64 architecture, a proper instance type like Compute/Memory/Storage optimised should be selected during Zabbix installation evaluation and testing before installing in its production environment.

https://www.zabbix.com/documentation/current/en/manual/installation/requirements

## Zabbix Performance Tuning Best Practices

This README provides a comprehensive guide to optimizing your Zabbix environment for peak performance. Zabbix is a powerful monitoring solution, but its efficiency heavily depends on proper configuration and tuning, especially as your monitored infrastructure grows.


## Table of Contents

0.  [Short intro]
1.  [General Principles]
2.  [Triggers: When to Use What]
      * [Trigger Best Practices]
      * [Triggers to Avoid]
3.  [History vs. Trends: Data Storage Strategies]
4.  [zabbix\_server.conf Parameters for Tuning]
      * [Key Parameters]
      * [Database Tuning Considerations]
5.  [Hardware and OS Considerations]
6.  [Monitoring Zabbix's Own Performance]

-----

## 0\. Short intro

Number of values processed per second (NVPS)
* Update frequency greatly affects NVPS.

Zabbix is able to deliver 2 million of values per minute or around 30.000 of values per second

What affects performance?
* Type of items, value types, SNMPv3, number of triggers and complexity of triggers.
* Housekeeper settings and thus size of the database
* Number of users working with the WEB interface
* Choose update frequency and duration of storage carefully

History analysis affects performance of Zabbix. But not so much!
|                                 | Slow    | Fast
|---------------------------------| ------- |------
| DB Size                         | Large   | Fits into memory
| Low level detection             | Update freq, 30s, 15m, 30m | Update freq, 1h, 1d, 7d
| Trigger expressions             | min(), max(), avg() | last(), nodata()
| Data collection                 | Polling (SNMP, agent-less, passive agent) | Trapping (active agents)
| Data types                      | Text, string | Numeric

Common problems of initial setup
* Default database settings
* * Tune database for the best performance (https://github.com/hermanekt/Zabbix_MYSQL_tunned_for_40k)
* Not optimal configuration of Zabbix Server
* * Tune Zabbix Server configuration (Monitoring > Dashboard > Zabbix server health)
* Housekeeper settings do not match hardware spec
* * (Use partitions in DB) 
* Use of default templates
* * Make your own smarter templates
* Use of older releases
* * Always use the latest one!

"If it's up to 10 minutes, you can probably ignore that and tune the trigger to be less sensitive. If it's more, it is a general Zabbix DB performance issue."

https://stackoverflow.com/questions/40040509/zabbix-housekeeper-processes-more-than-75-busy

Tuning, what to check.

* When did it start (around new year or short time after? Wait a week)
* How long does it take, what was it before?
* How is general performance?
* Did the DB performance decline also?
* Did the DB grow?
* What is the DB size, should be flat after some time?
* What is the DB IO?
* tail -f zabbix_server.log and zabbix_agentd.log logs
* Check administration and queue?
* Check general and houskeeping settings?
* Has there been changes lately to templates or hosts?
* Num of users?
* What is num of Startpoller?
* Has new values per seconds increased?
* Can you reduce new values per second`?
* Use less min, avg, max more last and nodata.
* For history use smallets days possible, not default 90, 45, 14 or even 7.
* Better to keep trend for longer times, example, history 14 days, trends 1 year.
* Can we live with this?


## 1\. General Principles

  * **Start Simple:** Avoid over-engineering templates and configurations initially. Begin with default settings and tune only when performance issues or specific monitoring needs arise.
  * **Modular Templates:** Design templates to monitor single resources or inseparable sets of resources. Use "Profile" or "Meta" templates to link multiple resource templates to a host.
  * **User Macros:** Utilize user macros for thresholds and frequently changing values within templates. This allows for easy tuning and customization without modifying the core template.
  * **Dependent Items:** Wherever possible, use dependent items. A master item collects a large dataset (e.g., JSON, XML, or database query), and dependent items extract specific values from that master item. This reduces the number of requests to the monitored host.
  * **Proxies:** For larger, distributed, or remote environments, deploy Zabbix proxies. Proxies collect data locally and forward it to the Zabbix server, significantly reducing network load and improving scalability.
  * **Database is Key:** Zabbix is highly database-dependent. Optimize your database engine (MySQL/MariaDB, PostgreSQL) as a top priority.
  * **Monitor Zabbix Itself:** Implement monitoring for your Zabbix server and proxies using the built-in "Zabbix internal process performance" items. This provides crucial insights into bottlenecks.

-----

## 2\. Triggers: When to Use What

Triggers are the core of Zabbix's alerting. Well-designed triggers prevent alert fatigue and ensure you're notified of critical issues.

### Trigger Best Practices

  * **Clarity and Readability:**
      * Use clear, concise trigger names. For LLD objects, prefix the trigger name with the LLD object (e.g., `CPU: High Utilization`).
      * Avoid using `{HOST.NAME}` or `{ITEM.LASTVALUE}` in trigger names directly; use the event name field for more detailed problem descriptions (Zabbix 5.2+).
      * Use newlines and spaces to make complex trigger expressions readable.
      * Always use time suffixes (e.g., `1m`, `5m`, `1d`) and size suffixes (e.g., `1K`, `1B`, `1G`) for better readability.
  * **Flap Resistance:** Avoid triggers that rely solely on the last value, as this can lead to frequent flapping. Instead, check values over a period (e.g., `avg(5m)`).
  * **Severity Levels:** Assign appropriate severity levels to triggers.
      * **Not classified:** Generally not used.
      * **Information:** Events that are not alarms but provide useful audit or retrospective data (e.g., user logged in).
      * **Warning:** Minor issues that could escalate if ignored (e.g., disk usage low but still room).
      * **Average:** Significant performance problems or service degradation (e.g., high CPU, low memory, website slow).
      * **High:** Key service unavailable or device not functioning (e.g., no ICMP ping, website down).
      * **Disaster:** Critical blackouts, global service failures (e.g., entire data center down). Reserve this for severe, business-impacting issues.
  * **Trigger Tags:** Utilize trigger tags to logically group and filter alerts (e.g., `scope:performance`, `scope:availability`, `category:network`). This aids in reporting and notification routing.
  * **User Macros for Thresholds:** Define thresholds using user macros (e.g., `{$CPU_UTIL_HIGH}`). This makes it easy to adjust thresholds without editing the trigger expression directly.
  * **Problem Description:** Use the trigger description field to elaborate on the problem, its potential root causes, and suggested actions.
  * **Healthchecks and Discrete States:**
      * For health check metrics that return integer states, use value mappings for clarity.
      * Consider `Discard unchanged with heartbeat` preprocessing for discrete states or inventory data that changes infrequently. This reduces database load by only storing changes.

### Triggers to Avoid

  * **Overly Complex Expressions:** While some complexity is necessary, avoid excessively convoluted trigger expressions unless absolutely required, as they can be harder to troubleshoot and consume more resources.
  * **Excessive Flapping:** Triggers that constantly switch between OK and PROBLEM states indicate an issue with the trigger logic or a highly unstable monitored item. Refine the expression (e.g., using `avg()` over a longer period, adding hysteresis) to prevent this.
  * **Too Many Disaster Triggers:** Reserve "Disaster" severity for truly catastrophic events. Overusing it can lead to alert fatigue and desensitize responders.
  * **Dependencies Across Templates (Prefer Tags):** Instead of trigger dependencies across different templates, use event tags and global correlation for managing related alerts.
  * **Monitoring "Everything":** Resist the urge to enable every single item and trigger available in a template. Focus on critical metrics relevant to your operational needs to reduce data volume and processing overhead.

-----

## 3\. History vs. Trends: Data Storage Strategies

Zabbix stores collected data in two ways: **history** and **trends**. Understanding their differences is crucial for efficient database management.

  * **History:**

      * Stores **each individual collected value**.
      * Provides high granularity for recent data.
      * Used for detailed graphs and trigger evaluations for shorter time periods.
      * **Best Practice:** Keep history for the **smallest possible number of days** required for immediate troubleshooting and short-term analysis (e.g., 7-14 days). This minimizes database size and I/O load.
      * Triggers heavily rely on history data. If history is set to '0', only the last value is stored, and most trigger functions will not work.

  * **Trends:**

      * Stores **hourly aggregated data** (minimum, maximum, average, and count of values for each hour).
      * Provides data reduction for long-term analysis.
      * Used for displaying data in graphs over longer time periods (typically when the graph period exceeds the history retention).
      * **Best Practice:** Keep trends for much **longer periods** than history (e.g., 1-5 years). This allows for long-term capacity planning and historical reporting without storing every single raw data point.
      * Trends do not directly participate in trigger evaluation.

**General Rule:**

  * For **short-term, high-resolution data** (e.g., troubleshooting an issue that occurred an hour ago), use **History**.
  * For **long-term analysis and capacity planning** (e.g., showing CPU utilization over the last year), use **Trends**.

**Example Strategy:**

  * **History:** 7-14 days (for numerical data)
  * **Trends:** 365-1825 days (1-5 years)

**Important Note:** Non-numeric data (logs, text) is only stored in history, so consider its retention period carefully if you need to keep it for longer.

-----

## 4\. zabbix\_server.conf Parameters for Tuning

The `zabbix_server.conf` file is central to Zabbix server performance. Adjusting these parameters requires careful consideration of your environment's workload and available resources.

**Before you begin:**

  * **Monitor Zabbix's internal processes:** Use `zabbix[process,<type>,<mode>,<state>]` items to understand where bottlenecks lie (e.g., `zabbix[process,poller,avg,busy]` for poller utilization).
  * **Start small and iterate:** Change one or two parameters at a time and monitor the impact before making further adjustments.
  * **Restart Zabbix server:** Most changes to `zabbix_server.conf` require a server restart to take effect.

### Key Parameters

  * **`StartPollers`**: Number of pre-forked instances of pollers.
      * **Purpose:** Collects data from Zabbix agents (active/passive), SNMP, JMX, etc.
      * **Tuning:** Increase if `zabbix[process,poller,avg,busy]` shows high utilization (above 50-60%) or if the Zabbix queue has many delayed items.
      * **Guideline:** Start with a value that ensures your queue (`Administration -> Queue`) is generally empty. Don't set it excessively high, as each poller consumes resources.
  * **`StartPollersUnreachable`**: Number of pre-forked instances of pollers for unreachable hosts.
      * **Purpose:** Handles data collection for hosts that are currently unreachable.
      * **Tuning:** Adjust if you have many hosts that frequently go offline or if `zabbix[process,unreachable poller,avg,busy]` is high.
  * **`StartTrappers`**: Number of pre-forked instances of trappers.
      * **Purpose:** Processes incoming data from Zabbix sender, active agents, and active proxies.
      * **Tuning:** Increase if you send a large volume of data via Zabbix sender or if you have many active agents/proxies. High `zabbix[process,trapper,avg,busy]` indicates a need for more trappers.
  * **`StartDBSyncers`**: Number of pre-forked instances of history syncers.
      * **Purpose:** Writes collected history and trend data from internal caches to the database. **Crucial for database write performance.**
      * **Tuning:** This is often a bottleneck. Increase if `History write cache` or `Trends write cache` (from Zabbix internal checks) are consistently growing, or `zabbix[process,history syncer,avg,busy]` is high. This parameter is highly dependent on your database's write performance.
  * **`CacheSize`**: Size of the configuration cache in bytes.
      * **Purpose:** Stores Zabbix configuration (hosts, items, triggers, etc.) in memory for faster access.
      * **Tuning:** Increase if `zabbix[cache,buffer,pfree,configuration]` is consistently low (e.g., below 20%) or if the Zabbix server log shows "configuration cache is too small" warnings. Ensure you have enough RAM.
  * **`HistoryCacheSize`**: Size of the history cache in bytes.
      * **Purpose:** Stores collected history values before they are written to the database by DBSyncers.
      * **Tuning:** Increase if `zabbix[cache,buffer,pfree,history]` is low or `History write cache` is consistently high. This is crucial for handling bursts of incoming data without overwhelming the database.
  * **`HistoryIndexCacheSize`**: Size of the history index cache in bytes.
      * **Purpose:** Indexes the history cache for faster lookup. Typically 1/4th the size of `HistoryCacheSize`.
      * **Tuning:** Increase proportionally with `HistoryCacheSize`.
  * **`ValueCacheSize`**: Size of the value cache in bytes.
      * **Purpose:** Caches item values, especially those used in calculated items, triggers, and trend functions.
      * **Tuning:** Increase if `zabbix[cache,buffer,pfree,values]` is low. Relevant if you have many calculated items or complex trigger expressions.
  * **`LogFileSize`** and **`LogFile`**:
      * **Purpose:** Defines the size and location of the Zabbix server log file.
      * **Tuning:** Monitor log size, ensure sufficient disk space.
  * **`DebugLevel`**:
      * **Purpose:** Specifies the logging verbosity.
      * **Tuning:** Set to `3` for normal operations (warnings, errors). Set to `4` (debug) only for troubleshooting, as it generates a large volume of logs.

### Database Tuning Considerations

The database is often the primary bottleneck in Zabbix.

  * **Hardware:** Fast storage (SSD/NVMe), ample RAM, and a powerful CPU are essential.
  * **Database Engine:** MySQL/MariaDB with InnoDB engine or PostgreSQL are highly recommended. InnoDB offers better concurrency than MyISAM.
  * **Partitioning:** For large installations, implement database partitioning for history and trends tables. This significantly improves housekeeping and query performance by breaking large tables into smaller, more manageable segments.
  * **InnoDB Buffer Pool Size (MySQL/MariaDB):** This is critical. Allocate a significant portion of your available RAM to `innodb_buffer_pool_size`. It should be large enough to hold frequently accessed data and indexes.
  * **`max_connections` (MySQL/MariaDB):** Ensure this is high enough to accommodate all Zabbix processes and other database connections.
  * **`innodb_flush_log_at_trx_commit` (MySQL/MariaDB):** For performance, consider setting to `2` or `0` (at the risk of minor data loss in case of a crash). For strict data integrity, `1` is the safest.
  * **Housekeeping:** Zabbix's internal housekeeper process cleans old data.
      * **Enable Housekeeping:** Ensure `Housekeeping` is enabled in Zabbix Administration -\> General -\> Housekeeping.
      * **Frequency:** Adjust the `HousekeepingFrequency` in `zabbix_server.conf` (default is 1 hour).
      * **Overriding Housekeeping:** For very large installations, consider disabling Zabbix's internal housekeeper and implementing external database partitioning with a custom cleanup script.

-----

## 5\. Hardware and OS Considerations

  * **CPU:** Use the fastest processor available.
  * **Memory (RAM):** More memory is always better. Zabbix caches extensively. Allocate ample RAM to the Zabbix server and especially the database server.
  * **Storage:** Fast storage (SSDs or NVMe) is paramount for database performance. RAID configurations (e.g., RAID 10) are recommended for both performance and redundancy.
  * **Network:** Fast Ethernet adapters and a robust network infrastructure are essential for data collection.
  * **Operating System:**
      * Use a stable, up-to-date Linux distribution.
      * Tune kernel parameters (e.g., `net.core.somaxconn`, `fs.file-max`, `vm.swappiness`).
      * Increase open file descriptor limits for the Zabbix user.
      * Disable unnecessary services.

-----

## 6\. Monitoring Zabbix's Own Performance

Zabbix provides excellent internal checks to monitor its own performance. These are crucial for identifying bottlenecks and guiding your tuning efforts.

**Key Internal Zabbix Items to Monitor:**

  * `zabbix[wcache,free]` / `zabbix[wcache,pfree,<cache>]`: Percentage of free cache memory.
  * `zabbix[queue,avg]` / `zabbix[queue,max]` / `zabbix[queue,last]` / `zabbix[queue,<sec>]`: Number of items in the queue delayed by a certain amount of time. A consistently growing queue indicates a bottleneck.
  * `zabbix[process,<type>,<mode>,<state>]`: Monitor the busy percentage of different Zabbix processes (e.g., `poller`, `trapper`, `history syncer`, `discoverer`, `escalator`, `alerter`). High busy percentages (e.g., \>60-70%) indicate a need to increase the number of those processes in `zabbix_server.conf`.
  * `zabbix[items_unsupported]` / `zabbix[hosts_unavailable]` / `zabbix[hosts_unreachable]`: Monitor the health of your Zabbix environment.

By regularly monitoring these internal metrics, you can make informed decisions about tuning your Zabbix server and ensure its optimal performance.
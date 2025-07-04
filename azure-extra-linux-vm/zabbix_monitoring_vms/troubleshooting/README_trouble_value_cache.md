# Value Cache Hits low

In Zabbix, the **Value Cache** is an internal mechanism used to improve the performance of the Zabbix server by caching item values in memory. This feature is particularly useful in large-scale Zabbix deployments where frequent access to historical data or trend data is required, as it reduces the load on the database and speeds up data retrieval.



### Issue

Every night at around 01:00, inbound flows are high also, like flodding port 100051 or 10050.

* It could be an zabbix agent on a server
* It could be something with zabbix server tuning
* Since cache hits are low, zabbix need to get more data from the database to calculate

![Value cache ](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/value_cache_hits.png)


Configuration tuning

- [Go to fix in progress](#fix-in-progress)


### Key Details About Zabbix Value Cache

1. **Purpose**:
   - The value cache stores recently collected monitoring data (item values) in the Zabbix server's memory.
   - It is primarily used to optimize performance for operations that require quick access to item values, such as:
     - Trigger evaluations.
     - Calculated items.
     - Aggregate calculations (e.g., trends, graphs, and reports).
     - Low-level discovery (LLD) rules.

2. **How It Works**:
   - When a new value is collected for an item, it is stored in the value cache in memory.
   - The Zabbix server can then retrieve values from the cache instead of querying the database, which is much faster.
   - The cache operates on a **least recently used (LRU)** principle, meaning that older or less frequently accessed data is removed from the cache to make room for new data when the cache reaches its size limit.

3. **Configuration**:
   - The value cache is enabled by default in Zabbix, but its behavior can be tuned via the Zabbix server configuration file (`zabbix_server.conf`).
   - Key configuration parameter:
     - **`ValueCacheSize`**: Specifies the amount of memory (in bytes) allocated for the value cache. For example:
       ```
       ValueCacheSize=64M
       ```
       The default value is 8 MB, but it can be increased for larger environments to improve performance. The size should be adjusted based on the number of items, the frequency of data collection, and available server memory.

4. **Modes of Operation**:
   The value cache can operate in two modes, depending on the configuration and needs:
   - **Normal Mode**: The cache stores item values and retrieves them as needed. If a value is not found in the cache, Zabbix queries the database.
   - **Low Memory Mode**: If the value cache runs out of memory (e.g., due to insufficient `ValueCacheSize`), Zabbix switches to low memory mode. In this mode, the cache is disabled, and all data is retrieved directly from the database, which can degrade performance.

5. **Monitoring Value Cache**:
   - Zabbix provides internal items to monitor the performance and status of the value cache, such as:
     - `zabbix[vcache,buffer,<parameter>]`: Monitors the value cache buffer usage (e.g., free space, used space, etc.).
     - `zabbix[vcache,cache,<parameter>]`: Monitors cache hits, misses, and mode (normal or low memory).
   - These metrics help administrators tune the `ValueCacheSize` and ensure optimal performance.

6. **When to Use a Larger Value Cache**:
   - If you have a large number of items (e.g., thousands or tens of thousands) and frequent trigger evaluations or calculations.
   - If you notice high database load or frequent cache misses (visible in the internal monitoring items).
   - If you are using features like trends, calculated items, or aggregate functions extensively.

7. **Best Practices**:
   - Monitor the value cache usage regularly using Zabbix internal items to ensure it is not running out of memory.
   - Adjust `ValueCacheSize` based on your environment's needs, but avoid setting it too high, as it consumes server RAM.
   - Ensure your Zabbix server has sufficient physical memory to accommodate the value cache and other processes.

### Example Scenario
Suppose you have a Zabbix setup monitoring 10,000 items, with data collected every minute, and many triggers and calculated items. Without the value cache, each trigger evaluation or calculation might require a database query, leading to high database load and slower performance. By enabling and properly sizing the value cache, Zabbix can retrieve most values directly from memory, significantly reducing database load and improving response times.

### Conclusion
The Zabbix value cache is a critical performance optimization feature for large-scale monitoring environments. Properly configuring and monitoring the value cache ensures efficient data retrieval, reduced database load, and improved overall system performance.

## Why is value cache suddenly low?

If the Zabbix value cache is suddenly running low (e.g., switching to low memory mode or showing a high number of cache misses), it indicates that the cache is unable to store all the necessary item values in memory, forcing Zabbix to query the database more frequently. This can degrade performance and increase database load. Below are the potential reasons for this issue and steps to diagnose and resolve it:

---

### Potential Reasons for Low Value Cache

1. **Insufficient `ValueCacheSize`**:
   - The most common reason is that the `ValueCacheSize` parameter in the Zabbix server configuration file (`zabbix_server.conf`) is set too low for your environment.
   - If the number of monitored items, frequency of data collection, or usage of triggers/calculated items has increased, the current cache size may no longer be sufficient to hold all the required data in memory.

2. **Increased Monitoring Load**:
   - If you have recently added more hosts, items, or triggers, or reduced item update intervals (e.g., collecting data more frequently), the amount of data Zabbix needs to cache may have increased significantly.
   - This can cause the value cache to fill up faster, leading to more cache evictions (based on the LRU principle) and cache misses.

3. **High Usage of Calculated Items or Triggers**:
   - Calculated items, aggregate functions, and complex triggers often require access to historical data or recent values for multiple items. If their usage has increased, the value cache may be under additional pressure to store more data.
   - For example, if a trigger references the last 10 values of an item, the cache needs to store all 10 values for that item, increasing memory demand.

4. **Low-Level Discovery (LLD) Rules**:
   - LLD rules can generate a large number of items dynamically. If you have recently added or modified LLD rules, the number of monitored items may have spiked, increasing the demand on the value cache.

5. **Server Memory Constraints**:
   - If the Zabbix server is running low on physical RAM, the operating system may limit the amount of memory available to the Zabbix server process, indirectly affecting the value cache.
   - This can happen if other processes on the server are consuming excessive memory or if the server is under-provisioned for the workload.

6. **Cache Misses Due to Data Retention**:
   - The value cache is designed to store recent data. If your triggers or calculations frequently reference older data that is no longer in the cache (e.g., data beyond the cache's capacity), it will result in cache misses and database queries.
   - This can happen if you have long periods in trigger expressions (e.g., referencing data from hours or days ago) or if the cache size is too small to retain enough historical data.

7. **Zabbix Server Restart or Configuration Change**:
   - If the Zabbix server was recently restarted, the value cache starts empty and needs time to populate with data. During this period, you may notice low cache efficiency (more misses) until the cache stabilizes.
   - Similarly, if you recently reduced the `ValueCacheSize` or made other configuration changes, it could lead to insufficient cache capacity.

8. **Software Bugs or Misconfiguration**:
   - In rare cases, a bug in the Zabbix server or a misconfiguration (e.g., incorrect database settings, corrupted cache, etc.) could cause unexpected behavior in the value cache.

---

### How to Diagnose the Issue

To identify the root cause of the low value cache, you can use Zabbix's internal monitoring items and logs. Follow these steps:

1. **Check Value Cache Metrics**:
   - Use the following Zabbix internal items to monitor the value cache:
     - `zabbix[vcache,buffer,free]`: Amount of free memory in the value cache (in bytes).
     - `zabbix[vcache,buffer,used]`: Amount of used memory in the value cache (in bytes).
     - `zabbix[vcache,buffer,total]`: Total size of the value cache (should match `ValueCacheSize`).
     - `zabbix[vcache,cache,hits]`: Number of times a value was found in the cache (cache hits).
     - `zabbix[vcache,cache,misses]`: Number of times a value was not found in the cache (cache misses).
     - `zabbix[vcache,cache,mode]`: Current mode of the value cache (0 = normal, 1 = low memory mode).
   - If `zabbix[vcache,buffer,free]` is consistently low or zero, and `zabbix[vcache,cache,mode]` is 1 (low memory mode), the cache size is insufficient.
   - A high number of `zabbix[vcache,cache,misses]` compared to `hits` indicates that the cache is not effective, likely due to insufficient size or excessive data retention needs.

2. **Check Zabbix Server Logs**:
   - Look for warnings or errors in the Zabbix server log file (e.g., `/var/log/zabbix/zabbix_server.log`) related to the value cache.
   - Common messages to look for:
     - `WARNING: Value cache is working in low memory mode`
     - `WARNING: Value cache is full`
   - These messages indicate that the cache size needs to be increased.

3. **Analyze Monitoring Load**:
   - Check the number of monitored items, hosts, and triggers in your Zabbix setup:
     - Use the Zabbix frontend (e.g., under *Administration > General > Housekeeping*) or database queries to count the number of items and their update intervals.
     - Example SQL query to count active items:
       ```sql
       SELECT COUNT(*) FROM items WHERE status=0;
       ```
   - If the number of items or the data collection frequency has increased significantly, this could explain the increased demand on the value cache.

4. **Check Server Memory Usage**:
   - Use system tools like `top`, `htop`, or `free -m` to check the overall memory usage on the Zabbix server.
   - Ensure that the server has enough free RAM to accommodate the Zabbix server process, including the value cache and other components (e.g., history cache, trend cache).

5. **Review Trigger and Calculated Item Usage**:
   - Check if there are triggers or calculated items that reference large amounts of historical data (e.g., `last(#10)`, `avg(1h)`, etc.).
   - These expressions can increase the demand on the value cache, especially if they are used extensively.

---

### How to Resolve the Issue

Based on your diagnosis, take the appropriate steps to address the low value cache:

1. **Increase `ValueCacheSize`**:
   - Edit the Zabbix server configuration file (`zabbix_server.conf`) and increase the `ValueCacheSize` parameter. For example:
     ```
     ValueCacheSize=128M
     ```
   - Restart the Zabbix server to apply the change:
     ```
     systemctl restart zabbix-server
     ```
   - Recommended sizing:
     - Small environments (<1,000 items): 8M–32M
     - Medium environments (1,000–10,000 items): 32M–128M
     - Large environments (>10,000 items): 128M–1G or more
   - Monitor the cache metrics after the change to ensure the issue is resolved.

2. **Optimize Monitoring Load**:
   - Review your monitoring setup to reduce unnecessary load:
     - Increase update intervals for items that do not require frequent updates (e.g., change from 30 seconds to 1 minute).
     - Disable unused items, hosts, or triggers.
     - Limit the use of LLD rules that generate excessive items.
   - This will reduce the amount of data Zabbix needs to cache.

3. **Optimize Triggers and Calculated Items**:
   - Reduce the use of triggers or calculated items that reference large amounts of historical data (e.g., use `last(#3)` instead of `last(#10)` if possible).
   - Avoid using long time periods in functions like `avg(1h)` unless absolutely necessary.

4. **Increase Server Memory**:
   - If the Zabbix server is running low on RAM, consider adding more physical memory to the server or moving Zabbix to a more powerful machine.
   - Ensure that other processes on the server (e.g., database, web server) are not consuming excessive memory.

5. **Tune Data Retention**:
   - If triggers or calculations frequently reference older data, consider increasing the history or trend retention period in the Zabbix database (configured under *Administration > General > Housekeeping*). This ensures that the database retains the necessary data, but it may not directly solve cache issues.
   - Alternatively, increase the `ValueCacheSize` to store more historical data in memory.

6. **Monitor and Test**:
   - After making changes, monitor the value cache metrics (`zabbix[vcache,...]`) to ensure that the cache is operating in normal mode (mode = 0) and that cache misses are minimized.
   - Create a dashboard or trigger to alert you if the cache enters low memory mode again.

7. **Upgrade Zabbix (if applicable)**:
   - If you are running an older version of Zabbix, consider upgrading to the latest stable release. Newer versions often include performance improvements and better cache management.

---


## Fix in progress

Question:

In zabbix 6.0.40. In Zabbix, the Value Cache is an internal mechanism used to improve the performance of the Zabbix server by caching item values in memory. This feature is particularly useful in large-scale Zabbix deployments where frequent access to historical data or trend data is required, as it reduces the load on the database and speeds up data retrieval. We are seeing many low hits for value cache? Why is that?

We have 6500 items and 3000 trigger, and ValueCacheSize=128M

CacheUpdateFrequency=60 is this ok?

ValueCacheTTL not found

Answer:

If you cannot find the ValueCacheTTL parameter in your zabbix_server.conf file, it's possible that this parameter was introduced or renamed in a later version of Zabbix, or it might not exist at all. As of Zabbix 6.0, there isn't a parameter explicitly named ValueCacheTTL in the official documentation.

in Zabbix 6.0.40, there is no ValueCacheTTL parameter. So how long does the cache live?

In Zabbix 6.0.40, the Value Cache does not have an explicit ValueCacheTTL parameter to define how long an item value lives in the cache. Instead, the lifetime of cached values is managed internally by the Zabbix server based on several factors, including cache size, update frequency, and data access patterns. Here's how the Value Cache lifetime is determined:

Conclusion
In Zabbix 6.0.40, the lifetime of cached values in the Value Cache is managed internally based on cache size, update frequency, and data access patterns. By adjusting parameters such as ValueCacheSize, CacheUpdateFrequency, and monitoring cache performance, you can optimise the Value Cache to improve the performance of your Zabbix server.

Question:
How about cachesize?

Answer:

The CacheSize parameter in Zabbix controls the total amount of memory (in bytes) allocated for all in-memory caches, 
including the Value Cache, History Cache, and Trend Cache. 
Properly configuring CacheSize is crucial for optimising the performance of your Zabbix server, especially in large-scale deployments.

Here is a comprehensive example configuration for zabbix_server.conf that optimises the cache settings for a setup with 6500 items and 3000 triggers:

```ini
CacheSize=512M
ValueCacheSize=256M
HistoryCacheSize=128M
TrendCacheSize=64M
CacheUpdateFrequency=60
StartValueCacheSize=128M

LogLevel=4 / or 3 depends what you want to see
```

Check after the weekend, hm still low.

![VCH low](https://github.com/spawnmarvel/linux-and-azure/blob/main/images/zabbix_01.jpg)

Next step, is it db backup on microsoft?
Search microsoft for azure mysql backup information.

### Fix 1 after initial fix

1. Understand What Low Value Cache Hit Rate Means

The value cache is designed to store the most recent item values in memory so Zabbix doesn’t have to query the database repeatedly. A low hit rate means:

* Zabbix is querying the database too often → increased load
* Performance drops, especially during evaluation of triggers


### Refined Configuration for Zabbix 6.0.40


Use these internal checks (available since Zabbix 5.0+) to evaluate real-world cache behavior:

| Metric                             | Description                                 |
|-----------------------------------|---------------------------------------------|
| `zabbix[cache,value]`             | Current size of Value Cache                 |
| `zabbix[cache,value,hits]`        | Number of cache hits per second             |
| `zabbix[cache,value,misses]`      | Number of cache misses per second           |
| `zabbix[cache,value,size]`        | Max allowed size (should match ValueCacheSize) |
| `zabbix[cache,value,utilization]` | Percentage used                             |


Hit ratio = (hits / (hits + misses)) * 100

Target: Keep hit ratio above 90%. If below 70–80%, increase ValueCacheSize or investigate frequent short-polling items.

Test our old config, it is good:

* 3h avg: (364.77 / (365.77 + 0.0014)) = 0.99999 * 100 = 99.9

Disable this:

Trigger name a name max(item.insidentcount, 336h)>=1

### Fix 2 Check MySql and network TBD


Mysql ?

Network and port flooding?


### Fix 3 Cache is 99.99

Q: 
zabbix value cache formula Hit ratio = (hits / (hits + misses)) * 100. We have check and we get 99.99, but still hits change from 400 vps to 200 vps from time to time, what more to check?

A:
If your **Zabbix Value Cache hit ratio is 99.99%** but the **hits per second (VPS) fluctuate between 200 and 400**, this suggests that while the cache is highly efficient, there may still be underlying performance issues. Here’s what to investigate further:

---

### **1. Check Cache Size vs. Usage**
Run:
```bash
zabbix_server -c /etc/zabbix/zabbix_server.conf -R diaginfo=valuecache

# zabbix_server: This is the Zabbix server daemon.
# -c /etc/zabbix/zabbix_server.conf: Specifies the configuration file to use.
# -R diaginfo=valuecache: This is a runtime control command that tells the Zabbix server to return diagnostic information about the value cache.

```
- **If `used` is close to `ValueCacheSize` (e.g., 95%+):**
  - The cache is **nearly full**, causing occasional evictions.
  - **Solution:** Increase `ValueCacheSize` (e.g., from `512M` to `768M`).

- **If `used` is low (e.g., <50%):**
  - The cache is **underutilized**, but something else is causing fluctuations.
  - **Check:** Database bottlenecks or poller delays.

---

We have: or view zabbix_diagnostics.txt in this folder

```ini

Items:3295 values:57279 mode:0 time:0.000965
Memory:
  size: free:266518696 used:1689944
  chunks: free:456 used:13697 min:24 max:266385648
  buckets:
      24:26
      32:91
      48:53
      56:3
      64:1
      96:1
      112:9
      128:3
      176:2
      192:4
      256+:263
Top.values:
  itemid:60581 values:1734 request.values:1682

[...]


```

From your diaginfo=valuecache output, here's the analysis and recommended actions:

1. Cache Usage

Total Size: 266,518,696 bytes (~254MB)
Used: 1,689,944 bytes (~1.6MB)
Free: 266,518,696 bytes (~254MB)
Utilization: ~0.63% (extremely low)

2. Items vs. Values
Items: 3,295
Values: 57,279
Ratio: ~17 values per item (normal for active monitoring)
3. Performance
Time: 0.000965s (very fast response)

### **2. Monitor Database Performance** TBD
#### **A. Check Slow Queries**
- **MySQL:**
  ```sql
  SHOW GLOBAL STATUS LIKE 'Slow_queries';
  SET GLOBAL slow_query_log = 'ON';
  SET GLOBAL long_query_time = 1;  # Log queries slower than 1s
  ```

This ok, no slow querys

#### **B. Check Database Cache Hit Ratio**
- **MySQL:**
  ```sql
  SHOW GLOBAL STATUS LIKE 'Innodb_buffer_pool_read%';
  ```
  - **Buffer pool hit ratio** should be **>99%**.

---


![Innodb read and reads](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/azure_mysql.jpg)

Based on your **InnoDB buffer pool metrics**, here's the analysis and action plan to optimize Zabbix performance:

### **Key Metrics Analysis**
| Metric | Value | Interpretation |
|--------|-------|----------------|
| **Innodb_buffer_pool_reads** | 60 (avg) | **Physical disk reads per second** (should be as low as possible) |
| **Innodb_buffer_pool_read_requests** | 1.5M | **Logical read requests** (high, but expected for Zabbix) |

#### **Buffer Pool Hit Ratio Calculation**
```
Hit Ratio = (1 - (Innodb_buffer_pool_reads / Innodb_buffer_pool_read_requests)) * 100
          = (1 - (60 / 1,500,000)) * 100
          = ~99.996% (excellent)
```
- **Your buffer pool is highly efficient** (99.996% hit ratio).
- **But 60 disk reads/sec is still too high** for optimal Zabbix performance.

---

### **Root Cause & Solutions**
#### **1. Database Bottleneck (Most Likely)**
- **Issue:** Even with a 99.99% hit ratio, **60 disk reads/sec** can cause latency.
- **Solutions:**
  - **Increase `innodb_buffer_pool_size`** (if <70% of RAM):
    ```ini
    innodb_buffer_pool_size = 8G  # Set to 70-80% of available RAM
    ```
We have innodb_buffer_pool_size= 12884901888 (12.5GB), Ram on DBAS is General Purpose, D4ds_v4, 4 vCores, 16 GiB RAM, 100 storage, 600 IOPS

### **1. Database Optimization (Critical)**

Given your **`innodb_buffer_pool_size=12884901888`** (≈12.5GB), here’s the optimized action plan for your Zabbix 6.0.40 setup:


#### **A. Verify Buffer Pool Efficiency**
Run these MySQL queries to confirm performance:
```sql
-- Check current buffer pool usage
SHOW ENGINE INNODB STATUS\G
-- Look for "BUFFER POOL AND MEMORY" section.

-- Check hit ratio (should be >99.9%)
SELECT (1 - (SELECT variable_value FROM performance_schema.global_status
            WHERE variable_name = 'Innodb_buffer_pool_reads') /
            (SELECT variable_value FROM performance_schema.global_status
            WHERE variable_name = 'Innodb_buffer_pool_read_requests')) * 100 AS hit_ratio;
```

#### **B. Adjust `innodb_buffer_pool_instances`**
For 12.5GB buffer pool, set:
```ini
innodb_buffer_pool_instances=8  # 1 instance per 1.5GB (12.5GB/8)
```
*This reduces contention in multi-core systems.*

#### **C. Optimize InnoDB Settings**
Add to `my.cnf` or edit in azure:
```ini
innodb_flush_log_at_trx_commit=2  # Slightly less durable, but faster
innodb_io_capacity=2000           # For SSD storage
innodb_io_capacity_max=4000
```

Settings current:

```ini
innodb_io_capacity=200           
innodb_io_capacity_max=2000
```

![Innodb settings ](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/innodb.jpg)

Current Issue:

* innodb_io_capacity=200 is too low for modern SSDs (default is 200 for HDDs).
* innodb_io_capacity_max=2000 is reasonable but could be higher for burst handling.

Why?

* SSDs can handle much higher I/O rates (200 is for spinning disks).
* Zabbix benefits from faster flushing (reduces latency).

innodb_io_capacity – set this to as many write iops as your disk subsystem can handle. For SSDs this should be at least a few thousand (2000 could be a good start) while for rotating disks somewhat lower values – 500-800, depending on the number of bearing disks, will do. Best to benchmark disks or do the math for actual numbers, but default of 200 is definitely too low for most systems nowadays.


We change to:
```ini
innodb_io_capacity=400
innodb_io_capacity_max=4000
```

Bck assumed time Azure Database for MySQL Flexible server backup is managed by Azure itself (PAAS) hence duration we can't see. Start time is  '2025-05-13 04:30 UTC'. Retention  :- 24 hours. 

13.05.2025 09:10

Trigger added:

last(/Zabbix server/zabbix[vcache,cache,hits])<200

Trigger disabled (from above):

Trigger name a name max(item.insidentcount, 336h)>=1

Check after that?????

Now it is stabile, 16.05.2025 10:55.

We see value cache hits low on

* 01:00 to 03:00 each night, one big dip
* 04:00 to 04:10, small dips
* 06:00 to 06:10, small dips

We change to:
at date 26.05.2025 12:30?

```ini
innodb_io_capacity=400
innodb_io_capacity_max=4000
```

### Go to monitor innodb

Check Mysql for same pattern.


View 1 Low cache hits and Low network out mysql.png

Go to https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/troubleshooting/README_innodb.md

We change to:
at date 26.05.2025 12:30?

```ini
innodb_io_capacity=600
innodb_io_capacity_max=4000
```

We still see some value cache misses around 200 2.4 times during the day. What to look for next`?

How is the relationship?

* Value Cache Miss: This happens when Zabbix needs a historical value (for a trigger, calculated item, etc.) and it's not found in the in-memory Value Cache
* innodb_io_capacity & innodb_io_capacity_max: These settings control how aggressively InnoDB performs background I/O operations, primarily flushing dirty pages from the buffer pool to disk and merging changes from the change buffer. They aim to keep up with I/O demand without overwhelming the storage system.

Key Point: innodb_io_capacity settings do NOT influence whether a Value Cache miss occurs. They influence how quickly the database can respond when a miss does occur (and during regular history writing, housekeeping, etc.).

Having good innodb_io_capacity settings means your database should be able to handle the extra queries generated by cache misses (and general load) more efficiently. But it won't prevent the misses themselves.

***Why Are You Still Seeing Misses?***

Data Age / Trigger Function Timeframes:
Do you have triggers that look back a significant amount of time? Examples:
* avg(/Host/item.key,1h) - Needs 1 hour of data.
* min(/Host/item.key,#10) - Needs the last 10 values. If items update slowly, this could be a long time.
* nodata(30m) - Needs to check if any data exists in the last 30 minutes.

(If a trigger needs data older than what's currently held in the Value Cache (because it's been pushed out by newer data), it will result in a cache miss. 200 misses might simply be these long-lookback triggers firing.)

* Your innodb_io_capacity settings are good for handling the misses, not preventing them. 
* The most likely reason for your (few) misses is triggers needing data older than what's in the cache. 
* Focus your investigation on trigger functions and their timeframes, correlating them with the times you observe the misses.


Action: Identify which triggers are being evaluated around the times you see the misses. Check their functions and the time periods they cover.

Time for misses last 7 days

* 21 05 2025, 07:08
* 22 05 2025, 06:44
* 22 05 2025, 17.26
* 25 05 2025, 18:26
* 26 05 2025, 15:30 - 16:00 self fixed
* 27 05 2025, 01:00 - 01:45 and 06:10 - 07:00 and 18:00 - 19:30
* 28 05 2025, 01:00 - 02:30 
Added trigger Value cache misses high > 200

When do it fire again? Check triggers from above.


trendavg(/Goodtech Log Agent Alarms And Events/SafetyOverview.json.InsidentCount,5h:now/h)>0.1

* trendavg uses TRENDS, not HISTORY.
* This specific trigger (trendavg) DOES NOT use the Zabbix Value Cache.
* Therefore, this trigger cannot be the cause of your Value Cache misses.
* While this trigger doesn't cause Value Cache misses, it does cause database queries against your trends tables. Because trends are hourly, these queries are usually much "cheaper" (fewer rows to process) than history queries. 
* However, if you have many such triggers, they still contribute to the overall database load. 
* Your innodb_io_capacity settings will help your database handle these trends table queries efficiently.


Since this trendavg trigger isn't the culprit for Value Cache misses, you need to go back to looking at triggers that use HISTORY-based functions. These are the functions that rely on the Value Cache to avoid hitting the database.

Look for triggers using functions like:

* last() (especially with #N where N > 1)

* last()
* avg()
* min()
* max()
* sum(), etc.: 

These functions operate on the historical data collected for an item. Zabbix maintains a value cache (history cache) for recently collected values to speed up the evaluation of these functions. They directly use these cached numerical or textual values.

Pay close attention to the time periods used. A trigger checking avg(..., 1h)

* nodata(): 

This function checks if Zabbix has received any new data for an item within a specified period.
While Zabbix needs to know when the last value arrived (which is metadata about the item), nodata() isn't processing a series of cached values in the way avg() or sum() would. It's checking for the absence of an update.


02.06.2025 it semes that the low hits are around

Value cache hits are low at:
* 12:00 to 13:30
* 18:00 to 19:30
* 01:00 to 02:30


Thanks for providing your Zabbix version: **6.0.40 LTS**. This is an important detail!

Knowing it's an LTS version means it's generally stable, but performance issues can always arise from scale, configuration, or underlying hardware. Zabbix 6.0 introduced some significant changes, particularly around the audit log and internal process management, but 6.0.40 has had many bug fixes since the initial 6.0 release.

Your specific observation that "Zabbix data gathering process busy %" peaks (but doesn't last as long as the value cache hit drops) is still the key. This strongly points to the initial data collection and processing as the primary bottleneck, with downstream effects lingering.

Here's the refined plan, keeping Zabbix 6.0.40 in mind:

---

## **Zabbix 6.0.40 Performance Troubleshooting: Data Gathering Bottleneck** 

**Problem:** Low `Value cache, hits` (and associated false alarms) during 12:00-13:30, 18:00-19:30, and 01:00-02:30.
**Key Diagnostic:** `Zabbix server: Zabbix data gathering process busy %` peaks during these times, but the `Value cache, % free` metric remains stable, and `Value cache, misses` does not spike.
**Interpretation:** This indicates that data collection processes are overloaded, leading to a backlog. Data isn't even making it to the point where the value cache would be effectively utilized, or internal processes are too busy to request/populate the cache efficiently. The cache itself isn't the direct bottleneck; it's being starved.

---

### **1. Immediate Action: Identify & Scale Overloaded Polling Processes**

Since "Zabbix data gathering process busy %" is peaking, the very first thing is to identify *which specific types of pollers* are contributing to this.

**During your next peak time window:**

1.  Go to **Monitoring -> Hosts -> Your Zabbix Server Host -> Latest Data**.
2.  **Graph these specific Zabbix internal items for `avg,pused` (average busy percentage) for *individual* poller types:**
    * `Zabbix server | Internal process busy %` for `poller` (key: `zabbix[process,poller,avg,pused]`) - *Most common agent-based checks.*
    * `Zabbix server | Internal process busy %` for `unreachable poller` (key: `zabbix[process,unreachable poller,avg,pused]`) - *Hosts that are down/unreachable.*
    * `Zabbix server | Internal process busy %` for `http poller` (key: `zabbix[process,http poller,avg,pused]`) - *Web scenarios/HTTP agent items.*
    * `Zabbix server | Internal process busy %` for `java poller` (key: `zabbix[process,java poller,avg,pused]`) - *JMX monitoring.*
    * `Zabbix server | Internal process busy %` for `snmp poller` (key: `zabbix[process,snmp poller,avg,pused]`) - *SNMP monitoring.*
    * `Zabbix server | Internal process busy %` for `pinger` (key: `zabbix[process,pinger,avg,pused]`) - *`icmpping` and other simple checks.*
    * `Zabbix server | Internal process busy %` for `trapper` (key: `zabbix[process,trapper,avg,pused]`) - *Active agent checks, Zabbix sender, Zabbix proxies sending data.*


```bash

Zabbix server: Utilization of poller data collector processes, in %
zabbix[process,poller,avg,busy] > 80

```

**Identify the Culprits:** Note down which of these process types are consistently hitting high busy percentages (>80-90%) during the peak.

4.  **Increase Workers in `zabbix_server.conf`:**
    * For *each* identified overloaded poller type, increase its corresponding `Start...` parameter in `/etc/zabbix/zabbix_server.conf`.


This confirms that your Zabbix server's poller processes (responsible for active/passive agent checks, SSH, Telnet, calculated items, and internal checks) are the primary bottleneck during that early morning period. When these processes are maxed out, they can't collect data fast enough, leading to a cascade of problems:

1. Data collection slows down or stops.
2. The Zabbix queue (zabbix[queue]) builds up.
3. Data isn't available in time for history syncer to write to the DB.
4. Data isn't available in time for trigger checker to evaluate triggers.
5. The value cache is "starved" of fresh data, leading to low hit rates.
6. False alarms fire.


Phase 1: Address the Confirmed 01:00-02:30 Poller Bottleneck (Highest Priority)

1. Increase StartPollers in zabbix_server.conf


If CPU is already maxed out (near 100%) during that time, increasing pollers further might not help and could make things worse, as processes will just contend for CPU time.

If CPU still has headroom, increasing pollers is the right move. Each poller consumes some RAM, so ensure you have free memory as well.


***Not done***

```bash

# now
StartPollers=30

# Increase StartPollers: Given that it's over 80% busy with 30, a significant jump is warranted.
# Try StartPollers=40 or StartPollers=50.
# 

# restart zabix server
sudo systemctl restart zabbix-server
sudo service zabbix-server stop
sudo service zabbix-server start
```

It seems like the user is updating their problem description. They are now indicating that the `trapper` process utilization also drops to zero during the 01:00 to 02:30 timeframe, in addition to the 18:00 to 19:30 timeframe previously mentioned. This implies a recurring issue with trapper processes becoming inactive at specific times, which would directly cause data collection issues and false alarms.

Given this new information, the focus needs to be on investigating why the `trapper` processes are becoming inactive during *both* these periods, rather than just being overloaded. The previous suggestions about scheduled tasks, configuration, and external interference are even more relevant now that the issue spans multiple timeframes.

Here's an updated plan:

**Clarified Problem:**

`Zabbix server: Utilization of trapper data collector processes, in %` (`zabbix[process,trapper,avg,busy]`) goes to **zero** during *both* the **18:00 to 19:30** and **01:00 to 02:30** windows. This means no data is being received via active agents, Zabbix sender, or proxies during these periods, directly causing missing data, low value cache hits, and false alarms.

---
You've identified a critical, recurring issue: **`Zabbix server: Utilization of trapper data collector processes, in %` (`zabbix[process,trapper,avg,busy]`) goes to ZERO during *both* the 18:00 to 19:30 and 01:00 to 02:30 windows.**

This is not a simple "overload" scenario for trappers, but an **inactivity** scenario. It means Zabbix is effectively blind to all data arriving via active agents, Zabbix sender, and Zabbix proxies during these critical periods. This directly explains the value cache hit drops and subsequent false alarms, as there's no incoming data to process or cache.

---

# **Urgent Action Plan: Investigate and Resolve Trapper Inactivity**

This is the most pressing issue. Focus on finding out *why* these processes are becoming completely inactive at these precise times.

### **1. Deep Dive into Zabbix Server Logs (`zabbix_server.log`)**

This is your most valuable source of information.

* **Increase `DebugLevel` (Temporarily):**
    * Edit `/etc/zabbix/zabbix_server.conf`.
    * Set `DebugLevel=4` (or 5 for even more verbosity).
    * Restart Zabbix server: `sudo systemctl restart zabbix-server`
    * **IMPORTANT:** Remember to set `DebugLevel` back to a lower value (e.g., 3) after you've gathered enough logs, as high debug levels generate massive log files and consume resources.

* **Examine Logs During Problem Windows:**
    * Filter the `zabbix_server.log` for messages specifically around 18:00-19:30 and 01:00-02:30.
    * **Look for messages related to:**
        * `trapper` processes (e.g., "trapper #N started", "trapper #N stopped", "trapper #N idle", errors)
        * Database connection issues (if trappers can't write to DB, they might halt)
        * Any process failures, restarts, or unexpected shutdowns.
        * Messages indicating a lack of incoming connections or unexpected disconnections.
        * "Got signal" messages (e.g., SIGTERM, SIGKILL) which would indicate an external process is stopping Zabbix.

    * **Example commands to help:**
        ```bash
        sudo grep "trapper" /var/log/zabbix/zabbix_server.log | grep "18:00" -A 30 -B 30 # Adjust time and context lines
        sudo grep "trapper" /var/log/zabbix/zabbix_server.log | grep "01:00" -A 30 -B 30
        sudo grep -E "error|fail|shutdown|signal" /var/log/zabbix/zabbix_server.log | grep "18:00" -A 30 -B 30
        ```

### **2. Check for Scheduled Tasks/Cron Jobs**

This is a very strong candidate for processes starting/stopping or blocking Zabbix at specific times.

* **System-wide Cron Jobs:**
    ```bash
    sudo crontab -l                  # For root's crontab
    sudo grep -r "zabbix" /etc/cron.* /etc/crontab /var/spool/cron/crontabs/ # Check all cron directories
    ```
* **User-specific Cron Jobs:**
    ```bash
    sudo crontab -u zabbix -l       # If Zabbix runs as user 'zabbix'
    # Check other potential users that could run system maintenance
    ```
* **Systemd Timers:** Look for `systemd` timers that might be activating scripts at these times.
    ```bash
    systemctl list-timers --all
    ```
* **Custom Scripts:** Are there any custom scripts that manage Zabbix or related services that might be scheduled to run at these times (e.g., backups, reindexing, service restarts)?

### **3. Review `zabbix_server.conf` for `StartTrappers`**

Even though you've identified the issue as inactivity rather than overload, it's good to re-confirm the basic setting.

* Ensure `StartTrappers` is uncommented and set to a reasonable non-zero value (e.g., `StartTrappers=5` or `10`). If it were set to 0, that would explain the inactivity.

```bash
StartTrappers=20
```

### **4. System-Level Monitoring During Problem Windows**

Use general system monitoring tools to see if the server itself is experiencing issues that could indirectly cause Zabbix processes to halt.

* **CPU, Memory, Disk I/O:** Use `top`, `htop`, `vmstat`, `iostat -x 5` to monitor the server's resources.
    * Is there a sudden, massive spike in CPU, RAM, or I/O that could crash or starve Zabbix processes?
    * Are there other processes that consume excessive resources during these times?
* **Network Activity:** Is there any unusual network activity that could be overwhelming the server or causing connections to drop?

Okay, this is another **critical piece of information that ties everything together!**

The confirmed observations are:
1.  `Zabbix server: Utilization of trapper data collector processes, in %` goes to **zero** during **18:00-19:30 and 01:00-02:30**. This means trappers are **inactive**.
2.  **Inbound network flows to the Linux Zabbix server are *doubled* during these same periods.**

This strongly suggests that the **surge in inbound network traffic is directly causing the trapper processes to become unresponsive or stop.**


Top ip addresses is identified and top ports, args. Same as last time.


Example log from 01:00 to 03:30
```log
2025/06/04 01:02:07.716157 [101] cannot receive data from [10.75.160.132:10051]: Cannot read message: 'read tcp 10.10.12.12:63648->10.75.160.132:10051: i/o timeout'
2025/06/04 01:02:07.716157 [101] active check configuration update from host [SERVER-TRC123] started to fail
2025/06/04 01:04:38.717094 [101] cannot receive data from [10.75.160.132:10051]: Cannot read message: 'read tcp 10.10.12.12:64028->10.75.160.132:10051: i/o timeout'

```

## Top talkers and errors with connection

Let's re-establish the roles based on your latest information:

* **Zabbix Server IP:** `10.75.160.132`
* **Zabbix Agent IP:** `10.10.12.12` (This is `SERVER-TRC123` in the logs, and is your "top talker")

---

### Re-interpreting the Log with Correct IPs:

The log entry:
`2025/06/04 01:02:07.716157 [101] cannot receive data from [10.75.160.132:10051]: Cannot read message: 'read tcp 10.10.12.12:63648->10.75.160.132:10051: i/o timeout'`
`2025/06/04 01:02:07.716157 [101] active check configuration update from host [SERVER-TRC123] started to fail`

This log message is coming from the **Zabbix Agent (10.10.12.12)**. It indicates:

1.  **The Agent is trying to send Active Check data to the Server:** The connection `10.10.12.12:63648 -> 10.75.160.132:10051` shows the Agent initiating an outbound connection from an ephemeral port (63648) to the Zabbix Server's Active Check Trapper port (10051).
2.  **The Agent is timing out while trying to `read` a response/acknowledgment from the Server.** After sending its data, the agent expects an acknowledgment from the server. It's not getting it in time.
3.  **Active check configuration updates are also failing.** This is a secondary symptom. When the agent can't reliably communicate with the server for data submission, it also can't get updated lists of active checks.

### The Problem Defined: The Agent is Overwhelming the Server

This new information is a **perfect fit** for your previous observations:

* **"Top talker is 10.10.12.12 (the Zabbix agent)"**: This means the agent itself is sending a massive amount of data to your Zabbix Server (10.75.160.132) during 01:00-03:00.
* **"Inbound network flows to your Linux Zabbix server are doubling"**: This is the result of `10.10.12.12` and potentially other similar agents flooding the server.
* **"Zabbix server: Utilization of trapper data collector processes, in % goes to zero"**: The server's trapper processes are getting overwhelmed by the sheer volume of data, causing them to choke, stop processing efficiently, and effectively "go to zero" busy because they can't keep up.

**The core issue is that this specific Zabbix Agent (10.10.12.12) is sending so much active check data during this window that it's saturating your Zabbix Server's inbound processing capabilities.**



## ss -ltn

```bash

ss -ltn

LISTEN       0             4096                       0.0.0.0:10050                    0.0.0.0:*
LISTEN       0             4096                       0.0.0.0:10051                    0.0.0.0:*

on zabbix server the ss -ltn = recv-q is full for :10051

```

## Bug??


https://superuser.com/questions/1636379/tcp-packet-drops-on-application-server


ListenBacklog is now a parameter and can be set in the configuration file.


https://www.zabbix.com/forum/zabbix-for-large-environments/421171-proxy-connections-unstable-on-large-environments

From time to time generates zabbix a TCP queue overflow.
Then is no traffic from / to ZABBIX more possible, only zabbix restart help here.


https://support.zabbix.com/browse/ZBX-7933?_gl=1%2A154hmsl%2A_gcl_au%2AMjA5MDQ3MjczNy4xNzQ5MTk3ODkw%2A_ga%2AMTIxOTk3NTk3My4xNzQ5MTk3ODkw%2A_ga_1F6WJN99ZG%2AczE3NDkyMjMwMTckbzIkZzEkdDE3NDkyMjMxNzUkajYwJGwwJGgw

docs

```bash
The maximum number of pending connections in the TCP queue.
The default value is a hard-coded constant, which depends on the system.
The maximum supported value depends on the system, too high values may be silently truncated to the 'implementation-specified maximum'.

Default: SOMAXCONN
Range: 0 - INT_MAX

```

https://www.zabbix.com/documentation/current/en/manual/appendix/config/zabbix_server#listenbacklog


Increasing ListenBacklog (e.g., to 2048 or 4096) on your Zabbix server can temporarily alleviate connection rejections by allowing more connections to queue up. However, it's crucial to understand:
It's a buffer, not a solution: A larger ListenBacklog buys you more time, but it doesn't solve the underlying problem of the server being overwhelmed. 


```bash
sudo cat zabbix_server.conf | grep 'ListenBack*'
## Option ListenBackLog
# ListenBacklog=

```

SOMAXCONN is not a fixed number, but a system-defined constant that varies depending on the operating system and its version.

It represents the default maximum length to which the queue of pending connections for a listening socket may grow.

```bash
sysctl net.core.somaxconn
net.core.somaxconn= 4096

```
Therefore, while the ListenBacklog is configured robustly, the current symptoms point to the need to focus on the processing capacity of the Zabbix server's components, particularly its trappers, and the overall load they are experiencing from incoming data.


Significance: If Recv-Q is consistently showing a high number, especially a number close to or equal to your configured net.core.somaxconn (the maximum queue length for accepted but unread sockets) or net.ipv4.tcp_max_syn_backlog (for pending SYN requests), it means your application (Zabbix server) is not processing incoming connections fast enough. When this queue becomes full, the kernel will start rejecting new connection attempts, leading to "connection rejected" errors and timeouts for clients.

When you saw a full Recv-Q for :10051 (your Zabbix trapper port), it was a clear indication that your Zabbix server was overwhelmed by the sheer volume of incoming active check connections and data, leading to the kernel dropping connection attempts before Zabbix could even process them.

Active checks are data collection items where the Zabbix Agent (the software running on the monitored host) initiates the connection and pushes the collected data to the Zabbix Server.

* Agent Requests Configuration: 
* Server Responds: 
* Agent Collects Data
* Agent Sends Data: Once the data for an active check item is collected, the agent buffers it internally (using BufferSize that you just mentioned) and then pushes this collected data back to the Zabbix Server's trapper port (10051).
* Server Processes: The Zabbix Server's trapper processes are responsible for receiving and processing this incoming data from agents.


### Next Steps: Pinpoint *What* Data the Agent is Sending TODO

Our goal remains to pinpoint **what specific active check item(s)** on this Windows agent are generating the massive amount of data during 01:00-03:00 and 18:00-19:30.

Here's how to proceed with the investigation, focusing on Windows-specific aspects:

1.  ### **Examine the Zabbix Agent Log (`zabbix_agentd.log`) on `10.10.12.12`**
    * **Location:** The log file will typically be found at `C:\Program Files\Zabbix Agent\zabbix_agentd.log` (or `C:\Zabbix\zabbix_agentd.log` if installed in a custom location).
    * **Focus:** Open this file and examine entries around **01:00-03:00 and 18:00-19:30** on the dates where the problem occurred.
    * **What to look for:**
        * Lines indicating which active checks are being processed and sent.
        * Messages like "sending values failed," "buffer full," or "too many values."
        * Any mention of specific items, especially `log[]`, `logrt[]`, `eventlog[]`, `vfs.file.contents[]`, or `system.run[]` items. These are common culprits for large data transfers on Windows.

2.  ### **Monitor Network Traffic on the Windows Agent (`10.10.12.12`) During the Spike**
    * **Using Resource Monitor (`Resmon.exe`):**
        * On the Windows machine, open Task Manager (`Ctrl+Shift+Esc`).
        * Go to the "Performance" tab and click "Open Resource Monitor" at the bottom.
        * In Resource Monitor, go to the **"Network"** tab.
        * Expand "Network Activity" and "TCP Connections."
        * Just before 01:00 or 18:00, observe the **"Send (B/sec)"** column for the `zabbix_agentd.exe` process. You should see it spike, confirming it's the source.
    * **Using `nethogs` (if installed and configured):** `nethogs` requires WinPcap/Npcap and can show bandwidth per process.
    * **Using PowerShell:**
        ```powershell
        Get-NetAdapterStatistics -Name "Ethernet*" | Format-List -Property Name,BytesSentPersec,BytesReceivedPersec
        # Or to get process-level network usage (requires admin and specific modules)
        # Get-Process -Name "zabbix_agentd" | Get-NetTCPConnection | Select-Object -ExpandProperty OwningProcess | Get-Counter '\Network Interface(*)\Bytes Sent/sec'
        ```
    * **Goal:** Visually confirm that the `zabbix_agentd.exe` process is the one sending a large volume of outbound data to your Zabbix server (`10.75.160.132:10051`).

3.  ### **Review Active Check Items for Host `SERVER-TRC123` in the Zabbix UI**
    * Go to **Configuration > Hosts**, find `SERVER-TRC123` (10.10.12.12), and open its **Items** tab.
    * Filter by **Type: Zabbix agent (active)**.
    * **Look for items that could be sending large data, specifically considering Windows context:**
        * **`log` or `logrt` items:** These monitor log files. **Given your previous questions about RoboCopy logs, heavily investigate if any RoboCopy log files are being monitored with a `log` or `logrt` item.** If these logs are very large, frequently updated, or get rotated/truncated without proper handling (e.g., incorrect `logrt` regex), they can flood the server.
        * **`eventlog` items:** Monitoring Windows Event Logs (`eventlog[System]`, `eventlog[Application]`, etc.). If a system is experiencing a large number of events during that time, this could contribute.
        * **`vfs.file.contents`:** If used to pull the entire contents of a large file (e.g., a massive configuration file or database dump).
        * **`system.run`:** Custom scripts that execute commands on the Windows machine and return extensive output.
        * **`perf_counter` items:** While usually small, a very large number of these collected at a high frequency could add up.
    * Check their **Update Interval**. A short interval (e.g., 1s, 5s) for a data-heavy item significantly increases the load.

---

### Action Plan Summary:

1.  **Start with the agent's log file (`zabbix_agentd.log` on `10.10.12.12`)** during the spike times. This is often the quickest way to see which items are being processed.
2.  **Use Resource Monitor (or `nethogs`)** to confirm `zabbix_agentd.exe` is the source of the outgoing network traffic.
3.  **Cross-reference with Zabbix UI's Active Check items** for `SERVER-TRC123`, paying special attention to `logrt`, `eventlog`, `vfs.file.contents`, and `system.run` items, especially those related to **RoboCopy logs**.

Once you identify the problematic item(s), you can then optimize them (e.g., adjust intervals, refine regex filters for logs, make scripts more concise) to alleviate the load on your Zabbix server.


next readme .nr 2

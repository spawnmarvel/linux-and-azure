# Value Cache

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

### Fix 2 Check MySql and network









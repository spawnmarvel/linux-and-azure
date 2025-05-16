# Monitor innodb

```markdown
# Assessing MySQL Performance After Changing `innodb_io_capacity`

This guide explains how to monitor and evaluate the impact of changing the `innodb_io_capacity` parameter in your MySQL configuration.  Proper monitoring is crucial to determine if your change improves or degrades performance.

## 1.  Establish a Baseline (Before the Change!)

*   **Importance:**  This is your reference point.  Collect performance metrics *before* making any changes.  This allows you to accurately compare results.
*   **Tools:**
    *   **`SHOW GLOBAL STATUS`:** Primary source of real-time performance data.
    *   **System-Level Monitoring:** CPU, disk I/O, and network usage (e.g., `iostat` on Linux, Performance Monitor on Windows, or cloud provider monitoring).
    *   **Workload (Real or Simulated):** Run your regular workload or a representative benchmark.

*   **Commands for Baseline Collection:**

    ```sql
    -- Before Change (Run these BEFORE changing innodb_io_capacity)
    SHOW GLOBAL STATUS LIKE 'Innodb%';
    SHOW GLOBAL STATUS LIKE 'Threads%';
    SHOW GLOBAL STATUS LIKE 'Queries%';
    -- ... Other SHOW GLOBAL STATUS commands (see details in Section 2)

    -- Optional: Get slow query information
    SHOW GLOBAL STATUS LIKE 'Slow_queries';
    ```

## 2.  Monitor with `SHOW GLOBAL STATUS` (MySQL Level)

*   **Purpose:** Provides real-time insights into InnoDB activity.

*   **Key Status Variables to Monitor:** (Run before and after the change, and periodically)

    ```sql
    -- InnoDB Specific
    SHOW GLOBAL STATUS LIKE 'Innodb_buffer_pool_read_requests'; -- (High is good) Requests from buffer pool
    SHOW GLOBAL STATUS LIKE 'Innodb_buffer_pool_reads';     -- (Low is good) Reads from disk
    SHOW GLOBAL STATUS LIKE 'Innodb_os_log_fsyncs';           -- File sync operations (can show disk issues)
    SHOW GLOBAL STATUS LIKE 'Innodb_log_waits';             -- Waits for log flushes (can show log bottlenecks)
    SHOW GLOBAL STATUS LIKE 'Innodb_data_reads';           -- Physical reads
    SHOW GLOBAL STATUS LIKE 'Innodb_data_writes';          -- Physical writes
    SHOW GLOBAL STATUS LIKE 'Innodb_data_read_time';        -- Total time spent reading
    SHOW GLOBAL STATUS LIKE 'Innodb_data_write_time';       -- Total time spent writing
    SHOW GLOBAL STATUS LIKE 'Innodb_row_lock_waits';       -- Row lock waits
    SHOW GLOBAL STATUS LIKE 'Innodb_row_lock_time';         -- Time spent waiting for row locks
    SHOW GLOBAL STATUS LIKE 'Innodb_buffer_pool_pages_flushed';
    SHOW GLOBAL STATUS LIKE 'Innodb_buffer_pool_pages_dirty';

    -- Thread-Related
    SHOW GLOBAL STATUS LIKE 'Threads_connected';
    SHOW GLOBAL STATUS LIKE 'Threads_running';

    -- Query-Related
    SHOW GLOBAL STATUS LIKE 'Queries';                  -- Total queries
    SHOW GLOBAL STATUS LIKE 'Slow_queries';           -- Slow queries (if enabled)
    SHOW GLOBAL STATUS LIKE 'Com_select';
    SHOW GLOBAL STATUS LIKE 'Com_insert';
    SHOW GLOBAL STATUS LIKE 'Com_update';
    SHOW GLOBAL STATUS LIKE 'Com_delete';
    SHOW GLOBAL STATUS LIKE 'Com_commit';
    SHOW GLOBAL STATUS LIKE 'Com_rollback';
    ```

*   **Interpretation:**

    *   **`Innodb_buffer_pool_read_requests`:** High is desirable.
    *   **`Innodb_buffer_pool_reads`:** Low is desirable. A high ratio of `requests` to `reads` indicates good caching.
    *   **`Innodb_os_log_fsyncs` and `Innodb_log_waits`:** Monitor for increases, which can indicate log bottlenecks.
    *   **`Threads_running`:** High values can suggest a bottleneck.
    *   **`Slow_queries`:** Track for increases in slow queries.

## 3.  Monitor System-Level Metrics (Beyond MySQL)

*   **Purpose:** Identify bottlenecks at the operating system and hardware level.

*   **Key Metrics to Monitor:**

    *   **CPU Usage:**
        *   Is CPU near 100% utilization?  Indicates a possible CPU bottleneck.
    *   **Disk I/O:** *Critical*
        *   `%util` (Disk Utilization): Aim for below 80-90% (generally).
        *   `await`: Average time for I/O requests (milliseconds). Higher = slower.
        *   `svctm` (Service Time):  Time disk is busy servicing a request.
        *   `r/s` (Reads per second) and `w/s` (Writes per second):  High numbers are okay, but check `await`.
        *   `MB/s`: Megabytes per second transferred.
    *   **Memory Usage:**  Monitor swap usage. Swapping severely degrades performance.
    *   **Network I/O:** Monitor network usage.

*   **Tools:**

    *   **Linux/Unix:** `iostat`, `top`, `free -m`
    *   **Windows:** Task Manager, Performance Monitor (perfmon)
    *   **Cloud Providers:** Use cloud provider's monitoring (AWS CloudWatch, Azure Monitor, Google Cloud Monitoring) - recommended.

*   **Example `iostat` command (Linux):**

    ```bash
    iostat -x 1  #  Extended stats, updating every second.
    ```

## 4.  Workload Analysis and Testing

*   **Purpose:**  Evaluate performance under a realistic load.

*   **Methods:**

    1.  **Real Workload:** Run your *actual* application workload.  This is the most accurate.

    2.  **Simulated Workload (Benchmarking):** If running the real workload is not feasible:
        *   **`sysbench`:** (Highly recommended) Versatile for various MySQL tests (CPU, disk I/O, transactions).  Configure for your workload type (read-only, write-heavy, mixed).
        *   **`tpcc-mysql`:**  (For OLTP)  TPC-C benchmark (for online transaction processing).
        *   **`mysqlslap`:** (Built-in MySQL tool)  Simulates client load.

*   **Testing Process:**

    1.  **Baseline:** Run the workload or benchmark *before* changing `innodb_io_capacity`. Record results (TPS, response times, system resource usage).
    2.  **Change `innodb_io_capacity`:**  Restart MySQL (or flush caches - see Section 5).
    3.  **Rerun Workload/Benchmark:** Run the *same* workload *after* the change.
    4.  **Compare Results:** Compare the performance metrics to the baseline.

## 5.  Restart, Flush, and Warmup (Important!)

*   **Restart MySQL:**  Most reliable to apply the change. Resets caches and statistics.
*   **Flush and Warmup (Alternative, if restart is not desired):**

    1.  `FLUSH TABLES;`
    2.  `FLUSH ENGINE LOGS;`
    3.  **Warmup Buffer Pool:**  After restarting or flushing, the buffer pool is empty.  Warm it up by:
        *   Running queries that access your most important data.
        *   Letting the system run long enough for data to be cached in the buffer pool.

    *   **Important Considerations:**
        *   **Dirty Pages:**  Monitor `Innodb_buffer_pool_pages_dirty`. High numbers mean more writes.
        *   **Log Files:**  The log will be affected.
        *   **Long-Term Monitoring:**  Monitor over time (hours, or even days) to see the full impact.

## 6.  Interpreting Results and Tuning Further

*   **Increased Performance (Positive Impact):**
    *   Higher TPS or faster query response times.
    *   Lower disk I/O utilization.
    *   Reduced `Innodb_buffer_pool_reads` and `Innodb_log_waits`.
    *   Reduced wait times for row locks.

    -> `innodb_io_capacity = 400` (or your set value) is likely a good change.

*   **No Change or Decreased Performance:**
    *   No improvement or decreased TPS/response times.
    *   Increased disk I/O utilization.
    *   No reduction in `Innodb_buffer_pool_reads`.
    *   Increased `Innodb_log_waits`.
    *   Increased wait times for row locks.

    -> `innodb_io_capacity = 400` might not be optimal. Try other values, or address other bottlenecks.

*   **Troubleshooting:**
    *   **Disk Still a Bottleneck:** Increase `innodb_io_capacity` (but don't exceed the disk's capacity). Consider a faster disk (SSD).
    *   **CPU Bottleneck:** Optimize queries, add indexes, increase server CPU resources.
    *   **Other MySQL Settings:**  Optimize `innodb_buffer_pool_size`, `innodb_log_file_size`, `innodb_log_buffer_size`, thread settings, and other parameters. Experiment!
    *   **Hardware:** Disk type, CPU speed, RAM influence performance.
    *   **Workload:** Workload characteristics (read-heavy, write-heavy, mixed) affect tuning.

*   **Iterative Tuning:**
    1.  Make a change.
    2.  Monitor performance.
    3.  Analyze the results.
    4.  Adjust settings.
    5.  Repeat.

## 7.  Important Considerations and Best Practices

*   **Disk Type:**
    *   **SSDs:**  Set `innodb_io_capacity` to reflect the sustained IOPS of your SSD. Check the SSD's documentation (often 10,000 - 20,000 IOPS or more).
    *   **HDDs:** Start with the default `200`.
*   **`innodb_io_capacity_max`:** Often set to a value higher than `innodb_io_capacity` (e.g., 2x or 3x).  Provides for burst I/O if the disk is not saturated.  If not set, defaults to `innodb_io_capacity`.
*   **`innodb_buffer_pool_size`:**  Critical!  Set to 70-80% of RAM (or more), leaving some for the OS.  Experiment!
*   **`innodb_log_file_size`:**  Affects write performance. Increase if write bottlenecks occur. Restart needed.
*   **`innodb_log_buffer_size`:**  Increase if you see frequent log flushes. Restart needed.
*   **Indexes:** Optimize queries and create appropriate indexes.
*   **Query Optimization:** Use `EXPLAIN` to analyze query plans and optimize SQL.
*   **MySQL Version:**  Keep MySQL up-to-date.
*   **Cloud-Specific Settings:**  Follow your cloud provider's best practices.
*   **Don't Overcommit:** Don't set `innodb_io_capacity` higher than the sustained IOPS of your disk/storage.
*   **Shared Storage:** If you are using shared storage array, consider the performance of the array.

This guide provides a framework. The ideal settings are workload-specific. Remember to baseline, monitor, and test changes in a controlled environment before deploying them to production.
```
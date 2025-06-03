# Zabbix functions


## Trend functions


Trend functions, in contrast to history functions, use trend data for calculations.

Trends store hourly aggregate values. Trend functions use these hourly averages, and thus are useful for long-term analysis.

Trend function results are cached so multiple calls to the same function with the same parameters fetch info from the database only once. The trend function cache is controlled by the TrendFunctionCacheSize server parameter.

* trendavg
* trendmax
* trendmin
* trendsum


https://www.zabbix.com/documentation/current/en/manual/appendix/functions/trends

## History functions

* change
* count
* find
* last
* nodata

https://www.zabbix.com/documentation/current/en/manual/appendix/functions/history

## Trend vs history

In zabbix_server.conf, history functions primarily use the Value Cache (ValueCacheSize parameter) for recent data, and trend functions use the Trend Cache (TrendCacheSize parameter).

### **Summary of Usage and Caches:**

| Feature       | Data Granularity     | Typical Retention | Primary Use Cases                                                                  | Main Cache Used                  |
| :------------ | :------------------- | :---------------- | :--------------------------------------------------------------------------------- | :------------------------------- |
| **History** | Every collected value | Short-term (days) | - Real-time monitoring\<br\>- Precise troubleshooting\<br\>- **Trigger evaluation** | `ValueCacheSize`, `HistoryCacheSize` |
| **Trends** | Hourly aggregated    | Long-term (months/years) | - Long-term capacity planning\<br\>- Historical reporting\<br\>- Graphs over long periods | `TrendCacheSize`                 |

By effectively managing your history and trend retention periods, and properly sizing your Zabbix caches, you can optimize both the performance of your Zabbix server and the longevity of your monitoring data. The general advice is to keep history for as short a period as needed for trigger evaluation and immediate troubleshooting, and then leverage trends for long-term analysis.

In summary, your proposed 

```bash
History=90 days and Trends=365 days
``` 
is a sensible and widely used configuration that balances granular short-term data with efficient long-term aggregation. It's a great starting point for most Zabbix deployments.


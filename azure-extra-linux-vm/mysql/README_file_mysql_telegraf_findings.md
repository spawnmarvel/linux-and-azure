### Example `telegraf.conf`

```toml
# Global settings
[agent]
 interval = "25s"
 round_interval = true
 metric_batch_size = 1000
 metric_buffer_limit = 10000
 collection_jitter = "0s"
 flush_interval = "30s"
 flush_jitter = "5s" precision = ""
 debug = true
 quiet = false # quiet: Log only error level messages.
 logfile = "/var/log/telegraf/telegraf.logs"
 logfile_rotation_max_size = "5MB"
 logfile_rotation_max_archives = 10

# Readme
# https://github.com/influxdata/telegraf/blob/master/docs/CONFIGURATION.md#agent

###############################################################################
#                                  INPUTS                                     #
###############################################################################
[[inputs.file]]
  ## Files to parse each interval
  files = ["/var/telegraf_data/metrics.in.json"]

  data_format = "json"
  json_name_key = "measurement"
  json_string_fields = ["quality"]
  tagexclude = ["host"]  # Exclude the "host" tag if not needed

###############################################################################
#                                  OUTPUTS                                     #
###############################################################################


# Send telegraf metrics to file(s)
[[outputs.file]]
  ## Files to write to, "stdout" is a specially handled file.
  files = ["/var/telegraf_data/metrics.out.json"]

  ## Data format to output.
  ## Each data format has its own unique set of configuration options, read
  ## more about them here:
  ## https://github.com/influxdata/telegraf/blob/master/docs/DATA_FORMATS_INPUT.md
  ## data_format = "influx"
  data_format = "json"
  # Output Plugin: SQL (MySQL)
[[outputs.sql]]
  ## Database driver, available drivers are: "mysql", "postgres", "mssql", "sqlite3", "snowflake"
  driver = "mysql"

  ## Data source name (DSN) for MySQL
  ## Format: username:password@tcp(host:port)/dbname?param1=value1&param2=value2
  data_source_name = "telegraf_user:etlaccount1@tcp(127.0.0.1:3306)/telegraf_db?charset=utf8"

  ## Table creation behavior
  ## If true, Telegraf will automatically create tables for measurements
  table_template = "CREATE TABLE IF NOT EXISTS `%s` (time DATETIME NOT NULL, %s, PRIMARY KEY (time))"
  # the above did not work and a new table was created look below, primary key should not be time either, but id

  ## Initialization SQL
  init_sql = "SET sql_mode='ANSI_QUOTES';"

  ## Timestamp column name
  timestamp_column = "time"

  ## Flush interval for writing to the database
  flush_interval = "10s"
```

### Explanation of the Configuration

#### 1. **Global Settings (`[agent]`)**
   - `interval`: How often Telegraf collects data from the input plugins.
   - `flush_interval`: How often Telegraf flushes data to the output plugins.
   - `debug`: Enable debug logging for troubleshooting.
   - `hostname`: Identifier for the host sending the metrics.

#### 2. **Input Plugin: `inputs.file`**
   - `files`: Specifies the file(s) to read metrics from. You can use glob patterns to match multiple files.
   - `data_format`: Specifies the format of the data in the file. Common options include:
     - `influx` (InfluxDB line protocol)
     - `json` (JSON format)
     - `csv` (CSV format)
     - See the [Telegraf documentation](https://github.com/influxdata/telegraf/blob/master/docs/DATA_FORMATS_INPUT.md) for more formats.
   - `name_override`: Overrides the default measurement name (useful if you want a custom name instead of the filename).
   - `tags`: Adds static tags to all metrics collected from the file.

#### 3. **Output Plugin: `outputs.sql`**
   - `driver`: Specifies the SQL database driver. In this case, `mysql` is used.
   - `data_source_name`: Connection string for MySQL. Replace `telegraf_user`, `password`, `127.0.0.1:3306`, and `telegraf_db` with your actual MySQL credentials, host, port, and database name.
   - `table_template`: Defines the SQL statement for creating tables. The `%s` placeholders are replaced with the measurement name and column definitions.
   - `timestamp_column`: Specifies the name of the column used to store timestamps.
   - `batch_size`: Number of metrics to batch before writing to the database.
   - `flush_interval`: How often to flush batched metrics to the database.

### Prerequisites for MySQL

1. **Create the MySQL Database and User**
   Before running Telegraf, ensure the MySQL database and user are set up. For example:

   ```sql
   CREATE DATABASE telegraf_db;
   CREATE USER 'telegraf_user'@'%' IDENTIFIED BY 'etlaccount1';
   GRANT ALL PRIVILEGES ON telegraf_db.* TO 'telegraf_user'@'%';
   FLUSH PRIVILEGES;
   ```

2. **Install MySQL Driver for Telegraf**
   Telegraf requires the MySQL driver to connect to MySQL. Ensure the `mysql` driver is available in your Go environment or installed on your system if using a pre-built Telegraf binary.

### Example Metrics File (`metrics.in.json`)

```json
[
  {
    "measurement": "tag1",
    "fields": {
      "value": 101,
      "active": 1,
      "state": 0,
      "quality": "good"
    }
  },
  {
    "measurement": "tag2",
    "fields": {
      "value": 55,
      "active": 1,
      "state": 0,
      "quality": "good"
    }
  }
]

```

### Running Telegraf

1. Save the configuration file as `telegraf.conf`.
2. Test the configuration to ensure it's valid:

   ```bash
   telegraf --config telegraf.conf --test
   ```

3. Run Telegraf with the configuration:

   ```bash
   telegraf --config telegraf.conf
   ```


### It does not auto create the tables (mysql user rights?)

Use an Auto-Increment Primary Key


```sql

CREATE TABLE IF NOT EXISTS `tag1` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  time DATETIME(6) NOT NULL,
  `value` DOUBLE,
  `active` BIGINT,
  `state` BIGINT,
  `quality` TEXT
);


CREATE TABLE IF NOT EXISTS `tag2` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  time DATETIME(6) NOT NULL,
  `value` DOUBLE,
  `active` BIGINT,
  `state` BIGINT,
  `quality` TEXT
);


```

Is perfect now:

```sql
select * from tag1;
+----+----------------------------+-------+--------+-------+---------+
| id | time                       | value | active | state | quality |
+----+----------------------------+-------+--------+-------+---------+
|  1 | 2025-02-27 22:16:40.000000 |   102 |      1 |     0 | good    |
|  2 | 2025-02-27 22:16:40.000000 |   102 |      1 |     0 | good    |
|  3 | 2025-02-27 22:17:05.000000 |   102 |      1 |     0 | good    |
|  4 | 2025-02-27 22:17:30.000000 |   102 |      1 |     0 | good    |
|  5 | 2025-02-27 22:17:55.000000 |   102 |      1 |     0 | good    |
|  6 | 2025-02-27 22:18:20.000000 |   102 |      1 |     0 | good    |
|  7 | 2025-02-27 22:18:45.000000 |   102 |      1 |     0 | good    |
+----+----------------------------+-------+--------+-------+---------+


select * from tag2;
+----+----------------------------+-------+--------+-------+---------+
| id | time                       | value | active | state | quality |
+----+----------------------------+-------+--------+-------+---------+
|  1 | 2025-02-27 22:16:40.000000 |    55 |      1 |     0 | good    |
|  2 | 2025-02-27 22:17:05.000000 |    55 |      1 |     0 | good    |
|  3 | 2025-02-27 22:17:30.000000 |    55 |      1 |     0 | good    |
|  4 | 2025-02-27 22:17:55.000000 |    55 |      1 |     0 | good    |
|  5 | 2025-02-27 22:18:20.000000 |    55 |      1 |     0 | good    |
|  6 | 2025-02-27 22:18:45.000000 |    55 |      1 |     0 | good    |
|  7 | 2025-02-27 22:19:10.000000 |    55 |      1 |     0 | good    |
+----+----------------------------+-------+--------+-------+---------+


```


### Troubleshoot

```log
2025-02-27T21:43:42Z D! [outputs.sql] Buffer fullness: 22 / 10000 metrics
2025-02-27T21:43:42Z E! [agent] Error writing to outputs.sql: Error 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near '%s, PRIMARY KEY (time))' at line 1


```


This indicates that MySQL received an SQL statement where a %s placeholder was not properly substituted, specifically near '%s, PRIMARY KEY (time))'. This suggests that:

The first %s (intended for the table name) was replaced successfully (since it's not in the error message anymore).
The second %s (intended for the field definitions) was not replaced and remains in the SQL statement sent to MySQL.


Understanding the Issue

This means that Telegraf could identify the measurement name (the table name) from your metrics, but it couldn't generate the field definitions needed to fill in the second %s.


check metrics.out.json

```log

{"fields":{"fields_active":1,"fields_state":0,"fields_value":101},"name":"tag1","tags":{"host":"vmdocker01"},"timestamp":1740693425}
{"fields":{"fields_active":1,"fields_state":0,"fields_value":55},"name":"tag2","tags":{"host":"vmdocker01"},"timestamp":1740693425}

```

It appears that the issue you're encountering stems from how Telegraf is parsing the nested "fields" object in your JSON input. Let's break down what's happening and how to resolve it.


By flattening the structure, Telegraf can directly parse each key as a field without adding prefixes

```json
[
  {
    "measurement": "tag1",
    "value": 101,
    "active": 1,
    "state": 0,
    "quality": "good"
  },
  {
    "measurement": "tag2",
    "value": 55,
    "active": 1,
    "state": 0,
    "quality": "good"
  }
]

```

check metroics.out.json

```json
{"fields":{"active":1,"quality":"good","state":0,"value":101},"name":"tag1","tags":{},"timestamp":1740693750}
{"fields":{"active":1,"quality":"good","state":0,"value":55},"name":"tag2","tags":{},"timestamp":1740693750}


```

Create the tables:

```sql
CREATE TABLE IF NOT EXISTS `tag1` (
  time DATETIME(6) NOT NULL,
  `value` DOUBLE,
  `active` BIGINT,
  `state` BIGINT,
  `quality` TEXT,
  PRIMARY KEY (time)
);



CREATE TABLE IF NOT EXISTS `tag2` (
  time DATETIME(6) NOT NULL,
  `value` DOUBLE,
  `active` BIGINT,
  `state` BIGINT,
  `quality` TEXT,
  PRIMARY KEY (time)
);


```

### Verifying Data in MySQL


```sql
sudo mysql

use telgraf_db;
select * from tag1;

+----------------------------+-------+--------+-------+---------+
| time                       | value | active | state | quality |
+----------------------------+-------+--------+-------+---------+
| 2025-02-27 22:02:30.000000 |   101 |      1 |     0 | good    |
+----------------------------+-------+--------+-------+---------+



```

Next insert

```log

2025-02-27T22:10:55Z E! [agent] Error writing to outputs.sql: execution failed: Error 1062 (23000): Duplicate entry '2025-02-27 22:02:30.000000' for key 'tag1.PRIMARY'

```

Possible Causes

If the input file (metrics.in.json) doesn't change between Telegraf polling intervals, Telegraf reads the same data repeatedly.
The metrics have the same timestamp each time Telegraf reads the file.
This leads to attempts to insert duplicate rows based on the time primary key.

By manually creating the tables with a PRIMARY KEY (time), you've enforced a uniqueness constraint on the time column.

Did edit metrixc.in.json and restarted telegraf

```sql
 select * from tag1;
+----------------------------+-------+--------+-------+---------+
| time                       | value | active | state | quality |
+----------------------------+-------+--------+-------+---------+
| 2025-02-27 22:02:30.000000 |   101 |      1 |     0 | good    |
| 2025-02-27 22:15:25.000000 |   102 |      1 |     0 | good    |
+----------------------------+-------+--------+-------+---------+
2 rows in set (0.00 sec)

```


Use an Auto-Increment Primary Key


```sql

CREATE TABLE IF NOT EXISTS `tag1` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  time DATETIME(6) NOT NULL,
  `value` DOUBLE,
  `active` BIGINT,
  `state` BIGINT,
  `quality` TEXT
);


CREATE TABLE IF NOT EXISTS `tag2` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  time DATETIME(6) NOT NULL,
  `value` DOUBLE,
  `active` BIGINT,
  `state` BIGINT,
  `quality` TEXT
);


```

Is perfect now:

```sql
select * from tag1;
+----+----------------------------+-------+--------+-------+---------+
| id | time                       | value | active | state | quality |
+----+----------------------------+-------+--------+-------+---------+
|  1 | 2025-02-27 22:16:40.000000 |   102 |      1 |     0 | good    |
|  2 | 2025-02-27 22:16:40.000000 |   102 |      1 |     0 | good    |
|  3 | 2025-02-27 22:17:05.000000 |   102 |      1 |     0 | good    |
|  4 | 2025-02-27 22:17:30.000000 |   102 |      1 |     0 | good    |
|  5 | 2025-02-27 22:17:55.000000 |   102 |      1 |     0 | good    |
|  6 | 2025-02-27 22:18:20.000000 |   102 |      1 |     0 | good    |
|  7 | 2025-02-27 22:18:45.000000 |   102 |      1 |     0 | good    |
+----+----------------------------+-------+--------+-------+---------+


select * from tag2;
+----+----------------------------+-------+--------+-------+---------+
| id | time                       | value | active | state | quality |
+----+----------------------------+-------+--------+-------+---------+
|  1 | 2025-02-27 22:16:40.000000 |    55 |      1 |     0 | good    |
|  2 | 2025-02-27 22:17:05.000000 |    55 |      1 |     0 | good    |
|  3 | 2025-02-27 22:17:30.000000 |    55 |      1 |     0 | good    |
|  4 | 2025-02-27 22:17:55.000000 |    55 |      1 |     0 | good    |
|  5 | 2025-02-27 22:18:20.000000 |    55 |      1 |     0 | good    |
|  6 | 2025-02-27 22:18:45.000000 |    55 |      1 |     0 | good    |
|  7 | 2025-02-27 22:19:10.000000 |    55 |      1 |     0 | good    |
+----+----------------------------+-------+--------+-------+---------+


```

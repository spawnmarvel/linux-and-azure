[agent]
 interval = "30s" 
 round_interval = true
 metric_batch_size = 1000 
 metric_buffer_limit = 10000 
 collection_jitter = "0s" 
 flush_interval = "30s"
 flush_jitter = "5s" precision = ""
 debug = true
 quiet = false # quiet: Log only error level messages.
 logfile = "C://Program Files//telegraf//telegraf-1.32.1_windows_amd64//telegraf-1.32.1//telegraf.logs"
 logfile_rotation_max_size = "200KB"
 logfile_rotation_max_archives = 10


# Readme
# https://github.com/influxdata/telegraf/blob/master/docs/CONFIGURATION.md#agent

###############################################################################
#                                  INPUTS                                     #
###############################################################################
[[inputs.file]]
  ## Files to parse each interval.  Accept standard unix glob matching rules,
  ## as well as ** to match recursive files and directories.
  files = ["C://Program Files//telegraf//telegraf-1.32.1_windows_amd64//telegraf-1.32.1//metrics.in.zabbix.json"]
  
  ## Data format to consume.
  ## Each data format has its own unique set of configuration options, read
  ## more about them here:
  ## https://github.com/influxdata/telegraf/blob/master/docs/DATA_FORMATS_INPUT.md
  ## data_format = "influx"
  data_format = "json"


# Read metrics about disk usage by mount point
[[inputs.disk]]
  ## By default stats will be gathered for all mount points.
  ## Set mount_points will restrict the stats to only the specified mount points.
  # mount_points = ["/"]

  ## Ignore mount points by filesystem type.
  ignore_fs = ["tmpfs", "devtmpfs", "devfs", "iso9660", "overlay", "aufs", "squashfs"]

  ## Ignore mount points by mount options.
  ## The 'mount' command reports options of all mounts in parathesis.
  ## Bind mounts can be ignored with the special 'bind' option.
  # ignore_mount_opts = []
  ## data_format = "influx"
  ## data_format = "json"



###############################################################################
#                                  OUTPUTS                                     #
###############################################################################


  # Send telegraf metrics to file(s)
[[outputs.file]]
  ## Files to write to, "stdout" is a specially handled file.
  files = ["C://Program Files//telegraf//telegraf-1.32.1_windows_amd64//telegraf-1.32.1//metrics.out.json"]
  
  ## Data format to output.
  ## Each data format has its own unique set of configuration options, read
  ## more about them here:
  ## https://github.com/influxdata/telegraf/blob/master/docs/DATA_FORMATS_INPUT.md
  ## data_format = "influx"
  ## data_format = "json"

# Send metrics to Zabbix, test http output if it exists, http input was nice
[[outputs.zabbix]]
  ## Address and (optional) port of the Zabbix server
  address = "ip:10051"

  ## Send metrics as type "Zabbix agent (active)"
  agent_active = false

  ## Add prefix to all keys sent to Zabbix.
  key_prefix = "telegraf."

  ## Name of the tag that contains the host name. Used to set the host in Zabbix.
  ## If the tag is not found, use the hostname of the system running Telegraf.
  # host_tag = ""

  ## Skip measurement prefix to all keys sent to Zabbix.
  # skip_measurement_prefix = true

  ## This field will be sent as HostMetadata to Zabbix Server to autoregister the host.
  ## To enable this feature, this option must be set to a value other than "".
  # autoregister = ""

  ## Interval to resend auto-registration data to Zabbix.
  ## Only applies if autoregister feature is enabled.
  ## This value is a lower limit, the actual resend should be triggered by the next flush interval.
  # autoregister_resend_interval = "30m"

  ## Interval to send LLD data to Zabbix.
  ## This value is a lower limit, the actual resend should be triggered by the next flush interval.
  # lld_send_interval = "10m"

  ## Interval to delete stored LLD known data and start capturing it again.
  ## This value is a lower limit, the actual resend should be triggered by the next flush interval.
  # lld_clear_interval = "1h"

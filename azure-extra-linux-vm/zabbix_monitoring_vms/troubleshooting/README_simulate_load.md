# Test your configuration and simulation load for troubleshooting


## Simulate load CPU

On Linux, you can simulate high CPU load and as a result receive a problem alert by running:

```bash

cat /dev/urandom | md5sum
```

The command cat /dev/urandom | md5sum is a pipeline in Unix-like systems that generates a continuous stream of random data and computes its MD5 hash. Here's a breakdown of what happens:

* /dev/urandom is a special file in Unix-like systems that serves as a pseudo-random number generator. It provides an endless stream of random bytes
* The cat command reads the contents of /dev/urandom and outputs it to standard output (stdout)
* The pipe (|) redirects the output of cat /dev/urandom (the random bytes) to the input of the next command, md5sum
* md5sum is a utility that computes the MD5 hash (a 128-bit cryptographic hash) of the input data it receives.
* Since /dev/urandom provides an infinite stream of random data, md5sum will continue reading this stream indefinitely, waiting for the input to end before it can produce a final hash

Infinite Stream Issue: Because /dev/urandom never "ends," md5sum will never finish computing the hash unless you manually stop the command (e.g., by pressing Ctrl+C)

![Test CPU](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/test_cpu.jpg)

## Simulate inbound flows Azure (many connections)

In addition to bandwidth, the number of network connections present on a VM at any given time can affect its network performance. 
The Azure networking stack maintains state for each direction of a TCP/UDP connection in data structures called ‘flows’. 

A typical TCP/UDP connection has two flows created, one for the inbound and another for the outbound direction. 

https://learn.microsoft.com/en-us/azure/virtual-network/virtual-machine-network-throughput


Exhausting port 8080 on an Ubuntu system means consuming all available resources associated with that specific port, typically by opening as many connections as possible to it. This is often done for stress testing, security research, or debugging purposes.

Step 2: Open Many Connections to Port 8080

Use a Bash script to open a large number of connections to port 8080 on localhost, consuming resources on both the client (ephemeral ports, file descriptors) and the server (connection slots, file descriptors).



exhaust_local_10051.sh

```bash
#!/bin/bash

# Target server (localhost in this case)
TARGET="127.0.0.1"
PORT=10051 # 10050

# Number of connections to attempt (adjust based on your system's limits)
CONNECTIONS=800

echo "Attempting to exhaust port $PORT on $TARGET by opening $CONNECTIONS connections..."

for ((i=1; i<=CONNECTIONS; i++)); do
    # Open a connection in the background and keep it alive
    nc -w 3600 "$TARGET" "$PORT" < /dev/null &
    if (( i % 1000 == 0 )); then
        echo "Opened $i connections..."
    fi
done

echo "Done. Check system state (e.g., 'ss -tunap | grep :10051' or 'netstat -tunap | grep :10051')."

```

To count all connections (both established and listening) on a specific port (e.g., port 10051):

```bash

ss -tuln | grep :10051 | wc -l
```

The simplest way to count nc instances is to check how many nc processes are running.

```bash

# ps aux: Lists all running processes.
# grep [n]c: Filters for nc processes (the square brackets prevent grep from matching itself).
# wc -l: Counts the number of matching lines (i.e., nc processes).
ps aux | grep [n]c | wc -l
797
# run the script again
1572

```

![Port exhaust ](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/port_exhaust.png)
### Stop simulate flow and nc


Use ps to locate the script’s process

```bash

# Use ps to locate the script’s process
ps aux | grep exhaust_local_10051.sh

# Look for a line that includes bash ./exhaust_local_10051.sh or similar. The second column in the output is the PID.
# user      # PID
imsdal      5544  0.0  0.0   7088  2176 pts/0    S+   20:44   0:00 grep --color=auto exhaust_local_10051.sh

# Use the kill command to terminate the script
kill <PID>

# The script spawns many nc (netcat) processes in the background (using &), each holding open a connection to port 10051. 
# Even after stopping the script, these processes will continue running and consuming resources (e.g., file descriptors, ephemeral ports). You need to terminate them as well.

# Use ps to list all running nc processes
ps aux | grep nc

# Instead of killing each nc process individually, you can use pkill to terminate all nc processes at once
pkill nc
7

# If some processes do not stop, you can force termination with
pkill -9 nc

# Check that no nc processes are still running
ps aux | grep nc

```




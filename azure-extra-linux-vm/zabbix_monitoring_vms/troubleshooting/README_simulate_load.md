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

## Simulate inbound flows Azure (many connections, trapper 10051)

In addition to bandwidth, the number of network connections present on a VM at any given time can affect its network performance. 
The Azure networking stack maintains state for each direction of a TCP/UDP connection in data structures called ‘flows’. 

A typical TCP/UDP connection has two flows created, one for the inbound and another for the outbound direction. 

https://learn.microsoft.com/en-us/azure/virtual-network/virtual-machine-network-throughput


Exhausting port 8080 on an Ubuntu system means consuming all available resources associated with that specific port, typically by opening as many connections as possible to it.

This is often done for stress testing, security research, or debugging purposes.

Step 2: Open Many Connections to Port 10051

Use a Bash script to open a large number of connections to port 10051 on localhost, consuming resources on both the client (ephemeral ports, file descriptors) and the server (connection slots, file descriptors).



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

![Port exhaust ](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/port_exhaust.jpg)


Run it 4 more times, it is now

```bash
ps aux | grep [n]c | wc -l
4372
```

Zabbix is down, jepp we got it.

![zabbix_dead ](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/zabbix_dead.jpg)




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



## Simulate much data for zabbix to calculate in value cache (trapper 10051) TODO

docker server (just a remote host), vmdocker01
Use zabbix_sender and make a bash script that has:

* Add and array for hosts, start with 5 hosts
* 30 items, tag-1 to tag-25, tag-1-str-status to tag-5-str-status
* 30 values each sec, use random 0-100
* 20 Numbers, 10 strings
* Loop until ctrl c

Total 5 x 30 = 90 each sec

Zabbix server,vmzabbix02

* Make a template with 30 items
* Add 30 triggers
* Use avg, last timespan 5 min, string contains etc


Check if w ehave zabbix sender vmdocker01

```bash

zabbix_sender -z 192.168.3.5 -s "simulatedhost01" -k tag1 -o 15
Response from "192.168.3.5:10051": "processed: 0; failed: 1; total: 1; seconds spent: 0.000017"
sent: 1; skipped: 0; total: 1

```

hm, is ufw open for 10051

```bash
ufw status
ERROR: You need to be root to run this script

sudo su
10051                      DENY        Anywhere

sudo ufw allow 10051
Rule updated
Rule updated (v6)


zabbix_sender -z 192.168.3.5 -s "simhost01" -k tag1 -o 15
Response from "192.168.3.5:10051": "processed: 1; failed: 0; total: 1; seconds spent: 0.000109"
sent: 1; skipped: 0; total: 1
```

Great, lets go to work.

![zabbix sender ok ](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/zabbix_sender.jpg)

### bash script with x host and x items flood port 10051


simulate_data_load_10051.sh

```bash

#!/bin/bash

# Zabbix server details
ZABBIX_SERVER="192.168.3.5"  # Replace with your Zabbix server IP/hostname
ZABBIX_PORT="10051"          # Default Zabbix trapper port

# Array of hostnames
HOSTS=("simhost01" "simhost02" "simhost03" "simhost04" "simhost05") 

# Number of iterations
ITERATIONS=120

# Pause between iterations (in seconds)
PAUSE=1

# Check if zabbix_sender is installed
if ! command -v zabbix_sender &> /dev/null; then
    echo "Error: zabbix_sender is not installed"
    exit 1
fi

# Function to generate random value between 1 and 100
generate_random_value() {
    echo $(( RANDOM % 100 + 1 ))
}

# Function to send data for a single host/item pair
send_single_item() {
    local host="$1"
    local item_key="$2"
    local value="$3"
    
    # Send the data using zabbix_sender with -s, -k, and -o options
    if zabbix_sender -z "$ZABBIX_SERVER" -p "$ZABBIX_PORT" -s "$host" -k "$item_key" -o "$value" > /dev/null 2>&1; then
        return 0
    else
        echo "Error sending $item_key: $value for $host"
        return 1
    fi
}

# Function to generate and send data for all hosts in one iteration
send_iteration_data() {
    local iteration="$1"
    local total_items=0
    local failed_items=0
    
    echo "Iteration $iteration of $ITERATIONS"
    
    # Process each host
    for host in "${HOSTS[@]}"; do
        echo "  Processing host: $host"
        
        # Process each item (tag1 to tag5)
        for item_num in {1..5}; do
            item_key="tag${item_num}"
            value=$(generate_random_value)
            
            echo "    Sending $item_key: $value"
            
            # Send the data for this host/item pair
            if ! send_single_item "$host" "$item_key" "$value"; then
                ((failed_items++))
            fi
            ((total_items++))
        done
    done
    
    # Summary for this iteration
    summary="Iteration $iteration: Total items attempted: $total_items, Failed items: $failed_items, Successful items: $((total_items - failed_items))"
    echo -e "\n  $summary"

    
    # Return success if no items failed
    [ "$failed_items" -eq 0 ]
}

# Main execution
echo -e "\nStarting Zabbix data sending loop..."
total_failed=0

# Loop for the specified number of iterations
for ((i=1; i<=ITERATIONS; i++)); do
    if ! send_iteration_data "$i"; then
        ((total_failed++))
    fi
    
    # Pause between iterations (skip pause on the last iteration)
    if [ "$i" -lt "$ITERATIONS" ]; then
        echo "  Pausing for $PAUSE second(s)..."
        sleep "$PAUSE"
    fi
done

# Final summary
echo -e "\nFinal Summary:"
echo "Total iterations: $ITERATIONS"
echo "Total items sent: $((ITERATIONS * ${#HOSTS[@]} * 5))"
echo "Iterations with failures: $total_failed"

if [ "$total_failed" -eq 0 ]; then
    echo "All data sent successfully across all iterations!"
else
    echo "Error: Some data failed to send to Zabbix server in $total_failed iteration(s)"
    exit 1
fi

exit 0
```

We created a template for test


![simulated_flood_template ](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/simulated_flood_template.jpg)


```bash

mkdir zabbix_simu_flood
sudo sudo nano 10051_simulate_data_load.sh

chmod +x 10051_simulate_data_load.sh
```


We now have the possbility to stress zabbix and trapper port 10051

![data load ](https://github.com/spawnmarvel/linux-and-azure/blob/main/azure-extra-linux-vm/zabbix_monitoring_vms/images/data_load.jpg)


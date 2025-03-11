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
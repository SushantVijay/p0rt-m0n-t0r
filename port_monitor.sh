#!/bin/bash

# Port Monitoring Tool
# Monitors open ports and alerts for new or closed ports.

MONITOR_INTERVAL=10  # Time in seconds between checks
PREVIOUS_PORTS_FILE="previous_ports.txt"

# Function to fetch current open ports
get_open_ports() {
    netstat -tuln | awk '{print $4}' | grep -Eo ':[0-9]+' | sed 's/://' | sort -n | uniq
}

# Function to compare port changes
compare_ports() {
    echo "Checking for port changes..."
    CURRENT_PORTS=$(get_open_ports)
    
    # If no previous port record exists, initialize it
    if [ ! -f "$PREVIOUS_PORTS_FILE" ]; then
        echo "$CURRENT_PORTS" > "$PREVIOUS_PORTS_FILE"
        echo "No previous data found. Monitoring initialized."
        return
    fi

    PREVIOUS_PORTS=$(cat "$PREVIOUS_PORTS_FILE")
    
    # Compare current and previous ports
    NEW_PORTS=$(comm -23 <(echo "$CURRENT_PORTS") <(echo "$PREVIOUS_PORTS"))
    CLOSED_PORTS=$(comm -13 <(echo "$CURRENT_PORTS") <(echo "$PREVIOUS_PORTS"))

    # Report changes
    if [ -n "$NEW_PORTS" ]; then
        echo "New open ports detected: $NEW_PORTS"
    fi

    if [ -n "$CLOSED_PORTS" ]; then
        echo "Ports closed: $CLOSED_PORTS"
    fi

    if [ -z "$NEW_PORTS" ] && [ -z "$CLOSED_PORTS" ]; then
        echo "No changes in open ports."
    fi

    # Update previous ports file
    echo "$CURRENT_PORTS" > "$PREVIOUS_PORTS_FILE"
}

# Monitoring loop
echo "Starting Port Monitoring Tool..."
while true; do
    compare_ports
    sleep "$MONITOR_INTERVAL"
done

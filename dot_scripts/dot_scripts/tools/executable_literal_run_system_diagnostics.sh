#!/bin/bash

while true; do
    clear
    echo "=== System Monitor ==="
    echo "Time: $(date)"
    echo "----------------------"
    
    # CPU & Memory Usage
    echo "[CPU & Memory Usage]"
    top -b -n1 | head -n 10
    
    echo "----------------------"
    
    # Disk Usage
    echo "[Disk Usage]"
    df -h | grep -E '^/dev/'
    
    echo "----------------------"

    # Network Activity
    echo "[Network Usage]"
    ip -s link | awk '/^[0-9]+:/ {print $2} /RX:/ {print "  RX: " $2 " bytes"} /TX:/ {print "  TX: " $2 " bytes"}'

    echo "----------------------"
    echo "Press Ctrl+C to exit."
    
    sleep 1
done

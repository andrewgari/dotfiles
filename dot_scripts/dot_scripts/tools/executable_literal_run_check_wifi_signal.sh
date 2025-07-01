#!/bin/bash

INTERFACE="wlan0"  # Change to your Wi-Fi interface name

while true; do
    clear
    echo "=== Wi-Fi Signal Strength ==="
    iwconfig $INTERFACE | grep -i --color signal
    sleep 1
done

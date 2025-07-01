#!/bin/bash

echo "=== Network Diagnostics ==="

# Check IP Address
echo -e "\n[+] IP Address:"
ip addr show | grep "inet " | grep -v "127.0.0.1"

# Check Default Gateway
echo -e "\n[+] Default Gateway:"
ip route | grep default

# Check Internet Connectivity
echo -e "\n[+] Checking Internet Connectivity..."
ping -c 4 8.8.8.8

# Check DNS Resolution
echo -e "\n[+] Checking DNS Resolution..."
nslookup google.com 8.8.8.8

# Check Open Ports
echo -e "\n[+] Open Ports:"
sudo netstat -tulnp | grep LISTEN

echo -e "\n[+] Done!"

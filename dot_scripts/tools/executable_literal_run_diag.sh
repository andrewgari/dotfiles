#!/bin/bash

# Define output file
OUTPUT_FILE="fedora_diagnostics_$(date +%F_%T).log"

# ANSI color codes
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
RESET='\033[0m'

# Function to print section headers in color
print_section() {
    echo -e "${CYAN}=== $1 ===${RESET}" | tee -a $OUTPUT_FILE
}

# Function to print subsections
print_subsection() {
    echo -e "${YELLOW}[+] $1:${RESET}" | tee -a $OUTPUT_FILE
}

# Start diagnostics
print_section "Fedora System Diagnostics"
echo -e "${BLUE}Date:${RESET} $(date)" | tee -a $OUTPUT_FILE
echo -e "${BLUE}Hostname:${RESET} $(hostname)" | tee -a $OUTPUT_FILE
echo "----------------------------------------" | tee -a $OUTPUT_FILE

# System Uptime
print_subsection "System Uptime"
uptime | tee -a $OUTPUT_FILE
echo "----------------------------------------" | tee -a $OUTPUT_FILE

# CPU & Memory Usage
print_subsection "CPU Load & Memory Usage"
top -b -n1 | head -n 10 | tee -a $OUTPUT_FILE
echo "----------------------------------------" | tee -a $OUTPUT_FILE

# Disk Space Usage
print_subsection "Disk Space Usage"
df -h | tee -a $OUTPUT_FILE
echo "----------------------------------------" | tee -a $OUTPUT_FILE

# Network Configuration
print_subsection "Network Configuration (IP Addresses & Routes)"
ip addr | tee -a $OUTPUT_FILE
echo "" | tee -a $OUTPUT_FILE
ip route | tee -a $OUTPUT_FILE
echo "----------------------------------------" | tee -a $OUTPUT_FILE

# Check Active Systemd Services
print_subsection "Active Systemd Services (Failed or Critical)"
FAILED_SERVICES=$(systemctl list-units --failed | grep "●" | wc -l)
if [[ $FAILED_SERVICES -gt 0 ]]; then
    echo -e "${RED}WARNING: There are $FAILED_SERVICES failed services!${RESET}" | tee -a $OUTPUT_FILE
    systemctl list-units --failed | tee -a $OUTPUT_FILE
else
    echo -e "${GREEN}All services are running normally.${RESET}" | tee -a $OUTPUT_FILE
fi
echo "----------------------------------------" | tee -a $OUTPUT_FILE

# Mounted Filesystems (including NFS)
print_subsection "Mounted Filesystems"
mount | grep -E 'nfs|ext4|btrfs|zfs' | tee -a $OUTPUT_FILE
echo "----------------------------------------" | tee -a $OUTPUT_FILE

# Docker & Podman Status (If Installed)
if command -v docker &> /dev/null; then
    print_subsection "Docker Status"
    sudo systemctl is-active docker | tee -a $OUTPUT_FILE
    docker ps -a | tee -a $OUTPUT_FILE
    echo "----------------------------------------" | tee -a $OUTPUT_FILE
fi

if command -v podman &> /dev/null; then
    print_subsection "Podman Status"
    sudo systemctl is-active podman | tee -a $OUTPUT_FILE
    podman ps -a | tee -a $OUTPUT_FILE
    echo "----------------------------------------" | tee -a $OUTPUT_FILE
fi

# GPU Information (If Available)
if command -v nvidia-smi &> /dev/null; then
    print_subsection "NVIDIA GPU Information"
    nvidia-smi | tee -a $OUTPUT_FILE
    echo "----------------------------------------" | tee -a $OUTPUT_FILE
elif command -v glxinfo &> /dev/null; then
    print_subsection "OpenGL GPU Information"
    glxinfo | grep "OpenGL renderer string" | tee -a $OUTPUT_FILE
    echo "----------------------------------------" | tee -a $OUTPUT_FILE
fi

# Last 20 System Logs (For Errors)
print_subsection "Last 20 System Logs (Errors & Warnings)"
journalctl -p 3 -n 20 --no-pager | tee -a $OUTPUT_FILE
echo "----------------------------------------" | tee -a $OUTPUT_FILE

# Summary
echo -e "${GREEN}[+] Diagnostics saved to $OUTPUT_FILE${RESET}"
echo -e "Run ${YELLOW}cat $OUTPUT_FILE${RESET} to review results."

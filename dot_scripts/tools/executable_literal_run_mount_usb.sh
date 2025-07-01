#!/bin/bash

MOUNT_POINT="/mnt/usb"

# Ensure mount point exists
mkdir -p "$MOUNT_POINT"

# Detect USB drive
DEVICE=$(lsblk -o NAME,MOUNTPOINT,TYPE | grep -E 'disk$' | awk '{print "/dev/" $1}' | head -n 1)

if [ -z "$DEVICE" ]; then
    echo "No USB drive detected."
    exit 1
fi

echo "Mounting $DEVICE at $MOUNT_POINT..."
sudo mount "$DEVICE" "$MOUNT_POINT"

if [ $? -eq 0 ]; then
    echo "Successfully mounted $DEVICE at $MOUNT_POINT"
else
    echo "Failed to mount $DEVICE"
fi

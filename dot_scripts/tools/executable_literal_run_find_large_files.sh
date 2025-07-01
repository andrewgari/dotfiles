#!/bin/bash

echo "=== Finding Large Files (Over 1GB) ==="
find / -type f -size +1G -exec ls -lh {} + 2>/dev/null | awk '{print $9 ": " $5}'

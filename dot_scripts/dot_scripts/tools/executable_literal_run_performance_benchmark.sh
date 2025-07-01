#!/bin/bash

echo "=== CPU Benchmark ==="
sysbench cpu --threads=4 run

echo "=== Memory Benchmark ==="
sysbench memory --threads=4 run

echo "=== Disk Benchmark ==="
dd if=/dev/zero of=tempfile bs=1M count=1024 oflag=direct
rm tempfile

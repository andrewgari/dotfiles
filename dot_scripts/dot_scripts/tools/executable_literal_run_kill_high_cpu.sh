#!/bin/bash

echo "Top CPU-using processes:"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 10

echo "Enter PID to kill (or press Enter to exit):"
read PID

if [ -n "$PID" ]; then
    kill -9 "$PID"
    echo "Process $PID killed."
else
    echo "No process killed."
fi

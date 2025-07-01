#!/bin/bash

set -e  # Exit on error

0 2 1 * * flock -n /tmp/drives-backup.lock /home/andrewgari/.scripts/drives-backup.sh >> /home/andrewgari/.logs/backup.log 2>&1

echo "CRON Job Started"
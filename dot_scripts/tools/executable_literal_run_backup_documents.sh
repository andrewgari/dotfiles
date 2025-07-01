#!/bin/bash

SOURCE_DIR="$HOME/Documents"
BACKUP_DIR="/mnt/unraid/backup"
LOG_FILE="$HOME/backup.log"

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

echo "Starting backup at $(date)" | tee -a "$LOG_FILE"
rsync -avh --progress "$SOURCE_DIR" "$BACKUP_DIR" | tee -a "$LOG_FILE"
echo "Backup completed at $(date)" | tee -a "$LOG_FILE"

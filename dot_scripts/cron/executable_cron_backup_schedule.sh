#!/bin/bash

set -e  # Exit on error

BACKUP_DIR="/mnt/unraid/andrew"
LOG_FILE="$HOME/home_backup.log"
CRON_FILE="/etc/cron.d/system_crons"

setup_cron_jobs() {
    echo "Setting up cron jobs..."
    sudo bash -c "cat > $CRON_FILE" <<EOF
# Home directory backup - Every Sunday at midnight
0 0 * * 0 rsync -a --exclude='.cache' --exclude='Downloads' /home/ $BACKUP_DIR >> $LOG_FILE 2>&1

# System updates - Every Sunday at 3 AM
0 3 * * 0 sudo dnf upgrade -y >> $HOME/system_update.log 2>&1

# Btrfs Scrub - 1st of every month at 2 AM
0 2 1 * * sudo btrfs scrub start -Bd / >> $HOME/btrfs_scrub.log 2>&1

# Disk Usage Monitoring - Every Monday at 6 AM
0 6 * * 1 df -h | mail -s "Disk Usage Report" covadax.ag@gmail.com

# Log Cleanup - Every Saturday at midnight
0 0 * * 6 find /var/log -type f -mtime +30 -exec rm -f {} \;

# Git Dotfiles Auto-Backup - Every Friday at midnight
0 0 * * 5 cd $HOME/.dotfiles && git add . && git commit -m "Auto backup" && git push

# Docker Cleanup - Every Sunday at 4 AM
0 4 * * 0 docker system prune -af >> $HOME/docker_cleanup.log 2>&1

# VSCode Extensions Sync - Every Sunday at midnight
0 0 * * 0 code --list-extensions > $HOME/vscode_extensions.txt
EOF
    
    sudo chmod 644 "$CRON_FILE"
    sudo systemctl restart cron || sudo systemctl restart crond
}

setup_cron_jobs

echo "Cron jobs set up successfully!"


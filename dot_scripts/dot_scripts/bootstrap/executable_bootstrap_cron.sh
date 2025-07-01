#!/bin/bash

# Detect OS and set correct `date` format
if [[ "$OSTYPE" == "darwin"* ]]; then
    DATE_CMD='date "+%Y-%m-%d %H:%M:%S"'
else
    DATE_CMD='date --iso-8601=seconds'
fi

# Detect correct cron command
if [[ "$OSTYPE" == "darwin"* ]]; then
    CRON_CMD="crontab -l 2>/dev/null"
    RESTART_CMD="launchctl kickstart -k system/com.vix.cron"
else
    CRON_CMD="crontab -l 2>/dev/null"
    RESTART_CMD="systemctl --user restart cron || sudo systemctl restart cron"
fi

# Define cron jobs safely
CRON_JOBS=(
    "*/15 * * * * $HOME/.scripts/tools/run_dotfiles_sync.sh"
    "0 4 * * 0 journalctl --vacuum-time=7d && rm -rf ~/.cache/*"
    "0 5 * * 0 fstrim -av"
    "0 2 * * * rsync -av --exclude=Vault --exclude=Games/foundryvtt --exclude=Shared --exclude=Unraid --exclude=Videos/unRAID --exclude=Pictures/unRAID --exclude=Games/unRAID --one-file-system ~ /mnt/unraid/andrew/backup/home/"
    "0 1 * * * rsync -av ~/dotfiles /mnt/unraid/andrew/backup/dotfiles/"
    "*/5 * * * * command -v moonlight &>/dev/null && ! pgrep moonlight && moonlight stream -app Steam"
    "*/5 * * * * ping -c 1 8.8.8.8 &>/dev/null || (command -v notify-send &>/dev/null && notify-send '🌐 Internet Connection Lost!')"
    "*/10 * * * * uptime | awk '{if (\$10 > 2.0) print strftime(\"%Y-%m-%d %H:%M:%S\"), \"⚠️ High CPU Load: \"\$10}' >> /mnt/unraid/andrew/backup/cpu_load.log && notify-send '⚠️ High CPU Load detected!'"
    "*/30 * * * * df -h | awk '\$5 > 90 {print \"🚨 Low Disk Space on \"\$6\": \"\$5}' | mail -s 'Disk Space Warning!' covadax.ag@gmail.com"
    "*/10 * * * * command -v mountpoint &>/dev/null && ! mountpoint -q /mnt/unraid && systemctl restart mnt-unraid-data.mount && notify-send '🔄 Remounted Unraid Share'"
    "0 1 * * * find ~/Downloads -type f -size +2G -mtime +30 -exec mv {} /mnt/unraid/andrew/backup/old_downloads/ \\;"
    "0 4 * * * find /var/log -type f -mtime +7 -exec rm -f {} \\;"
    "0 5 * * * rsync -av ~/.ssh /mnt/unraid/andrew/backup/ssh_keys/"
    "0 9 * * * command -v curl &>/dev/null && command -v jq &>/dev/null && curl -s https://api.quotable.io/random | jq -r '.content + \" - \" + .author' | notify-send '🌟 Daily Motivation'"
    "*/5 * * * * (ping -c 1 192.168.50.3 &>/dev/null || (sleep 30 && ping -c 1 192.168.50.3 &>/dev/null) || { TIMESTAMP=\$($DATE_CMD); MESSAGE=\"🚨 [Unraid Down] - \$TIMESTAMP: Unraid (192.168.50.3) is unreachable.\"; echo \"\$MESSAGE\" >> /mnt/unraid/andrew/backup/unraid_status.log; command -v notify-send &>/dev/null && notify-send \"\$MESSAGE\"; [[ \"\$(uname)\" == \"Darwin\" ]] && osascript -e \"display notification \\\"\$MESSAGE\\\" with title \\\"Unraid Alert\\\"\"; command -v mail &>/dev/null && echo \"\$MESSAGE\" | mail -s \"🚨 Unraid Down Alert\" covadax.ag@gmail.com; command -v sendmail &>/dev/null && echo -e \"Subject: 🚨 Unraid Down Alert\\n\\n\$MESSAGE\" | sendmail covadax.ag@gmail.com; })"
    "0 */12 * * * rsync -a ~/.mozilla/firefox/*.default*/bookmarkbackups/ /mnt/unraid/andrew/backup/firefox_bookmarks/"
    "0 3 * * 0 docker system prune -af --volumes"
    "0 2 * * 1 find \$HOME -name '*.log' -mtime +30 -exec gzip {} \\;"
    "0 */2 * * * grep 'Failed password' /var/log/auth.log | tail -n 5 | mail -s 'Failed SSH Attempts' covadax.ag@gmail.com"
    "0 0 * * 0 dpkg --get-selections > /mnt/unraid/andrew/backup/pkg-list-\$(date +\\%Y\\%m\\%d).txt"
    "*/5 * * * * lsusb > /tmp/current_usb; diff /tmp/previous_usb /tmp/current_usb && notify-send '🔌 New USB Device Detected'; mv /tmp/current_usb /tmp/previous_usb"
    "0 3 * * * systemctl --user list-units --failed --no-pager | mail -s 'Failed Services Report' covadax.ag@gmail.com"
    "*/15 * * * * sensors | grep -E 'Core|Package' | awk '{if (\$3 > 80) system(\"notify-send '\''🌡️ High CPU Temperature: \"\$3\"°C'\''\")'}'"
    "*/30 * * * * ps axo stat,ppid,pid,comm | awk '\$1~/^Z/ { print \$2 }' | xargs -r kill -9"
    "*/10 * * * * ping -c 3 192.168.50.3 | tail -1 | awk '{print \$4}' | cut -d '/' -f 2 | awk '{ if (\$1 > 100) system(\"notify-send '\''⚠️ High Network Latency: \"\$1\"ms'\''\") }'"
    "*/15 * * * * host google.com >/dev/null || notify-send '🌐 DNS Resolution Failed!'"
)

CRON_JOB_FILE="/tmp/current_cron"

echo "🔍 Checking and updating cron jobs..."

# Backup existing crontab
$CRON_CMD > "$CRON_JOB_FILE" 2>/dev/null || touch "$CRON_JOB_FILE"

# Ensure new cron jobs are added safely
UPDATED=false
for job in "${CRON_JOBS[@]}"; do
    if grep -Fxq "$job" "$CRON_JOB_FILE"; then
        echo "✅ Cron job exists: ${job:0:50}..."
    else
        echo "🆕 Adding cron job: ${job:0:50}..."
        echo "$job" >> "$CRON_JOB_FILE"
        UPDATED=true
    fi
done

# Apply new crontab if changes were made
if [ "$UPDATED" = true ]; then
    crontab "$CRON_JOB_FILE"
    echo "✅ Cron jobs updated."
else
    echo "✅ No changes needed."
fi

# Ensure cron service is running correctly
echo "🔄 Restarting cron service..."
eval "$RESTART_CMD"
echo "✅ Cron service restarted."

# Clean up temp file
rm -f "$CRON_JOB_FILE"
echo "🎉 Cron job bootstrap complete!"


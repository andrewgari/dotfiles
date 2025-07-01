#!/bin/bash

set -e  # Exit on error

setup_btrfs_optimizations() {
    echo "Setting up BTRFS optimizations..."

    # List all Btrfs mounts except /mnt
    MOUNTS=$(findmnt -t btrfs -n -o TARGET | grep -v "^/mnt$")

    for mount in $MOUNTS; do
        echo "Running maintenance on $mount..."

        echo "Defragmenting $mount..."
        sudo btrfs filesystem defragment -r "$mount"

        echo "Starting balance on $mount..."
        sudo btrfs balance start "$mount"

        echo "Starting scrub on $mount..."
        sudo btrfs scrub start "$mount"

        echo "Completed maintenance on $mount."
    done
}

setup_btrfs_snapshots() {
    echo "Setting up BTRFS snapshots..."
    HOSTNAME=$(hostname)

    SNAPSHOT_DIR="/var/backups/snapshots/$HOSTNAME"
    SNAPSHOT_PATH="$SNAPSHOT_DIR/snapshot-$(date +%Y%m%d-%H%M%S)"

    # Ensure the snapshot directory exists
    sudo mkdir -p "$SNAPSHOT_DIR"

    echo "Creating snapshot of '/home' in '$SNAPSHOT_PATH'"
    sudo btrfs subvolume snapshot -r /home "$SNAPSHOT_PATH"
}

push_snapshots_to_unraid() {
    echo "Pushing snapshots to NFS share..."
    HOSTNAME=$(hostname)
    
    LOCAL_PATH="/var/backups/snapshots/$HOSTNAME/"
    NFS_PATH="/mnt/unraid/vault/backup/snapshots/$HOSTNAME"

    # Ensure the NFS share is mounted
    if ! mount | grep -q "/mnt/unraid/vault"; then
        echo "NFS share is not mounted! Attempting to mount..."
        sudo mount -t nfs 192.168.50.3:/mnt/user/vault /mnt/unraid/vault
    fi

    # Ensure the NFS backup directory exists
    mkdir -p "$NFS_PATH"

    echo "Syncing snapshot to NFS..."
    sudo rsync -a --delete --no-perms --omit-dir-times \
    --exclude={"/boot/*","/dev/*","/etc/*","/proc/*","/sys/*","/tmp/*","/run/*","/var/run/*","/var/lock/*"} \
    "$LOCAL_PATH" "$NFS_PATH/"


    # Keep only the most recent 10 snapshots
    echo "Pruning old snapshots..."
    cd "$NFS_PATH" || exit
    ls -1t | grep 'snapshot-' | tail -n +11 | xargs -I {} rm -rf {}

    echo "Snapshot push complete!"
}

# setup_btrfs_optimizations
setup_btrfs_snapshots
push_snapshots_to_unraid

echo "BTRFS optimizations, and snapshots setup completed!"

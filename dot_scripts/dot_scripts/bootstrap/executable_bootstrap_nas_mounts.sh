#!/bin/bash

set -e  # Exit on error

setup_unraid() {
    echo "Setting up NFS shares using systemd..."
    sudo mkdir -p /mnt/unraid/{data,foundryvtt,vault,andrew,shared}

    for share in data foundryvtt vault andrew shared; do
        MOUNT_UNIT="/etc/systemd/system/mnt-unraid-${share}.mount"
        AUTOMOUNT_UNIT="/etc/systemd/system/mnt-unraid-${share}.automount"

        echo "Creating systemd .mount unit for $share..."
        sudo bash -c "cat > $MOUNT_UNIT" <<EOF
[Unit]
Description=NFS mount for $share
After=network-online.target
Wants=network-online.target

[Mount]
What=192.168.50.3:/mnt/user/$share
Where=/mnt/unraid/$share
Type=nfs
Options=defaults,noatime,nofail,_netdev,x-systemd.automount

[Install]
WantedBy=multi-user.target
EOF

        echo "Creating systemd .automount unit for $share..."
        sudo bash -c "cat > $AUTOMOUNT_UNIT" <<EOF
[Unit]
Description=Automount for $share
After=network-online.target
Wants=network-online.target

[Automount]
Where=/mnt/unraid/$share

[Install]
WantedBy=multi-user.target
EOF

        # Reload systemd and enable both mount and automount
        echo "Enabling and starting systemd automount for $share..."
        sudo systemctl daemon-reload
        sudo systemctl enable --now "mnt-unraid-${share}.automount"
        sudo systemctl enable "mnt-unraid-${share}.mount"  # Don't start, automount handles it
    done

    echo "All NFS shares are configured with .mount and .automount files!"
}

setup_hardlinks() {
    echo "Setting up hardlinks (symlinks)..."

    # Ensure /mnt/unraid exists
    sudo mkdir -p /mnt/unraid

    # Define paths as associative arrays (Bash 4+)
    declare -A paths=(
        ["$HOME/Games/unraid"]="/mnt/unraid/data/media/games"
        ["$HOME/Videos/unraid"]="/mnt/unraid/data/media/videos"
        ["$HOME/Pictures/unraid"]="/mnt/unraid/data/media/photos"
        ["$HOME/foundryvtt"]="/mnt/unraid/foundryvtt"
        ["$HOME/Vault"]="/mnt/unraid/vault"
    )

    for target in "${!paths[@]}"; do
        src="${paths[$target]}"

        # Ensure the target's parent directory exists
        mkdir -p "$(dirname "$target")"

        # If target exists but is not a symlink, remove it
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            echo "Warning: $target exists but is not a symlink. Removing and replacing it..."
            rm -rf "$target"
        fi

        # Create symlink if it does not exist or is incorrect
        if [ -L "$target" ] && [ "$(readlink -f "$target")" == "$src" ]; then
            echo "Symlink $target already exists and is correct. Skipping..."
        else
            echo "Creating symlink: $target → $src"
            ln -s "$src" "$target"
        fi
    done

    echo "Hardlink setup complete!"
}

setup_unraid
setup_hardlinks

echo "NFS shares (systemd), symlinks, and optimizations setup completed!"


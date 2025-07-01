#!/bin/bash

set -e  # Exit on error

# Define variables
REPO_URL="git@github.com:andrewgari/.dotfiles"
TARGET_DIR="$HOME/Repos/.dotfiles"
SYSTEMD_DIR="$TARGET_DIR/systemd"
BACKUP_DIR="$HOME/backups/$(date +'%Y-%m-%d_%H-%M-%S')"

# Ensure ~/Repos exists
mkdir -p "$HOME/Repos"

# Clone the repository
clone_dotfiles() {
    if [ -d "$TARGET_DIR" ]; then
        echo "Repository already exists at $TARGET_DIR. Pulling latest changes..."
        git -C "$TARGET_DIR" pull
    else
        echo "Cloning repository into $TARGET_DIR..."
        git clone "$REPO_URL" "$TARGET_DIR"
    fi
}

# Backup existing files before replacing
backup_files() {
    echo "Backing up existing dotfiles to $BACKUP_DIR..."
    mkdir -p "$BACKUP_DIR"
    for file in $(ls -A "$TARGET_DIR"); do
        if [ "$file" != "systemd" ] && [ -e "$HOME/$file" ]; then
            mv "$HOME/$file" "$BACKUP_DIR/"
            echo "Backed up $file to $BACKUP_DIR/"
        fi
    done
}

# Copy systemd files to their correct locations
install_systemd_files() {
    echo "Installing systemd files..."

    # Check systemd location
    SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
    SYSTEMD_SYSTEM_DIR="/etc/systemd/system"

    mkdir -p "$SYSTEMD_USER_DIR"

    for file in "$SYSTEMD_DIR"/*; do
        if [[ $file == *.mount || $file == *.automount ]]; then
            if [ -w "$SYSTEMD_SYSTEM_DIR" ]; then
                sudo cp "$file" "$SYSTEMD_SYSTEM_DIR/"
                echo "Installed $(basename "$file") to $SYSTEMD_SYSTEM_DIR/"
            else
                cp "$file" "$SYSTEMD_USER_DIR/"
                echo "Installed $(basename "$file") to $SYSTEMD_USER_DIR/"
            fi
        fi
    done

    echo "Reloading systemd daemon..."
    systemctl --user daemon-reload
    sudo systemctl daemon-reload
}

# Copy remaining dotfiles to home directory
apply_dotfiles() {
    echo "Copying dotfiles to home directory..."
    cp -r "$TARGET_DIR"/. "$HOME/"
    echo "Dotfiles applied!"
}

# Main function
main() {
    clone_dotfiles
    backup_files
    install_systemd_files
    apply_dotfiles
    echo "Dotfiles setup complete!"
}

# Run script
main

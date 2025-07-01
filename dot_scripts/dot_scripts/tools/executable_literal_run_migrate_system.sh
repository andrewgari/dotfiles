#!/bin/bash

set -e  # Exit on error

BACKUP_DIR="/mnt/unraid/vault/backup/system_migration"
HOSTNAME=$(hostname)
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_PATH="$BACKUP_DIR/$HOSTNAME-$TIMESTAMP"

backup_home() {
    echo "Backing up home directory..."
    mkdir -p "$BACKUP_PATH/home"
    rsync -a --exclude=".cache" --exclude="Downloads" "$HOME/" "$BACKUP_PATH/home/"
}

backup_dotfiles() {
    echo "Backing up dotfiles..."
    mkdir -p "$BACKUP_PATH/dotfiles"
    rsync -a "$HOME/.zshrc" "$HOME/.vimrc" "$HOME/.gitconfig" "$HOME/.config/nvim" "$HOME/.config/kitty" "$BACKUP_PATH/dotfiles/"
}

backup_packages() {
    echo "Backing up installed packages..."
    mkdir -p "$BACKUP_PATH/packages"
    if command -v dnf &> /dev/null; then
        rpm -qa > "$BACKUP_PATH/packages/dnf-packages.txt"
    elif command -v apt &> /dev/null; then
        dpkg --get-selections > "$BACKUP_PATH/packages/apt-packages.txt"
    elif command -v pacman &> /dev/null; then
        pacman -Qe > "$BACKUP_PATH/packages/pacman-packages.txt"
    fi
}

backup_ssh_keys() {
    echo "Backing up SSH keys..."
    mkdir -p "$BACKUP_PATH/ssh"
    rsync -a "$HOME/.ssh/" "$BACKUP_PATH/ssh/"
}

backup_vscode_extensions() {
    echo "Backing up VSCode extensions..."
    mkdir -p "$BACKUP_PATH/vscode"
    code --list-extensions > "$BACKUP_PATH/vscode/extensions.txt"
}

backup_nvim_plugins() {
    echo "Backing up Neovim plugins..."
    mkdir -p "$BACKUP_PATH/nvim"
    rsync -a "$HOME/.local/share/nvim/site/" "$BACKUP_PATH/nvim/"
}

backup_home
backup_dotfiles
backup_packages
backup_ssh_keys
backup_vscode_extensions
backup_nvim_plugins

echo "System migration backup completed! Backup stored at: $BACKUP_PATH"

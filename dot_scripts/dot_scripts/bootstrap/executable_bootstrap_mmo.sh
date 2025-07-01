#!/bin/bash

set -e  # Exit on error

install_lutris() {
    echo "Installing Lutris..."
    if command -v dnf &> /dev/null; then
        sudo dnf install -y lutris
    elif command -v apt &> /dev/null; then
        sudo add-apt-repository ppa:lutris-team/lutris -y
        sudo apt update && sudo apt install -y lutris
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm lutris
    else
        echo "Unsupported package manager. Install Lutris manually."
        exit 1
    fi
}

install_xivlauncher() {
    echo "Installing XIVLauncher..."
    mkdir -p "$HOME/Games/FFXIV"
    
    if command -v yay &> /dev/null; then
        yay -S --noconfirm xivlauncher-git
    elif command -v paru &> /dev/null; then
        paru -S --noconfirm xivlauncher-git
    else
	flatpak install flathub dev.goats.xivlauncher
        echo "Please install an AUR helper like yay or paru."
    fi
}

install_wow() {
    echo "Installing World of Warcraft via Lutris..."
    lutris -i https://lutris.net/api/installers/world-of-warcraft & disown
    echo "Lutris is running in the background. Continue installation..."
}

configure_games() {
    echo "Configuring XIVLauncher and WoW..."
    
    # XIVLauncher Setup
    echo "Setting up XIVLauncher..."
    mkdir -p "$HOME/.config/XIVLauncher"
    
    # WoW Setup
    echo "Setting up World of Warcraft..."
    mkdir -p "$HOME/Games/WorldOfWarcraft"
}

backup_game_configs() {
    echo "Backing up game configurations..."
    BACKUP_DIR="/mnt/unraid/vault/backup/games"
    
    mkdir -p "$BACKUP_DIR/FFXIV"
    mkdir -p "$BACKUP_DIR/WoW"
    
    rsync -a "$HOME/.config/XIVLauncher/" "$BACKUP_DIR/FFXIV/"
    rsync -a "$HOME/Games/WorldOfWarcraft/" "$BACKUP_DIR/WoW/"
    
    echo "Backup completed!"
}

install_lutris
install_xivlauncher
install_wow
configure_games
backup_game_configs

echo "Final Fantasy XIV (XIVLauncher) and World of Warcraft installation and backup completed!"


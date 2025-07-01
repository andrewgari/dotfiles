#!/bin/bash

set -e  # Exit on error

# Install 1Password based on the system package manager
install_1password() {
    echo "🔒 Installing 1Password..."
    
    # Detect package manager
    if [[ "$(uname)" == "Darwin" ]]; then
        PACKAGE_MANAGER="brew"
    elif command -v dnf &>/dev/null; then
        PACKAGE_MANAGER="dnf"
    elif command -v yay &>/dev/null; then
        PACKAGE_MANAGER="yay"
    elif command -v pacman &>/dev/null; then
        PACKAGE_MANAGER="pacman"
    elif command -v apt &>/dev/null; then
        PACKAGE_MANAGER="apt"
    else
        echo "❌ Unsupported package manager" >&2
        exit 1
    fi

    case "$PACKAGE_MANAGER" in
        brew)
            brew install --cask 1password
            ;;
        dnf)
            # Add the 1Password yum repo
            sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
            sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://downloads.1password.com/linux/keys/1password.asc" > /etc/yum.repos.d/1password.repo'
            sudo dnf install -y 1password
            ;;
        apt)
            # Add the key for the 1Password apt repository
            curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
                sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg

            # Add the 1Password apt repository
            echo "deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main" | \
                sudo tee /etc/apt/sources.list.d/1password.list

            # Add the debsig-verify policy
            sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
            curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
                sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
            sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
            curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
                sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg

            # Install 1Password
            sudo apt update && sudo apt install -y 1password
            ;;
        yay|pacman)
            # Install using yay from AUR
            yay -S --noconfirm 1password
            ;;
    esac
}

# Execute installation if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_1password
fi 
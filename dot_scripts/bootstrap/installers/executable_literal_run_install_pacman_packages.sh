#!/bin/bash

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_DIR="$(cd "$SCRIPT_DIR/../../" && pwd)/packages"

# Check if running on a Pacman-based system
if ! command -v pacman &>/dev/null; then
    echo "❌ Error: Pacman package manager not found. This script is for Pacman-based systems only."
    exit 1
fi

# Source package definitions
source "$PACKAGES_DIR/pacman_packages.sh"

echo "📦 Installing Pacman packages..."
sudo pacman -Syu --noconfirm $(get_pacman_packages)

echo "✅ Pacman packages installation completed!" 
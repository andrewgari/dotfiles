#!/bin/bash

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_DIR="$(cd "$SCRIPT_DIR/../../" && pwd)/packages"

# Check if running on an APT-based system
if ! command -v apt &>/dev/null; then
    echo "❌ Error: APT package manager not found. This script is for APT-based systems only."
    exit 1
fi

# Source package definitions
source "$PACKAGES_DIR/apt_packages.sh"

echo "📦 Installing APT packages..."
sudo apt update
sudo apt install -y $(get_apt_packages)

echo "✅ APT packages installation completed!" 
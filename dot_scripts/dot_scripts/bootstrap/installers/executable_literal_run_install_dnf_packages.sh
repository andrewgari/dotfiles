#!/bin/bash

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)/packages"

# Check if running on a DNF-based system
if ! command -v dnf &>/dev/null; then
    echo "❌ Error: DNF package manager not found. This script is for DNF-based systems only."
    exit 1
fi

# Source package definitions
source "$PACKAGES_DIR/dnf_packages.sh"

# Enable RPM Fusion repositories
echo "📦 Setting up RPM Fusion repositories..."
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                   https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Setup additional repositories
echo "📦 Setting up additional repositories..."
setup_dnf_repos

# Update package list
echo "📦 Updating package list..."
sudo dnf check-update || true  # Don't fail if updates are available

echo "📦 Installing DNF packages..."
sudo dnf install -y --skip-unavailable $(get_dnf_packages)

echo "✅ DNF packages installation completed!" 
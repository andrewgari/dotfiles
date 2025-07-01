#!/bin/bash

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_DIR="$(cd "$SCRIPT_DIR/../../" && pwd)/packages"

# Check if flatpak is installed
if ! command -v flatpak &>/dev/null; then
    echo "❌ Error: Flatpak not found. Please install flatpak first."
    exit 1
fi

# Source package definitions
source "$PACKAGES_DIR/flatpak_packages.sh"

# Add Flathub repository if not already added
echo "📦 Setting up Flatpak..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true

# Install each Flatpak package
for app in "${!FLATPAK_PACKAGES[@]}"; do
    package_name="${FLATPAK_PACKAGES[$app]}"
    if ! flatpak list --user | grep -q "$package_name"; then
        echo "🚀 Installing: $app ($package_name)"
        if ! flatpak install --user -y --noninteractive "$package_name" 2>/tmp/flatpak_error.log; then
            echo "❌ Failed to install: $app ($package_name)"
            echo "💡 Command: flatpak install --user -y --noninteractive $package_name"
            echo "🔍 Error Details:"
            cat /tmp/flatpak_error.log
        else
            echo "✅ Installed: $app ($package_name)"
        fi
    else
        echo "✔ Already installed: $app ($package_name)"
    fi
done

echo "✅ Flatpak packages installation completed!" 
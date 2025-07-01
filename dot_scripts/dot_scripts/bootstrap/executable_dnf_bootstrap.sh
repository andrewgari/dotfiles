#!/bin/bash

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)/packages"

# Source package definitions
source "$PACKAGES_DIR/dnf_packages.sh"
source "$PACKAGES_DIR/flatpak_packages.sh"

echo "📦 Installing DNF packages..."
sudo dnf install -y --skip-unavailable $(get_dnf_packages)

# Install Flatpak applications
echo "📦 Installing Flatpak applications..."
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

# Install external applications
source "$SCRIPT_DIR/external_apps.sh"
install_external_apps

echo "🎉 DNF bootstrap completed! Reboot recommended." 
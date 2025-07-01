#!/bin/bash

echo "🔍 Finding all system-installed Flatpaks..."
flatpak list --system --columns=application > /tmp/system-flatpaks.txt

if [[ ! -s /tmp/system-flatpaks.txt ]]; then
    echo "✅ No system-wide Flatpaks found. Exiting."
    exit 0
fi

echo "💾 Backing up Flatpak user data..."
mkdir -p ~/.local/share/flatpak-backup

while IFS= read -r app; do
    echo "📦 Processing $app..."

    # Backup app data (if exists)
    if [ -d "$HOME/.var/app/$app" ]; then
        cp -r "$HOME/.var/app/$app" ~/.local/share/flatpak-backup/
        echo "✅ Backed up data for $app."
    fi

    # Uninstall system-wide version
    echo "❌ Uninstalling system-wide Flatpak: $app..."
    flatpak uninstall --system -y "$app"

    # Reinstall in user mode
    echo "⬇️ Installing Flatpak in user mode: $app..."
    flatpak install --user -y "$app"

    # Restore app data
    if [ -d ~/.local/share/flatpak-backup/$app ]; then
        mv ~/.local/share/flatpak-backup/$app "$HOME/.var/app/"
        echo "🔄 Restored data for $app."
    fi
done < /tmp/system-flatpaks.txt

echo "🧹 Cleaning up..."
rm -rf ~/.local/share/flatpak-backup
rm /tmp/system-flatpaks.txt

echo "✅ All system-wide Flatpaks have been moved to user mode!"

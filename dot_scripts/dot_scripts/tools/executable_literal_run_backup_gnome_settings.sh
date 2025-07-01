#!/bin/bash
echo "Backing up GNOME settings..."

# Backup dconf
dconf dump / > ~/gnome-settings.ini
dconf dump /org/gnome/shell/extensions/ > ~/gnome-extensions-settings.ini

# Backup extension list
gnome-extensions list > ~/gnome-extensions.txt

# Commit and push all tracked GNOME-related files
cd ~
git add gnome-settings.ini gnome-extensions-settings.ini gnome-extensions.txt
git add .config/gtk-3.0 .config/gtk-4.0 .config/gnome-session .config/gnome-shell .local/share/gnome-shell

git commit -m "Auto-update GNOME settings"
git push origin main

echo "GNOME settings backed up successfully!"

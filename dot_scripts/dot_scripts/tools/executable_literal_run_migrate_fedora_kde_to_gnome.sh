#!/bin/bash

set -e  # Exit on error

echo "Updating system packages..."
sudo dnf update -y

echo "Installing GNOME and related packages..."
sudo dnf group install -y "GNOME" "GNOME Applications" --skip-unavailable

echo "Installing additional GNOME utilities..."
sudo dnf install -y --skip-unavailable \
    gdm \
    gnome-terminal \
    gnome-software \
    gnome-tweaks \
    nautilus \
    file-roller \
    gedit \
    evince \
    cheese \
    gnome-calculator \
    gnome-characters \
    gnome-weather \
    gnome-maps \
    gnome-contacts \
    gnome-clocks \
    gnome-music \
    gnome-photos \
    gnome-system-monitor \
    gnome-font-viewer \
    tracker \
    tracker-miners \
    tracker3 \
    tracker3-miners

echo "Removing KDE and unnecessary KDE applications..."
sudo dnf group remove -y kde-desktop kde-apps kde-software-development

echo "Removing additional KDE applications replaced by GNOME equivalents..."
sudo dnf remove -y \
    sddm \
    konsole \
    dolphin \
    ark \
    gwenview \
    kate \
    kcalc \
    okular \
    plasma-nm \
    plasma-pa \
    plasma-systemmonitor \
    spectacle \
    ksysguard || true  # Continue if some packages are missing

echo "Setting GDM as the default display manager..."
sudo systemctl disable sddm || true
sudo systemctl enable gdm

echo "Setting GNOME to use Wayland by default..."
echo "exec gnome-session" > ~/.xinitrc

echo "Cleaning up unnecessary dependencies..."
sudo dnf autoremove -y

echo "Migration complete! Rebooting now..."
sudo reboot


#!/bin/bash

set -e  # Exit on error

echo "Updating system packages..."
sudo dnf update -y

echo "Installing KDE Plasma and related packages..."
sudo dnf group install -y kde-desktop kde-apps kde-software-development --skip-unavailable

echo "Installing additional KDE utilities..."
sudo dnf install -y --skip-unavailable \
    sddm \
    plasma-nm \
    plasma-pa \
    spectacle \
    ksysguard

echo "Removing GNOME and unnecessary GNOME applications..."
sudo dnf group remove -y "GNOME"

echo "Removing extra GNOME applications replaced by KDE equivalents..."
sudo dnf remove -y \
    gnome-terminal \
    gnome-text-editor \
    nautilus \
    file-roller \
    gedit \
    totem \
    eog \
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
    gnome-software \
    gnome-tweaks \
    tracker \
    tracker-miners \
    tracker3 \
    tracker3-miners || true  # Continue if some packages are missing

echo "Setting SDDM as the default display manager..."
sudo systemctl disable gdm || true
sudo systemctl enable sddm

echo "Setting KDE Plasma to use Wayland by default..."
echo "exec startplasma-wayland" > ~/.xinitrc

echo "Cleaning up unnecessary dependencies..."
sudo dnf autoremove -y

echo "Migration complete! Rebooting now..."
sudo reboot


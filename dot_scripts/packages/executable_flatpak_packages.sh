#!/bin/bash

# Flatpak applications with their package IDs
declare -A FLATPAK_PACKAGES=(
    # Gaming and Emulation
    ["retroarch"]="org.libretro.RetroArch"
    ["ppsspp"]="org.ppsspp.PPSSPP"
    ["duckstation"]="org.duckstation.DuckStation"
    ["pcsx2"]="net.pcsx2.PCSX2"
    ["yuzu"]="org.yuzu_emu.yuzu"
    ["rpcs3"]="net.rpcs3.RPCS3"
    ["dolphin"]="org.DolphinEmu.dolphin-emu"
    
    # Streaming and Media
    ["obs-studio"]="com.obsproject.Studio"
    ["vlc"]="org.videolan.VLC"
    
    # Gaming Platforms
    ["steam"]="com.valvesoftware.Steam"
    ["lutris"]="net.lutris.Lutris"
    ["bottles"]="com.usebottles.bottles"
    ["wine"]="org.winehq.Wine"
    
    # Communication
    ["discord"]="com.discordapp.Discord"
    ["vesktop"]="dev.vencord.Vesktop"
    
    # Productivity
    ["libreoffice"]="org.libreoffice.LibreOffice"
    ["obsidian"]="md.obsidian.Obsidian"
    
    # System Tools
    ["flatseal"]="com.github.tchx84.Flatseal"
)

# Function to get list of Flatpak package IDs
get_flatpak_packages() {
    local packages=()
    for pkg in "${FLATPAK_PACKAGES[@]}"; do
        packages+=("$pkg")
    done
    echo "${packages[@]}"
} 
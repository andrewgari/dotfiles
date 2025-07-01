#!/bin/bash

# Pacman-specific packages with Arch package names
declare -A PACMAN_PACKAGES=(
    # Core development tools
    ["git"]="git"
    ["neovim"]="neovim"
    ["fzf"]="fzf"
    ["gh"]="github-cli"
    ["git-extras"]="git-extras"
    
    # Shell and terminal utilities
    ["zsh"]="zsh"
    ["zsh-autosuggestions"]="zsh-autosuggestions"
    ["zsh-syntax-highlighting"]="zsh-syntax-highlighting"
    ["starship"]="starship"
    ["tmux"]="tmux"
    ["thefuck"]="thefuck"
    ["exa"]="exa"
    ["ghostty"]="ghostty"
    
    # System monitoring and management
    ["htop"]="htop"
    ["fastfetch"]="fastfetch"
    ["progress"]="progress"
    ["scc"]="scc"
    
    # Container and virtualization
    ["docker"]="docker"
    ["docker-compose"]="docker-compose"
    ["podman"]="podman"
    ["virt-manager"]="virt-manager"
    ["qemu"]="qemu"
    ["libvirt"]="libvirt"
    
    # File operations and search
    ["ripgrep"]="ripgrep"
    ["fd"]="fd"
    ["tree"]="tree"
    ["bat"]="bat"
    ["jq"]="jq"
    ["yq"]="yq"
    
    # Network and download utilities
    ["wget"]="wget"
    ["rsync"]="rsync"
    ["tldr"]="tldr"
    
    # Multimedia
    ["ffmpeg"]="ffmpeg"
    
    # Android development
    ["android-tools"]="android-tools"
    
    # System integration
    ["flatpak"]="flatpak"
    
    # Additional AUR helpers
    ["yay"]="yay"

    # Fonts
    ["ttf-firacode-nerd"]="ttf-firacode-nerd"
    ["ttf-jetbrains-mono-nerd"]="ttf-jetbrains-mono-nerd"
    ["nerd-fonts-fira-mono"]="nerd-fonts-fira-mono"
    ["ttf-nerd-fonts-symbols"]="ttf-nerd-fonts-symbols"
)

# Function to get list of packages for installation
get_pacman_packages() {
    local packages=()
    for pkg in "${PACMAN_PACKAGES[@]}"; do
        packages+=("$pkg")
    done
    echo "${packages[@]}"
} 
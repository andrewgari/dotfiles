#!/bin/bash

# APT-specific packages with Debian/Ubuntu package names
declare -A APT_PACKAGES=(
    # Core development tools
    ["git"]="git"
    ["neovim"]="neovim"
    ["fzf"]="fzf"
    ["gh"]="gh"
    ["git-extras"]="git-extras"
    
    # Shell and terminal utilities
    ["zsh"]="zsh"
    ["zsh-autosuggestions"]="zsh-autosuggestions"
    ["zsh-syntax-highlighting"]="zsh-syntax-highlighting"
    ["tmux"]="tmux"
    ["thefuck"]="thefuck"
    ["exa"]="exa"
    
    # System monitoring and management
    ["htop"]="htop"
    ["fastfetch"]="fastfetch"
    ["progress"]="progress"
    ["scc"]="scc"
    
    # Container and virtualization
    ["docker"]="docker.io"
    ["docker-compose"]="docker-compose"
    ["podman"]="podman"
    ["virt-manager"]="virt-manager"
    ["qemu"]="qemu"
    ["libvirt"]="libvirt-daemon"
    
    # File operations and search
    ["ripgrep"]="ripgrep"
    ["fd"]="fd-find"
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
    ["android-tools"]="adb fastboot"
    
    # System integration
    ["flatpak"]="flatpak"
    
    # Additional dependencies
    ["curl"]="curl"
    ["software-properties-common"]="software-properties-common"
    ["apt-transport-https"]="apt-transport-https"

    # Fonts
    ["fonts-firacode"]="fonts-firacode"
    ["fonts-jetbrains-mono"]="fonts-jetbrains-mono"
)

# Function to get list of packages for installation
get_apt_packages() {
    local packages=()
    for pkg in "${APT_PACKAGES[@]}"; do
        # Split package names if there are multiple packages for one key
        for p in $pkg; do
            packages+=("$p")
        done
    done
    echo "${packages[@]}"
} 
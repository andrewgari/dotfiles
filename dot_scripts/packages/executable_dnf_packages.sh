#!/bin/bash

# DNF-specific packages with Fedora/RHEL package names
declare -A DNF_PACKAGES=(
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
    ["starship"]="starship"
    ["tmux"]="tmux"
    ["thefuck"]="thefuck"
    ["exa"]="eza"
    
    # System monitoring and management
    ["htop"]="htop"
    ["fastfetch"]="fastfetch"
    ["progress"]="progress"
    ["scc"]="scc"
    
    # Container and virtualization
    ["docker"]="docker-ce"
    ["docker-compose"]="docker-compose"
    ["podman"]="podman"
    ["virt-manager"]="virt-manager"
    ["qemu"]="qemu-kvm"
    ["libvirt"]="libvirt"
    
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
    ["tldr"]="tealdeer"
    
    # Multimedia
    ["ffmpeg"]="ffmpeg"
    
    # Android development
    ["android-tools"]="android-tools"
    
    # System integration
    ["flatpak"]="flatpak"
    
    # Browsers
    ["google-chrome"]="google-chrome-stable"

    # Fonts
    ["fira-code-fonts"]="fira-code-fonts"
    ["jetbrains-mono-fonts"]="jetbrains-mono-fonts"
    ["mozilla-fira-mono-fonts"]="mozilla-fira-mono-fonts"
    ["mozilla-fira-sans-fonts"]="mozilla-fira-sans-fonts"
    ["nerd-fonts"]="fira-code-fonts"
)

# Function to get list of packages for installation
get_dnf_packages() {
    local packages=()
    for pkg in "${DNF_PACKAGES[@]}"; do
        packages+=("$pkg")
    done
    echo "${packages[@]}"
}

# Function to setup additional repositories if needed
setup_dnf_repos() {
    # Docker CE repo
    if ! dnf repolist | grep -q "docker-ce"; then
        sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    fi
    
    # Google Chrome repo
    if ! dnf repolist | grep -q "google-chrome"; then
        sudo dnf config-manager --add-repo https://dl.google.com/linux/chrome/rpm/stable/x86_64
    fi
} 
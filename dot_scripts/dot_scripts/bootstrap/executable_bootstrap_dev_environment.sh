#!/bin/bash

set -e  # Exit on error

# Define Constants
REPO_URL="http://github.com/andrewgari/.dotfiles"
TARGET_DIR="$HOME/Repos/.dotfiles"
BACKUP_DIR="$HOME/dotfiles_backup"
TOOLBOX_URL="https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.28.1.tar.gz"
TOOLBOX_DIR="$HOME/.jetbrains-toolbox"
TOOLBOX_TMP="/tmp/jetbrains-toolbox.tar.gz"
DRY_RUN=false  # Default mode

# Ask user whether to enable dry-run mode
echo -n "Enable Dry-Run mode? (y/N): "
read -r dry_choice
if [[ "$dry_choice" =~ ^[Yy]$ ]]; then
    DRY_RUN=true
    echo "[Dry-Run Mode Enabled] No actual changes will be made."
fi

# Detect Package Manager (Prefers `yay` over `pacman` if available)
detect_package_manager() {
    if command -v yay &> /dev/null; then
        PM="yay"
    elif command -v dnf &> /dev/null; then
        PM="dnf"
    elif command -v apt &> /dev/null; then
        PM="apt"
    elif command -v pacman &> /dev/null; then
        PM="pacman"
    elif command -v brew &> /dev/null; then
        PM="brew"
    elif command -v flatpak &> /dev/null; then
        PM="flatpak"
    else
        echo "Unsupported package manager. Install required apps manually."
        exit 1
    fi
}

# Verify package availability
check_package_existence() {
    local package=$1
    case $PM in
        yay) yay -Si "$package" &> /dev/null ;;
        dnf) sudo dnf list --available "$package" &> /dev/null ;;
        apt) apt-cache show "$package" &> /dev/null ;;
        pacman) pacman -Si "$package" &> /dev/null ;;
        brew) brew info "$package" &> /dev/null ;;
        flatpak) flatpak search "$package" &> /dev/null ;;
        *) return 1 ;;
    esac
    return $?  # Returns 0 if the package exists, otherwise 1
}

# Install package with fallback methods
install_package() {
    local package=$1
    local package_name=$2  # Alternative package name if different from $package
    
    if [ "$DRY_RUN" = true ]; then
        if check_package_existence "$package"; then
            echo "[✔] $package is available in $PM"
        else
            echo "[✖] $package NOT FOUND in $PM"
        fi
        return
    fi

    case $PM in
        dnf)
            if ! sudo dnf install -y "$package" --skip-unavailable; then
                case $package in
                    wezterm)
                        echo "Installing WezTerm from official repository..."
                        sudo dnf copr enable wez/wezterm
                        sudo dnf install -y wezterm
                        ;;
                    cursor)
                        echo "Installing Cursor from official repository..."
                        curl -LO https://download.cursor.sh/latest
                        chmod +x latest
                        sudo mv latest /usr/local/bin/cursor
                        sudo dnf install fuse --skip-unavailable
                        ;;
                    lazygit)
                        echo "Installing lazygit from GitHub releases..."
                        curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep "browser_download_url.*lazygit_.*_Linux_x86_64.tar.gz" | cut -d : -f 2,3 | tr -d \" | wget -qi -
                        tar xf lazygit_*_Linux_x86_64.tar.gz
                        sudo install lazygit /usr/local/bin/
                        rm lazygit lazygit_*_Linux_x86_64.tar.gz
                        ;;
                    docker)
                        echo "Installing Docker from official repository..."
                        sudo dnf -y install dnf-plugins-core
                        sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
                        sudo dnf install -y docker-ce docker-ce-cli containerd.io
                        ;;
                    lazydocker)
                        echo "Installing lazydocker from GitHub releases..."
                        curl -s https://api.github.com/repos/jesseduffield/lazydocker/releases/latest | grep "browser_download_url.*lazydocker_.*_Linux_x86_64.tar.gz" | cut -d : -f 2,3 | tr -d \" | wget -qi -
                        tar xf lazydocker_*_Linux_x86_64.tar.gz
                        sudo install lazydocker /usr/local/bin/
                        rm lazydocker lazydocker_*_Linux_x86_64.tar.gz
                        ;;
                    ripgrep)
                        echo "Installing ripgrep from GitHub releases..."
                        curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | grep "browser_download_url.*ripgrep_.*_x86_64-unknown-linux-musl.tar.gz" | cut -d : -f 2,3 | tr -d \" | wget -qi -
                        tar xf ripgrep_*_x86_64-unknown-linux-musl.tar.gz
                        sudo install ripgrep_*/rg /usr/local/bin/
                        rm -rf ripgrep_*
                        ;;
                    neovim)
                        echo "Installing neovim from official repository..."
                        sudo dnf copr enable -y dperson/neovim
                        sudo dnf install -y neovim
                        ;;
                    wget)
                        echo "Installing wget..."
                        sudo dnf install -y wget
                        ;;
                    code)
                        echo "Installing VSCode from official repository..."
                        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
                        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
                        sudo dnf install -y code
                        ;;
                esac
            fi
            ;;
        apt)
            if ! sudo apt install -y "$package"; then
                case $package in
                    claude-code)
                        echo "Installing Claude Code..."
                        mkdir -p "$HOME/.local/bin"
                        curl -s https://raw.githubusercontent.com/anthropics/claude-code/main/install.sh | bash
                        ;;
                    lazygit)
                        echo "Installing lazygit from GitHub releases..."
                        curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep "browser_download_url.*lazygit_.*_Linux_x86_64.tar.gz" | cut -d : -f 2,3 | tr -d \" | wget -qi -
                        tar xf lazygit_*_Linux_x86_64.tar.gz
                        sudo install lazygit /usr/local/bin/
                        rm lazygit lazygit_*_Linux_x86_64.tar.gz
                        ;;
                    ghostty)
                        echo "Installing Ghostty from official repository..."
                        curl -s https://ghostty.app/install.sh | sh
                        ;;
                    docker)
                        echo "Installing Docker from official repository..."
                        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
                        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                        sudo apt update
                        sudo apt install -y docker-ce docker-ce-cli containerd.io
                        ;;
                    lazydocker)
                        echo "Installing lazydocker from GitHub releases..."
                        curl -s https://api.github.com/repos/jesseduffield/lazydocker/releases/latest | grep "browser_download_url.*lazydocker_.*_Linux_x86_64.tar.gz" | cut -d : -f 2,3 | tr -d \" | wget -qi -
                        tar xf lazydocker_*_Linux_x86_64.tar.gz
                        sudo install lazydocker /usr/local/bin/
                        rm lazydocker lazydocker_*_Linux_x86_64.tar.gz
                        ;;
                    ripgrep)
                        echo "Installing ripgrep from GitHub releases..."
                        curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | grep "browser_download_url.*ripgrep_.*_x86_64-unknown-linux-musl.tar.gz" | cut -d : -f 2,3 | tr -d \" | wget -qi -
                        tar xf ripgrep_*_x86_64-unknown-linux-musl.tar.gz
                        sudo install ripgrep_*/rg /usr/local/bin/
                        rm -rf ripgrep_*
                        ;;
                    neovim)
                        echo "Installing neovim from official repository..."
                        sudo add-apt-repository ppa:neovim-ppa/stable
                        sudo apt update
                        sudo apt install -y neovim
                        ;;
                    wget)
                        echo "Installing wget..."
                        sudo apt install -y wget
                        ;;
                    code)
                        echo "Installing VSCode from official repository..."
                        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
                        sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
                        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
                        rm -f packages.microsoft.gpg
                        sudo apt update
                        sudo apt install -y code
                        ;;
                esac
            fi
            ;;
        pacman)
            if ! sudo pacman -S --noconfirm "$package"; then
                case $package in
                    claude-code)
                        echo "Installing Claude Code..."
                        mkdir -p "$HOME/.local/bin"
                        curl -s https://raw.githubusercontent.com/anthropics/claude-code/main/install.sh | bash
                        ;;
                    lazygit)
                        echo "Installing lazygit from AUR..."
                        yay -S --noconfirm lazygit
                        ;;
                    ghostty)
                        echo "Installing Ghostty from AUR..."
                        yay -S --noconfirm ghostty
                        ;;
                    docker)
                        echo "Installing Docker from official repository..."
                        sudo pacman -S --noconfirm docker
                        ;;
                    lazydocker)
                        echo "Installing lazydocker from AUR..."
                        yay -S --noconfirm lazydocker
                        ;;
                    ripgrep)
                        echo "Installing ripgrep from official repository..."
                        sudo pacman -S --noconfirm ripgrep
                        ;;
                    neovim)
                        echo "Installing neovim from official repository..."
                        sudo pacman -S --noconfirm neovim
                        ;;
                    wget)
                        echo "Installing wget from official repository..."
                        sudo pacman -S --noconfirm wget
                        ;;
                    code)
                        echo "Installing VSCode from AUR..."
                        yay -S --noconfirm visual-studio-code-bin
                        ;;
                esac
            fi
            ;;
        brew)
            if ! brew install "$package"; then
                case $package in
                    claude-code)
                        echo "Installing Claude Code..."
                        brew install anthropics/tap/claude-code
                        ;;
                    lazygit)
                        echo "Installing lazygit from Homebrew..."
                        brew install lazygit
                        ;;
                    ghostty)
                        echo "Installing Ghostty from Homebrew..."
                        brew install --cask ghostty
                        ;;
                    docker)
                        echo "Installing Docker from Homebrew..."
                        brew install --cask docker
                        ;;
                    lazydocker)
                        echo "Installing lazydocker from Homebrew..."
                        brew install lazydocker
                        ;;
                    ripgrep)
                        echo "Installing ripgrep from Homebrew..."
                        brew install ripgrep
                        ;;
                    neovim)
                        echo "Installing neovim from Homebrew..."
                        brew install neovim
                        ;;
                    wget)
                        echo "Installing wget from Homebrew..."
                        brew install wget
                        ;;
                    code)
                        echo "Installing VSCode from Homebrew..."
                        brew install --cask visual-studio-code
                        ;;
                esac
            fi
            ;;
        flatpak)
            if ! flatpak install -y flathub "$package"; then
                case $package in
                    claude-code)
                        echo "Installing Claude Code..."
                        mkdir -p "$HOME/.local/bin"
                        curl -s https://raw.githubusercontent.com/anthropics/claude-code/main/install.sh | bash
                        ;;
                    *)
                        echo "Package $package not available in Flatpak"
                        return 1
                        ;;
                esac
            fi
            ;;
    esac
}

# Install necessary system packages
install_packages() {
    echo "Installing essential packages..."
    
    packages=(
        git git-extras gh lazygit wezterm cursor docker docker-compose lazydocker android-tools
        neovim fzf ripgrep bat htop wget unzip tar curl code claude-code
    )

    for pkg in "${packages[@]}"; do
        install_package "$pkg"
    done
}

# Setup Docker
install_docker() {
    echo "Setting up Docker..."
    
    if [ "$DRY_RUN" = true ]; then
        echo "[Dry-Run] Would enable and configure Docker"
        return
    fi

    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER
}

# Setup Docker Network
setup_docker_network() {
    echo "Setting up Docker network..."
    docker network create dev-network || true
}

# Create Development Containers
create_dev_containers() {
    echo "Creating development containers..."
    
    containers=(
        "java-dev openjdk:latest $HOME/dev/java"
        "kotlin-dev gradle:latest $HOME/dev/kotlin"
        "golang-dev golang:latest $HOME/dev/go"
        "rust-dev rust:latest $HOME/dev/rust"
        "node-dev node:latest $HOME/dev/node"
        "python-dev python:latest $HOME/dev/python"
        "android-dev ghcr.io/cirruslabs/android-sdk:latest $HOME/dev/android"
        "claude-dev python:latest $HOME/dev/claude"
    )

    for container in "${containers[@]}"; do
        set -- $container
        name=$1
        image=$2
        volume=$3

        if [ "$DRY_RUN" = true ]; then
            echo "[Dry-Run] Would create container: $name using image: $image"
            continue
        fi

        docker run -d --name "$name" --network dev-network -v "$volume:/workspace" -w /workspace "$image" tail -f /dev/null
    done
}

# Verify Installations
verify_installations() {
    echo "Verifying installations..."
    
    echo "Checking installed applications..."
    apps=(git gh lazygit ghostty docker docker-compose lazydocker neovim fzf ripgrep bat htop)

    for app in "${apps[@]}"; do
        if command -v "$app" &> /dev/null; then
            echo "[✔] $app is installed"
        else
            echo "[✖] $app is missing"
        fi
    done

    echo "Checking Docker containers..."
    docker ps --format "table {{.Names}}\t{{.Status}}"

    echo "Checking VSCode extensions..."
    code --list-extensions
}

# Execute functions
detect_package_manager
install_packages
install_docker
setup_docker_network
create_dev_containers
verify_installations

echo "All development tools and configurations have been set up successfully! 🚀"

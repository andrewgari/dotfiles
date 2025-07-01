#!/bin/bash

set -e  # Exit on error

# Function to check if NerdFonts are installed via package manager
check_package_manager_fonts() {
    if command -v dnf &>/dev/null; then
        if dnf list installed | grep -q "fira-code-fonts"; then
            return 0
        fi
    elif command -v pacman &>/dev/null; then
        if pacman -Q ttf-firacode-nerd &>/dev/null; then
            return 0
        fi
    elif command -v apt &>/dev/null; then
        if dpkg -l | grep -q "fonts-firacode"; then
            return 0
        fi
    elif command -v brew &>/dev/null; then
        if brew list | grep -q "font-fira-code-nerd-font"; then
            return 0
        fi
    fi
    return 1
}

# Install NerdFonts
install_nerdfonts() {
    echo "🎨 Installing NerdFonts..."
    
    # Check if fonts are already installed via package manager
    if check_package_manager_fonts; then
        echo "✅ NerdFonts already installed via package manager"
        return 0
    fi

    # If on macOS, try to install via Homebrew first
    if [[ "$(uname)" == "Darwin" ]]; then
        if command -v brew &>/dev/null; then
            echo "🍺 Installing NerdFonts via Homebrew..."
            brew tap homebrew/cask-fonts
            brew install --cask font-fira-code-nerd-font
            return 0
        fi
    fi
    
    # Manual installation as fallback
    echo "📥 Installing NerdFonts manually..."
    
    # Create fonts directory
    FONT_DIR="$HOME/.local/share/fonts/NerdFonts"
    mkdir -p "$FONT_DIR"
    
    # Download and install FiraCode Nerd Font
    echo "📥 Downloading FiraCode Nerd Font..."
    wget -qO "$FONT_DIR/FiraCode.zip" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"
    
    echo "📦 Extracting font files..."
    unzip -qo "$FONT_DIR/FiraCode.zip" -d "$FONT_DIR"
    
    # Clean up zip file
    rm "$FONT_DIR/FiraCode.zip"
    
    # Update font cache
    echo "🔄 Updating font cache..."
    if [[ "$(uname)" == "Darwin" ]]; then
        cp "$FONT_DIR"/*.ttf "$HOME/Library/Fonts/"
    else
        fc-cache -f
    fi
    
    echo "✅ NerdFonts installation completed!"
}

# Execute installation if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_nerdfonts
fi 
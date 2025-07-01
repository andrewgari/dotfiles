#!/bin/bash

set -e

# Define variables
CURSOR_URL="https://github.com/getcursor/cursor/releases/latest/download/Cursor.AppImage"
INSTALL_PATH="/usr/local/bin/cursor"
ICON_URL="https://raw.githubusercontent.com/getcursor/resources/main/logo.png"
ICON_PATH="$HOME/.local/share/icons/cursor.png"
DESKTOP_ENTRY="$HOME/.local/share/applications/cursor.desktop"
ALIAS_CMD="alias cursor='/usr/local/bin/cursor'"
BASH_RC="$HOME/.bashrc"
ZSH_RC="$HOME/.zshrc"

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Try running: sudo $0"
    exit 1
fi

# Check if Cursor is already installed
if [[ -f "$INSTALL_PATH" ]]; then
    echo "Cursor is already installed at $INSTALL_PATH."
else
    echo "Downloading Cursor..."
    curl -fsSL -o "$INSTALL_PATH" "$CURSOR_URL" && echo "Cursor downloaded successfully."

    echo "Making Cursor executable..."
    chmod +x "$INSTALL_PATH" && echo "Cursor is now executable."
fi

# Update PATH if necessary
if ! echo "$PATH" | grep -q "/usr/local/bin"; then
    echo "Adding /usr/local/bin to PATH..."
    echo 'export PATH="/usr/local/bin:$PATH"' >> "$BASH_RC" && echo "Updated $BASH_RC"
    echo 'export PATH="/usr/local/bin:$PATH"' >> "$ZSH_RC" && echo "Updated $ZSH_RC"
    source "$BASH_RC" 2>/dev/null || true
    source "$ZSH_RC" 2>/dev/null || true
else
    echo "PATH is already set correctly, skipping update."
fi

# Add alias to shell aliases files if they exist
for file in "$HOME/.bash-aliases" "$HOME/.zsh-aliases"; do
    if [[ -f "$file" ]]; then
        if grep -q "$ALIAS_CMD" "$file"; then
            echo "Alias already exists in $file, skipping."
        else
            echo "Adding cursor alias to $file"
            echo "$ALIAS_CMD" >> "$file" && echo "Alias added to $file"
        fi
    else
        echo "$file does not exist, skipping alias addition."
    fi
done

# Download Cursor icon if it doesn't exist
if [[ -f "$ICON_PATH" ]]; then
    echo "Cursor icon already exists at $ICON_PATH."
else
    echo "Downloading Cursor icon..."
    mkdir -p "$(dirname "$ICON_PATH")"
    curl -fsSL -o "$ICON_PATH" "$ICON_URL" && echo "Cursor icon saved to $ICON_PATH."
fi

# Create a .desktop entry for Cursor (GNOME/KDE search integration)
if [[ -f "$DESKTOP_ENTRY" ]]; then
    echo "Desktop entry already exists at $DESKTOP_ENTRY."
else
    echo "Creating desktop entry for Cursor..."
    mkdir -p "$(dirname "$DESKTOP_ENTRY")"
    cat <<EOF > "$DESKTOP_ENTRY"
[Desktop Entry]
Name=Cursor
Comment=AI-powered Code Editor
Exec=$INSTALL_PATH
Icon=$ICON_PATH
Terminal=false
Type=Application
Categories=Development;IDE;
EOF
    chmod +x "$DESKTOP_ENTRY"
    echo "Desktop entry created at $DESKTOP_ENTRY."
    echo "Updating application database..."
    update-desktop-database "$HOME/.local/share/applications"
fi

# Verify installation
if command -v cursor &> /dev/null; then
    echo "Cursor installed successfully!"
    cursor --version || echo "Cursor installed but failed to retrieve version."
else
    echo "Cursor installation failed. Please check for errors."
    exit 1
fi

echo "Installation complete! Restart your shell or run 'source ~/.bashrc' or 'source ~/.zshrc' to apply changes."
echo "Cursor should now be available in your system application launcher (GNOME/KDE search) with its official icon."


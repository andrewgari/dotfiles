#!/bin/bash

set -e  # Exit on error

# Define variables
CURSOR_URL="https://github.com/getcursor/cursor/releases/latest/download/Cursor.AppImage"
INSTALL_PATH="/usr/local/bin/cursor"
ICON_URL="https://raw.githubusercontent.com/getcursor/resources/main/logo.png"
ICON_PATH="$HOME/.local/share/icons/cursor.png"
DESKTOP_ENTRY="$HOME/.local/share/applications/cursor.desktop"
ALIAS_CMD="alias cursor='/usr/local/bin/cursor'"

install_cursor() {
    echo "💻 Installing Cursor IDE..."

    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        echo "⚠️  This script requires root privileges to install Cursor system-wide."
        echo "Running with sudo..."
        sudo "$0"
        exit $?
    fi

    # Check if Cursor is already installed
    if [[ -f "$INSTALL_PATH" ]]; then
        echo "✔️ Cursor is already installed at $INSTALL_PATH"
    else
        echo "📥 Downloading Cursor..."
        curl -fsSL -o "$INSTALL_PATH" "$CURSOR_URL" || {
            echo "❌ Failed to download Cursor"
            exit 1
        }

        echo "🔑 Making Cursor executable..."
        chmod +x "$INSTALL_PATH" || {
            echo "❌ Failed to make Cursor executable"
            exit 1
        }
    fi

    # Download Cursor icon
    if [[ -f "$ICON_PATH" ]]; then
        echo "✔️ Cursor icon already exists"
    else
        echo "🎨 Downloading Cursor icon..."
        mkdir -p "$(dirname "$ICON_PATH")"
        curl -fsSL -o "$ICON_PATH" "$ICON_URL" || {
            echo "⚠️  Failed to download icon, but continuing installation"
        }
    fi

    # Create desktop entry
    echo "📝 Creating desktop entry..."
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

    # Update desktop database
    echo "🔄 Updating application database..."
    update-desktop-database "$HOME/.local/share/applications" || true

    # Add alias to shell config files if they exist
    for rc_file in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [[ -f "$rc_file" ]]; then
            if ! grep -q "$ALIAS_CMD" "$rc_file"; then
                echo "Adding cursor alias to $rc_file"
                echo "$ALIAS_CMD" >> "$rc_file"
            fi
        fi
    done

    echo "✅ Cursor installation completed!"
    echo "🔄 Please restart your shell or run 'source ~/.bashrc' or 'source ~/.zshrc' to use the cursor command"
}

# Execute installation if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_cursor
fi 
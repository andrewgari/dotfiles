update_system() {
    echo "🔄 Updating system packages..."
    
    if command -v dnf &>/dev/null; then
        echo "🟢 Using DNF (Fedora, RHEL, CentOS)"
        sudo dnf upgrade --refresh -y
        sudo dnf autoremove -y
        sudo dnf clean all
    elif command -v apt &>/dev/null; then
        echo "🟢 Using APT (Debian, Ubuntu)"
        sudo apt update && sudo apt full-upgrade -y
        sudo apt autoremove -y
        sudo apt autoclean
    elif command -v yay &>/dev/null; then
        echo "🟢 Using YAY (Arch, Manjaro - AUR)"
        yay -Syu --noconfirm
        yay -Yc --noconfirm
    elif command -v pacman &>/dev/null; then
        echo "🟢 Using Pacman (Arch, Manjaro)"
        sudo pacman -Syu --noconfirm
        sudo pacman -Rns $(pacman -Qdtq) --noconfirm 2>/dev/null || true
        sudo pacman -Sc --noconfirm
    elif command -v brew &>/dev/null; then
        echo "🟢 Using Homebrew (macOS, Linux)"
        brew update
        brew upgrade
        brew cleanup
    else
        echo "❌ No supported package manager found."
        return 1
    fi

    # Update Flatpak if installed
    if command -v flatpak &>/dev/null; then
        echo "🟢 Updating Flatpak..."
        flatpak update -y
        flatpak uninstall --unused -y
    fi

    # Update firmware if available
    if command -v fwupdmgr &>/dev/null; then
        echo "🟢 Checking for firmware updates..."
        sudo fwupdmgr get-updates && sudo fwupdmgr update
    fi

    echo "✅ System update complete!"
}

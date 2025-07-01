#!/bin/bash

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLERS_DIR="$SCRIPT_DIR/installers"
PACKAGES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)/packages"
DRY_RUN=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--dry-run]"
            exit 1
            ;;
    esac
done

# Function to check if a file exists and is readable
check_file() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        echo "❌ Missing file: $file"
        return 1
    elif [[ ! -r "$file" ]]; then
        echo "❌ File not readable: $file"
        return 1
    else
        echo "✅ Found file: $file"
        return 0
    fi
}

# Function to check package definition files
check_package_definitions() {
    local has_error=false
    echo "🔍 Checking package definition files..."
    
    for pkg_file in "dnf_packages.sh" "apt_packages.sh" "pacman_packages.sh" "flatpak_packages.sh"; do
        if ! check_file "$PACKAGES_DIR/$pkg_file"; then
            has_error=true
        fi
    done
    
    if [[ "$has_error" == "true" ]]; then
        echo "❌ Some package definition files are missing or not readable"
        return 1
    fi
    return 0
}

# Function to check installer scripts
check_installer_scripts() {
    local has_error=false
    echo "🔍 Checking installer scripts..."
    
    for installer in "run_install_dnf_packages.sh" "run_install_apt_packages.sh" \
                    "run_install_pacman_packages.sh" "run_install_flatpak_packages.sh" \
                    "run_install_1password.sh" "run_install_cursor.sh" "run_install_nerdfonts.sh"; do
        if ! check_file "$INSTALLERS_DIR/$installer"; then
            has_error=true
        fi
    done
    
    if [[ "$has_error" == "true" ]]; then
        echo "❌ Some installer scripts are missing or not readable"
        return 1
    fi
    return 0
}

# Function to detect and run package manager installers
detect_and_run_installers() {
    local has_package_manager=false

    echo "🔍 Detecting available package managers..."

    # Check and run DNF installer
    if command -v dnf &>/dev/null; then
        echo "📦 Found DNF package manager"
        if [[ "$DRY_RUN" == "true" ]]; then
            echo "🔍 Would run: $INSTALLERS_DIR/run_install_dnf_packages.sh"
            source "$PACKAGES_DIR/dnf_packages.sh"
            echo "📋 Would install packages: $(get_dnf_packages)"
        else
            bash "$INSTALLERS_DIR/run_install_dnf_packages.sh"
        fi
        has_package_manager=true
    fi

    # Check and run APT installer
    if command -v apt &>/dev/null; then
        echo "📦 Found APT package manager"
        if [[ "$DRY_RUN" == "true" ]]; then
            echo "🔍 Would run: $INSTALLERS_DIR/run_install_apt_packages.sh"
            source "$PACKAGES_DIR/apt_packages.sh"
            echo "📋 Would install packages: $(get_apt_packages)"
        else
            bash "$INSTALLERS_DIR/run_install_apt_packages.sh"
        fi
        has_package_manager=true
    fi

    # Check and run Pacman installer
    if command -v pacman &>/dev/null; then
        echo "📦 Found Pacman package manager"
        if [[ "$DRY_RUN" == "true" ]]; then
            echo "🔍 Would run: $INSTALLERS_DIR/run_install_pacman_packages.sh"
            source "$PACKAGES_DIR/pacman_packages.sh"
            echo "📋 Would install packages: $(get_pacman_packages)"
        else
            bash "$INSTALLERS_DIR/run_install_pacman_packages.sh"
        fi
        has_package_manager=true
    fi

    # Check and run Homebrew installer for macOS
    if [[ "$(uname)" == "Darwin" ]]; then
        if ! command -v brew &>/dev/null; then
            if [[ "$DRY_RUN" == "true" ]]; then
                echo "🔍 Would install Homebrew"
            else
                echo "🍺 Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
        fi
        # TODO: Add Homebrew packages installer when created
        has_package_manager=true
    fi

    # Error if no package manager was found
    if [[ "$has_package_manager" == "false" ]]; then
        echo "❌ No supported package manager found. Supported: DNF, APT, Pacman, Homebrew"
        exit 1
    fi
}

# Function to install Flatpak packages if available
install_flatpak_if_available() {
    # If Flatpak is installed or we can install it
    if command -v flatpak &>/dev/null || [[ "$has_package_manager" == "true" ]]; then
        echo "🚀 Installing Flatpak packages..."
        if [[ "$DRY_RUN" == "true" ]]; then
            echo "🔍 Would run: $INSTALLERS_DIR/run_install_flatpak_packages.sh"
            source "$PACKAGES_DIR/flatpak_packages.sh"
            echo "📋 Would install Flatpak packages:"
            for app in "${!FLATPAK_PACKAGES[@]}"; do
                echo "  - $app (${FLATPAK_PACKAGES[$app]})"
            done
        else
            bash "$INSTALLERS_DIR/run_install_flatpak_packages.sh"
        fi
    else
        echo "⚠️  Flatpak not available and cannot be installed automatically"
    fi
}

# Function to install external applications
install_external_apps() {
    echo "🌟 Installing external applications..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "🔍 Would install external applications:"
        echo "  - Would run: $INSTALLERS_DIR/run_install_1password.sh"
        echo "  - Would run: $INSTALLERS_DIR/run_install_cursor.sh"
        echo "  - Would run: $INSTALLERS_DIR/run_install_nerdfonts.sh"
    else
        # Install 1Password
        bash "$INSTALLERS_DIR/run_install_1password.sh"
        
        # Install Cursor IDE
        bash "$INSTALLERS_DIR/run_install_cursor.sh"
        
        # Install NerdFonts
        bash "$INSTALLERS_DIR/run_install_nerdfonts.sh"
    fi
}

# Main execution
echo "🚀 Starting package bootstrap process..."
if [[ "$DRY_RUN" == "true" ]]; then
    echo "⚠️  DRY RUN MODE - No changes will be made"
fi

# First check all required files
check_package_definitions || exit 1
check_installer_scripts || exit 1

# Then detect and install using native package managers
detect_and_run_installers

# Then install Flatpak packages if possible
install_flatpak_if_available

# Finally install external applications
install_external_apps

if [[ "$DRY_RUN" == "true" ]]; then
    echo "✨ Dry run completed - all checks passed!"
else
    echo "✨ Package bootstrap completed! A reboot is recommended."
fi

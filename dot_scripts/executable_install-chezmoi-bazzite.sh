#!/bin/bash

# Chezmoi Installation Script for Bazzite/Fedora Kinoite
# This script installs chezmoi via Homebrew for safe, updatable installation on immutable systems

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Bazzite/Fedora Kinoite
check_bazzite() {
    if ! grep -q "Bazzite\|Kinoite" /etc/os-release 2>/dev/null; then
        log_warn "This script is designed for Bazzite/Fedora Kinoite systems"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_error "Installation cancelled"
            exit 1
        fi
    fi
}

# Check if Homebrew is installed
check_homebrew() {
    if ! command -v brew &> /dev/null; then
        log_error "Homebrew is not installed. Please install Homebrew first:"
        echo "Visit: https://brew.sh/"
        exit 1
    fi
    log_info "Homebrew found at $(which brew)"
}

# Check if chezmoi is already installed
check_existing_chezmoi() {
    if command -v chezmoi &> /dev/null; then
        local version=$(chezmoi --version | head -n1)
        log_warn "Chezmoi is already installed: $version"
        read -p "Reinstall/upgrade anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled"
            exit 0
        fi
    fi
}

# Install chezmoi via Homebrew
install_chezmoi() {
    log_info "Installing chezmoi via Homebrew..."
    
    if brew install chezmoi; then
        log_success "Chezmoi installed successfully"
    else
        log_error "Failed to install chezmoi"
        exit 1
    fi
}

# Verify installation
verify_installation() {
    log_info "Verifying installation..."
    
    if command -v chezmoi &> /dev/null; then
        local version=$(chezmoi --version | head -n1)
        log_success "Chezmoi verified: $version"
        
        # Run chezmoi doctor for additional verification
        log_info "Running chezmoi doctor..."
        chezmoi doctor
    else
        log_error "Chezmoi installation verification failed"
        exit 1
    fi
}

# Show usage instructions
show_usage() {
    cat << EOF

${GREEN}Chezmoi Installation Complete!${NC}

${BLUE}Next Steps:${NC}
1. Initialize chezmoi with your dotfiles repository:
   ${YELLOW}chezmoi init https://github.com/yourusername/dotfiles.git${NC}

2. Or create a new dotfiles repository:
   ${YELLOW}chezmoi init${NC}

3. Edit your first file:
   ${YELLOW}chezmoi add ~/.bashrc${NC}
   ${YELLOW}chezmoi edit ~/.bashrc${NC}

4. Apply changes:
   ${YELLOW}chezmoi apply${NC}

${BLUE}Updating:${NC}
- Update chezmoi: ${YELLOW}brew upgrade chezmoi${NC}
- Update all Homebrew packages: ${YELLOW}brew upgrade${NC}

${BLUE}System Updates:${NC}
- Bazzite system updates: ${YELLOW}ujust update${NC}
- Chezmoi will NOT interfere with ujust updates

${BLUE}Documentation:${NC}
- Chezmoi docs: https://www.chezmoi.io/
- Quick start: https://www.chezmoi.io/quick-start/

EOF
}

# Main execution
main() {
    log_info "Starting Chezmoi installation for Bazzite/Fedora Kinoite"
    
    check_bazzite
    check_homebrew
    check_existing_chezmoi
    install_chezmoi
    verify_installation
    show_usage
    
    log_success "Installation complete!"
}

# Run main function
main "$@"
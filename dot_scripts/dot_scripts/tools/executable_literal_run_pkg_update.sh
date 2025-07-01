#!/bin/bash

# Script to update system packages across multiple package managers
DRY_RUN=false

# Parse arguments
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "🟡 Running in dry-run mode (no changes will be made)."
fi

# Function to display a progress bar
progress_bar() {
    local width=40
    local progress=$(( $1 * width / $2 ))
    printf "\r[%-${width}s] %d%% - %s" "$(printf '%0.s#' $(seq 1 $progress))" $(( $1 * 100 / $2 )) "$3"
}

echo "🚀 Starting system update..."

# Detect package manager
if command -v dnf >/dev/null; then
    CMD="sudo dnf upgrade -y"
elif command -v yum >/dev/null; then
    CMD="sudo yum update -y"
elif command -v apt >/dev/null; then
    CMD="sudo apt update && sudo apt upgrade -y"
elif command -v nala >/dev/null; then
    CMD="sudo nala upgrade -y"
elif command -v pacman >/dev/null; then
    CMD="sudo pacman -Syu --noconfirm"
elif command -v yay >/dev/null; then
    CMD="yay -Syu --noconfirm"
elif command -v brew >/dev/null; then
    CMD="brew update && brew upgrade"
elif command -v zypper >/dev/null; then
    CMD="sudo zypper update -y"
else
    echo "❌ No supported package manager found!"
    exit 1
fi

if [ "$DRY_RUN" = true ]; then
    echo "🟡 [Dry Run] Would run: $CMD"
else
    eval "$CMD"
fi

echo ""
echo "✅ System update complete."


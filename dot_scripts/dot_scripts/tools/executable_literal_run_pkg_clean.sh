#!/bin/bash

# Script to clean up old packages and caches
DRY_RUN=false

if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "🟡 Running in dry-run mode (no changes will be made)."
fi

echo "🧹 Starting package cleanup..."

if command -v dnf >/dev/null; then
    CMD="sudo dnf autoremove -y && sudo dnf clean all"
elif command -v yum >/dev/null; then
    CMD="sudo yum autoremove -y && sudo yum clean all"
elif command -v apt >/dev/null; then
    CMD="sudo apt autoremove -y && sudo apt autoclean -y"
elif command -v nala >/dev/null; then
    CMD="sudo nala autopurge"
elif command -v pacman >/dev/null; then
    CMD="sudo pacman -Rns $(pacman -Qdtq) --noconfirm && sudo pacman -Scc --noconfirm"
elif command -v yay >/dev/null; then
    CMD="yay -Rns $(yay -Qdtq) --noconfirm && yay -Scc --noconfirm"
elif command -v brew >/dev/null; then
    CMD="brew cleanup"
elif command -v zypper >/dev/null; then
    CMD="sudo zypper clean --all"
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
echo "✅ Package cleanup complete."


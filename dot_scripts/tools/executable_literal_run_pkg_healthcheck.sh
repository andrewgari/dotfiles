#!/bin/bash

# Script to check for broken/missing packages and repair them
DRY_RUN=false

if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "🟡 Running in dry-run mode (no changes will be made)."
fi

echo "🩺 Running package health check..."

if command -v dnf >/dev/null; then
    CMD="sudo dnf check all"
elif command -v yum >/dev/null; then
    CMD="sudo yum check all"
elif command -v apt >/dev/null; then
    CMD="sudo apt --fix-broken install -y"
elif command -v nala >/dev/null; then
    CMD="sudo nala doctor"
elif command -v pacman >/dev/null; then
    CMD="sudo pacman -Qkk"
elif command -v yay >/dev/null; then
    CMD="yay -Qkk"
elif command -v brew >/dev/null; then
    CMD="brew doctor"
elif command -v zypper >/dev/null; then
    CMD="sudo zypper verify"
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
echo "✅ Package health check complete."


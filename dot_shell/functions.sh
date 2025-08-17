#!/usr/bin/env bash
# ~/.shell/functions.sh - Shared shell functions for bash and zsh

# -----------------------------
# Docker/Podman utility functions
# -----------------------------

# Shell into a running container
dsh() {
    if [ -z "$1" ]; then
        echo "Usage: dsh <container-name-or-id>"
        return 1
    fi
    docker exec -it "$1" /bin/bash || docker exec -it "$1" /bin/sh
}

# Prune unused Docker resources
dprune() {
    echo "Pruning containers, networks, and images..."
    docker system prune -a -f
    echo "Pruning volumes..."
    docker volume prune -f
    echo "Docker system cleaned!"
}

# -----------------------------
# Git utility functions
# -----------------------------

# Show the most frequently used git commands
git-stats() {
    history | grep "git " | awk '{print $2, $3}' | sort | uniq -c | sort -nr | head -n 10
}

# Show git status in a cleaner format
git-summary() {
    git rev-parse --is-inside-work-tree &>/dev/null || { 
        echo "Not a git repository!"
        return 1
    }
    echo "Branch: $(git branch --show-current)"
    echo "Status:"
    git status -s
    echo "Recent commits:"
    git log --oneline -n 5
}
# -----------------------------
# Zoxide Smart Navigation
# -----------------------------

# Jump to directories quickly
j() {
    [ $# -gt 0 ] || return
    if command -v zoxide &>/dev/null; then
        cd "$(zoxide query "$@")" || return
    else
        echo "zoxide not installed"
        return 1
    fi
}

# -----------------------------
# Utility functions
# -----------------------------

# Quick calculations
calc() {
    echo "scale=2; $*" | bc -l
}

# Generate a strong password
genpass() {
    local length=${1:-20}
    openssl rand -base64 48 | cut -c1-$length
}

# Get external IP address
whatismyip() {
    echo "Public IP: $(curl -s ifconfig.me)"
    echo "Local IP: $(hostname -I | awk '{print $1}')"
}

# Internet speed test
speedtest-cli() {
    if command -v fast &>/dev/null; then
        fast
    elif command -v speedtest-cli &>/dev/null; then
        speedtest-cli
    else
        curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -
    fi
}

# Help with syntax highlighting (for bat users)
help() { 
    "$@" --help 2>&1 | bat --plain --language=help 2>/dev/null || "$@" --help
}

# -----------------------------
# Chezmoi Helper Functions
# -----------------------------

# Edit chezmoi files and automatically apply changes
czedit() {
    chezmoi edit "$@" && \
    echo "Applying changes..." && \
    chezmoi apply -v
}

# Add, commit, and push all chezmoi changes in one go
czcommit() {
    local commit_message="${1:-Update dotfiles}"

    echo "Syncing chezmoi changes..."

    # Go to the chezmoi source directory
    cd "$(chezmoi source-path)" || return

    # Add all unstaged changes
    git add .

    # Commit with the provided or default message
    git commit -m "$commit_message"

    # Push to the remote repository
    git push

    # Return to the directory you were in before
    cd - >/dev/null 2>&1
}

# -----------------------------
# Dotfiles management functions
# -----------------------------

dotfiles-sync() {
    echo "🔄 Running dotfiles sync..."
    if [ -f "$HOME/Repos/dotfiles/.scripts/tools/run_dotfiles_sync.sh" ]; then
        "$HOME/Repos/dotfiles/.scripts/tools/run_dotfiles_sync.sh"
        source ~/.zshrc 2>/dev/null || source ~/.bashrc
    else
        echo "Dotfiles sync script not found"
    fi
}

dotfiles-upload() {
    echo "🚀 Uploading local dotfiles to repo..."
    if [ -f "$HOME/Repos/dotfiles/.scripts/tools/run_dotfiles_upload.sh" ]; then
        "$HOME/Repos/dotfiles/.scripts/tools/run_dotfiles_upload.sh"
        source ~/.zshrc 2>/dev/null || source ~/.bashrc
    else
        echo "Dotfiles upload script not found"
    fi
}

dotfiles-download() {
    echo "📥 Downloading dotfiles from remote repo..."
    if [ -f "$HOME/Repos/dotfiles/.scripts/tools/run_dotfiles_download.sh" ]; then
        "$HOME/Repos/dotfiles/.scripts/tools/run_dotfiles_download.sh"
        source ~/.zshrc 2>/dev/null || source ~/.bashrc
    else
        echo "Dotfiles download script not found"
    fi
}

dotfiles-add() {
    if [ -z "$1" ]; then
        echo "⚠️ Usage: dotfiles-add <file>"
        return 1
    fi
    echo "➕ Adding $1 to dotfiles repo..."
    if [ -f "$HOME/Repos/dotfiles/.scripts/tools/run_dotfiles_add.sh" ]; then
        "$HOME/Repos/dotfiles/.scripts/tools/run_dotfiles_add.sh" "$1"
        source ~/.zshrc 2>/dev/null || source ~/.bashrc
    else
        echo "Dotfiles add script not found"
    fi
}

dotfiles-remove() {
    if [ -z "$1" ]; then
        echo "⚠️ Usage: dotfiles-remove <file>"
        return 1
    fi
    echo "❌ Removing $1 from dotfiles repo..."
    if [ -f "$HOME/Repos/dotfiles/.scripts/tools/run_dotfiles_remove.sh" ]; then
        "$HOME/Repos/dotfiles/.scripts/tools/run_dotfiles_remove.sh" "$1"
        source ~/.zshrc 2>/dev/null || source ~/.bashrc
    else
        echo "Dotfiles remove script not found"
    fi
}
#!/usr/bin/env bash
# ~/.shell/exports.sh - Environment variables and PATH configuration

# -----------------------------
# Editor and Terminal Settings
# -----------------------------
export EDITOR=nvim
export VISUAL=nvim
export DISPLAY=:0

# -----------------------------
# History Settings
# -----------------------------

# Bash history settings
export HISTSIZE=100000
export HISTFILESIZE=100000
export HISTFILE="$HOME/.bash_history"
export HISTCONTROL=ignoredups:erasedups

# Zsh history settings (will be ignored by bash)
export HISTSIZE=100000
export SAVEHIST=100000
export HISTFILE="$HOME/.zsh_history"

# -----------------------------
# FZF Configuration
# -----------------------------
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --color=always --style=numbers --line-range=:500 {}' 2>/dev/null"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}' 2>/dev/null"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# -----------------------------
# PATH Management
# -----------------------------

# Function to safely add to PATH (avoid duplicates)
add_to_path() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        export PATH="$1:$PATH"
    fi
}

# Add directories to PATH
add_to_path "$HOME/.npm-global/bin"
add_to_path "$HOME/.local/bin"
add_to_path "$HOME/.cargo/bin"

# Clean up PATH function
unset -f add_to_path

# -----------------------------
# Application-specific exports
# -----------------------------
export SOFTWARE_UPDATE_AVAILABLE='📦 '
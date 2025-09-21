# ~/.config/fish/config.fish - Fish configuration

# -----------------------------
# Environment Variables
# -----------------------------
# Using fish_add_path to prepend to PATH, avoiding duplicates.
fish_add_path ~/.local/bin
fish_add_path ~/bin

# Set EDITOR if not already set
if not set -q EDITOR
    set -x EDITOR nvim
end

# -----------------------------
# Tool Initializations
# -----------------------------

# Starship prompt
# if status is-interactive; and command -v starship &>/dev/null
#     starship init fish | source
# end

# Zoxide (replaces z)
# if command -v zoxide &>/dev/null
#     zoxide init fish | source
# end

# FZF integration
# if command -v fzf &>/dev/null
#     fzf --fish | source
# end


# -----------------------------
# Key Bindings (Translated from Zsh)
# -----------------------------
# To add these, you might need to run them in your terminal once,
# or add them to this file.

# bind \e\[A history-search-backward
# bind \e\[B history-search-forward
# bind \e\[1\;5C forward-word
# bind \e\[1\;5D backward-word
# # bind \cH backward-kill-word # Consider using default alt-backspace
# # bind \cU backward-kill-line # Consider using default ctrl-u
# # bind \cL clear-screen # `clear` or ctrl-l is default
# # bind \e q kill-whole-line # No direct equivalent, ctrl-u is similar
# bind \cA beginning-of-line
# bind \cE end-of-line
# bind \cK kill-line
# bind \cR history-incremental-search-backward


# -----------------------------
# Fish Plugin Management (Recommendation)
# -----------------------------
# Zsh's zinit doesn't work with Fish. The most popular plugin manager for Fish is Fisher.
# 1. Install Fisher:
#    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
#
# 2. Create a fish_plugins file: `touch ~/.config/fish/fish_plugins`
#
# 3. Add plugins to `~/.config/fish/fish_plugins`. Here are some equivalents to your Zsh plugins:
#    jorgebucaran/fisher          # Fisher itself
#    PatrickF1/fzf.fish           # FZF integration
#    jethrokuan/z                 # Z-like directory jumping (alternative to zoxide)
#    oh-my-fish/plugin-bang-bang  # Command history expansion (!!)
#    IlanCosman/tide              # A powerful prompt, alternative to starship
#    pufferfish/pufferfish        # Completion suggestions
#
# 4. Run `fisher update` to install them.

# -----------------------------
# Welcome message
# -----------------------------
if status is-interactive; and command -v fastfetch &>/dev/null
    fastfetch
end

# Source custom aliases
source ~/.config/fish/aliases.fish
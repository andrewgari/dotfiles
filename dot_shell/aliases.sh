#!/usr/bin/env bash
# ~/.shell/aliases.sh - Unified aliases for bash and zsh

# -----------------------------
# Config file quick access
# -----------------------------
alias zshrc='${EDITOR:-nvim} ~/.zshrc && source ~/.zshrc'
alias bashrc='${EDITOR:-nvim} ~/.bashrc && source ~/.bashrc'
alias aliases='${EDITOR:-nvim} ~/.shell/aliases.sh && source ~/.shell/aliases.sh'
alias vimrc='${EDITOR:-nvim} ~/.config/nvim/init.lua'

# -----------------------------
# SSH Shortcuts
# -----------------------------
alias sshpc='ssh andrewgari@192.168.50.2'
alias sshtower='ssh root@192.168.50.3'
alias sshlaptop='ssh andrewgari@192.168.50.4'
alias sshwork='ssh andrewgari@192.168.50.11'
alias ssh_copy_id='ssh-copy-id -i ~/.ssh/id_rsa.pub'

# -----------------------------
# System utilities
# -----------------------------
alias edit='${EDITOR:-nvim}'
alias print='echo'
alias trash='mv --force -t ~/.local/share/Trash '
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias md='mkdir -p'

# System info and monitoring
alias free_space="df -h --total | grep total"
alias meminfo="free -h"
alias processes="ps aux --sort=-%cpu | head -15"
alias reboot_now="sudo systemctl reboot"
alias shutdown_now="sudo systemctl poweroff"

# Copy/paste in terminal
alias c='xclip -selection clipboard'
alias v='xclip -selection clipboard -o'

# -----------------------------
# Modern CLI tools
# -----------------------------

# Bat (better `cat` replacement)
if command -v bat &>/dev/null; then
    alias cat='bat --style=plain'
    alias bathelp='bat --plain --language=help'
    alias catp='bat -p'
fi

# Eza (better `ls` replacement)
if command -v eza &>/dev/null; then
    alias ls='eza --color=always --group-directories-first --icons'
    alias ll='eza -alF --color=always --group-directories-first --icons --header --git'
    alias la='eza -a --color=always --group-directories-first --icons'
    alias l='eza -F --color=always --group-directories-first --icons'
    alias l.='eza -a --icons | egrep "^\."'
    alias lt='eza -aT --color=always --group-directories-first --icons --level=2'
    alias llt='eza -alFT --color=always --group-directories-first --icons --git --level=2'
    alias list='eza -la --icons'
    alias ld='eza -D --icons'
    alias lsd='eza -D --icons'
elif command -v lsd &>/dev/null; then
    alias ls='lsd'
    alias ll='lsd -l'
    alias la='lsd -la'
    alias lt='lsd --tree'
fi

# Use `duf` for better disk usage overview
if command -v duf &>/dev/null; then
    alias df='duf --only local'
fi

# Use `btop` or `htop` if installed
if command -v btop &>/dev/null; then
    alias top='btop'
elif command -v htop &>/dev/null; then
    alias top='htop'
fi

# Use `rg` over `grep` if available
if command -v rg &>/dev/null; then
    alias grep='rg'
fi

# -----------------------------
# Directory navigation
# -----------------------------
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias docs="cd ~/Documents"alias dl="cd ~/Downloads"
alias repos="cd ~/Repos"
alias starbunk="cd ~/Repos/starbunk-js"
alias unraid="cd /mnt/unraid"
alias scripts='cd ~/.scripts/tools'
alias -- -="cd -"

# -----------------------------
# Git shortcuts
# -----------------------------
alias g="git"
alias gs="git status"
alias ga="git add ."
alias gc="git commit -m"
alias gp="git push -u origin"
alias gl="git log --oneline --graph --decorate --all"
alias gd="git diff"
alias gco="git switch"
alias gpull="git pull origin"

# -----------------------------
# System services
# -----------------------------
alias status='systemctl status'
alias start='systemctl start'
alias enable='systemctl enable'
alias disable='systemctl disable'
alias stop='systemctl stop'
alias restart='systemctl restart'
alias restart_network="sudo systemctl restart NetworkManager"
alias list_services="systemctl list-units --type=service --state=running"
alias reload_systemd="sudo systemctl daemon-reload"

# -----------------------------
# Docker/Podman shortcuts
# -----------------------------
alias dps='docker ps'
alias dpa='docker ps -a'alias drm='docker rm'
alias drmi='docker rmi'
alias drma='docker rm $(docker ps -aq)'
alias dstop='docker stop'
alias dstopa='docker stop $(docker ps -q)'
alias drestart='docker restart'
alias dlogs='docker logs'
alias dexec='docker exec -it'
alias dimg='docker images'
alias dcup='docker-compose up -d'
alias dcdown='docker-compose down'
alias dcps='docker-compose ps'
alias dclogs='docker-compose logs -f'
alias dcrestart='docker-compose restart'
alias docker_restart="sudo systemctl restart docker"
alias docker_cleanup="docker system prune -a -f && docker volume prune -f"

# -----------------------------
# Networking
# -----------------------------
alias myip="curl ifconfig.me"
alias flush_dns="sudo systemd-resolve --flush-caches && sudo systemctl restart systemd-resolved"
alias speedtest="fast"
alias nmap_local="sudo nmap -sP 192.168.50.0/24"
alias ports="netstat -tulanp"
alias weather="curl wttr.in"

# -----------------------------
# Process monitoring
# -----------------------------
alias top_cpu="ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu | head -10"
alias top_mem="ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -10"
alias psmem="ps auxf | sort -nr -k 4 | head -10"
alias pscpu="ps auxf | sort -nr -k 3 | head -10"
alias pstree="pstree -pula"

# -----------------------------
# Log viewing
# -----------------------------
alias watch_logs="journalctl -f"
alias logs="journalctl -xe"
alias system_logs="journalctl -b"
alias service_logs="journalctl -u"
alias error_logs="journalctl -p err..alert -b"

# -----------------------------
# Flatpak management
# -----------------------------
alias flatpak_list="flatpak list"
alias flatpak_clean="flatpak uninstall --unused -y && flatpak repair"
alias flatpak_update="flatpak update -y"
alias flatpak_install="flatpak install"
alias flatpak_remove="flatpak uninstall"
alias flatpak_search="flatpak search"
alias flatpak_run="flatpak run"
alias flatpak_info="flatpak info"

# -----------------------------
# Development tools
# -----------------------------
alias python="python3"
alias py="python3"
alias pip="pip3"
alias venv="python3 -m venv venv"
alias activate="source venv/bin/activate"

# NPM shortcuts
alias npmi="npm install"
alias npmg="npm install -g"
alias npmu="npm update"
alias npmr="npm run"
alias npms="npm start"
alias npmt="npm test"
alias npml="npm list --depth=0"
alias npmgl="npm list -g --depth=0"

# Yarn shortcuts
if command -v yarn &>/dev/null; then
    alias yi="yarn install"
    alias ya="yarn add"
    alias yad="yarn add --dev"
    alias yr="yarn remove"
    alias ys="yarn start"
    alias yt="yarn test"
    alias yb="yarn build"
fi

# -----------------------------
# Utility shortcuts
# -----------------------------
alias h="history | grep"
alias paths="echo $PATH | tr ':' '\n'"
alias path="echo $PATH | tr ':' '\n'"
alias now="date +\"%T\""
alias nowtime="now"
alias nowdate="date +\"%d-%m-%Y\""
alias week="date +%V"
alias extract="tar -xvf"
alias chrome="google-chrome-stable --ozone-platform=wayland"

# fzf shortcuts
if command -v fzf &>/dev/null; then
    alias fzfp="find . | fzf"
fi

# Better rsync defaults
alias rsync="rsync -avz --progress --one-file-system"
alias giga-rsync="rsync -avz --progress"
alias rsync-update="rsync -avzu --progress --delete"

# -----------------------------
# Personal script shortcuts
# -----------------------------
alias backup_gnome="$HOME/Repos/dotfiles/.scripts/tools/run_backup_gnome_settings.sh"
alias btrfs_backup="$HOME/Repos/dotfiles/.scripts/tools/run_btrfs_backup.sh"
alias bulk_rename="$HOME/Repos/dotfiles/.scripts/tools/run_bulk_rename.sh"alias wifi_signal="$HOME/Repos/dotfiles/.scripts/tools/run_check_wifi_signal.sh"
alias convert_video="$HOME/Repos/dotfiles/.scripts/tools/run_convert_video.sh"
alias diagnostics="$HOME/Repos/dotfiles/.scripts/tools/run_diagnostics.sh"
alias dnf_refresh="$HOME/Repos/dotfiles/.scripts/tools/run_dnf_refresh.sh"
alias find_large_files="$HOME/Repos/dotfiles/.scripts/tools/run_find_large_files.sh"
alias kill_high_cpu="$HOME/Repos/dotfiles/.scripts/tools/run_kill_high_cpu.sh"
alias mount_usb="$HOME/Repos/dotfiles/.scripts/tools/run_mount_usb.sh"
alias move_flatpaks="$HOME/Repos/dotfiles/.scripts/tools/run_move_flatpaks.sh"
alias benchmark="$HOME/Repos/dotfiles/.scripts/tools/run_performance_benchmark.sh"
alias record_terminal="$HOME/Repos/dotfiles/.scripts/tools/run_record_terminal.sh"
alias screenshot_ocr="$HOME/Repos/dotfiles/.scripts/tools/run_screenshot_ocr.sh"
alias network_diag="$HOME/Repos/dotfiles/.scripts/tools/run_network_diagnostics.sh"
alias system_diag="$HOME/Repos/dotfiles/.scripts/tools/run_system_diagnostics.sh"
alias system_migrate="$HOME/Repos/dotfiles/.scripts/tools/run_system_migration.sh"
alias watch_directory="$HOME/Repos/dotfiles/.scripts/tools/run_watch_directory.sh"

# Claude CLI shortcut
alias claude="$HOME/.claude/local/claude"

# Make scripts executable (run this once)
if [ -d "$HOME/Repos/dotfiles/.scripts/tools" ]; then
    chmod +x "$HOME/Repos/dotfiles/.scripts/tools"/*.sh 2>/dev/null
fi
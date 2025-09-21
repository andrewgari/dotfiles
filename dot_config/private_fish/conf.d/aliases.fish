# -------------------
# SSH Shortcuts
# -------------------
alias sshpc 'ssh andrewgari@192.168.50.2'
alias sshtower 'ssh root@192.168.50.3'
alias sshlaptop 'ssh andrewgari@192.168.50.4'
alias sshwork 'ssh root@192.168.50.10'

# -------------------
# 🔹 DOTFILES ALIASES
# -------------------

alias scripts 'cd ~/.scripts/tools'
alias claude '$HOME/.claude/local/claude'
# -------------------
# 🔹 SYSTEM UTILITIES
# -------------------

# Config file quick access
# Note: these aliases are for zsh. You might want to adapt them for fish.
# For example, to edit fish config: alias fishrc 'nvim ~/.config/fish/config.fish'
alias zshrc 'nvim ~/.zshrc'
alias aliases 'nvim ~/.zsh-aliases'
alias vimrc 'nvim ~/.config/nvim/init.lua'

# System info and monitoring

# File operations
alias trash 'mv --force -t ~/.local/share/Trash '
alias rm 'rm -i'  # Prompt before removing files
alias cp 'cp -i'  # Prompt before overwriting files
alias mv 'mv -i'  # Prompt before overwriting files
alias mkdir 'mkdir -p'  # Create parent directories as needed
alias md 'mkdir -p'  # Short for mkdir -p
alias print 'echo'
alias edit 'nvim'

# SSH connections
alias sshpc 'ssh andrewgari@192.168.50.2'
alias sshwork 'ssh andrewgari@192.168.50.11'
alias sshtower 'ssh root@192.168.50.3'

alias ssh_copy_id 'ssh-copy-id -i ~/.ssh/id_rsa.pub'  # Copy SSH key to server

# Copy/paste in terminal
alias c 'xclip -selection clipboard'
alias v 'xclip -selection clipboard -o'

# Modern CLI tools
# Bat (better `cat` replacement)
if command -v bat >/dev/null 2>&1
    alias cat 'bat --style=plain'
    alias bathelp 'bat --plain --language=help'
    alias catp 'bat -p'  # Plain mode (no line numbers, etc.)
end

if command -v eza >/dev/null 2>&1
    alias ls 'eza --color=always --group-directories-first --icons'
    alias ll 'eza -alF --color=always --group-directories-first --icons --header --git'
    alias la 'eza -a --color=always --group-directories-first --icons'
    alias l 'eza -F --color=always --group-directories-first --icons'
    alias l. 'eza -a --icons | string match -r "^".'
    alias lt 'eza -aT --color=always --group-directories-first --icons --level=2' # tree view
    alias llt 'eza -alFT --color=always --group-directories-first --icons --git --level=2'
end

# Use `duf` for better disk usage overview
if command -v duf >/dev/null 2>&1
    alias df 'duf --only local'
end

# Use `btop` or `htop` if installed
if command -v btop >/dev/null 2>&1
    alias top 'btop'
else if command -v htop >/dev/null 2>&1
    alias top 'htop'
end

# Use `rg` over `grep` if available
if command -v rg >/dev/null 2>&1
    alias grep 'rg'
end

alias status 'systemctl status'
alias start 'systemctl start'
alias enable 'systemctl enable'
alias disable 'systemctl disable'
alias stop 'systemctl stop'
alias restart 'systemctl daemon-reload'

alias restart_network 'sudo systemctl restart NetworkManager'

# -------------------
# 🔹 FILE & DIRECTORY NAVIGATION
# -------------------

# Directory navigation
alias repos 'cd ~/Repos'
alias starbunk 'cd ~/Repos/starbunk-js'
alias unraid 'cd /mnt/unraid'
alias -- - 'cd -'

# Better rsync defaults
alias rsync 'rsync -avz --progress --one-file-system'
alias giga-rsync 'rsync -avz --progress'
alias rsync-update 'rsync -avzu --progress --delete'

# -------------------
# 🔹 DOCKER & SYSTEMD
# -------------------

alias docker_restart 'sudo systemctl restart docker'
alias docker_cleanup 'docker system prune -a -f; and docker volume prune -f'

# Docker/Podman common aliases
alias dps 'docker ps'
alias dpa 'docker ps -a'
alias drm 'docker rm'
alias drmi 'docker rmi'
alias drma 'docker rm (docker ps -aq)'
alias dstop 'docker stop'
alias dstopa 'docker stop (docker ps -q)'
alias drestart 'docker restart'
alias dlogs 'docker logs'
alias dexec 'docker exec -it'
alias dimg 'docker images'
alias dcup 'docker-compose up -d'
alias dcdown 'docker-compose down'
alias dcps 'docker-compose ps'
alias dclogs 'docker-compose logs -f'
alias dcrestart 'docker-compose restart'

alias list_services 'systemctl list-units --type=service --state=running'
alias reload_systemd 'sudo systemctl daemon-reexec'

# -------------------
# 🔹 MISC SHORTCUTS
# -------------------

# Log viewing
alias watch_logs 'journalctl -f'
alias logs 'journalctl -xe'
alias system_logs 'journalctl -b'
alias service_logs 'journalctl -u'
alias error_logs 'journalctl -p err..alert -b'

# Process monitoring
alias top_cpu 'ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu | head -10'
alias top_mem 'ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -10'
alias psmem 'ps auxf | sort -nr -k 4 | head -10'
alias pscpu 'ps auxf | sort -nr -k 3 | head -10'
alias pstree 'pstree -pula'  # Process tree

# Common utilities
alias weather 'curl wttr.in'  # Show weather
alias h 'history | grep'  # Search history
alias ports 'netstat -tulanp'  # Show open ports
alias paths 'echo $PATH | tr ":" "\n"'
alias path 'echo $PATH | tr ":" "\n"'
alias now 'date +"%T"'
alias nowtime 'now'
alias nowdate 'date +"%d-%m-%Y"'
alias week 'date +%V'

# -------------------
# 🔹 FLATPAK & SOFTWARE
# -------------------

# Flatpak management
alias flatpak_list 'flatpak list'
alias flatpak_clean 'flatpak uninstall --unused -y; and flatpak repair'
alias flatpak_update 'flatpak update -y'
alias flatpak_install 'flatpak install'
alias flatpak_remove 'flatpak uninstall'
alias flatpak_search 'flatpak search'
alias flatpak_run 'flatpak run'
alias flatpak_info 'flatpak info'

# NPM shortcuts
alias npmi 'npm install'
alias npmg 'npm install -g'
alias npmu 'npm update'
alias npmr 'npm run'
alias npms 'npm start'
alias npmt 'npm test'
alias npml 'npm list --depth=0'
alias npmgl 'npm list -g --depth=0'

# Yarn shortcuts
if command -v yarn >/dev/null 2>&1
    alias yi 'yarn install'
    alias ya 'yarn add'
    alias yad 'yarn add --dev'
    alias yr 'yarn remove'
    alias ys 'yarn start'
    alias yt 'yarn test'
    alias yb 'yarn build'
end

# Development tools
alias python 'python3'
alias py 'python3'
alias pip 'pip3'
alias venv 'python3 -m venv venv'
alias activate 'source venv/bin/activate.fish' # fish activate script is different

# -----------------------------
# Zoxide Smart Navigation
# -----------------------------

if command -v zoxide >/dev/null 2>&1
    zoxide init fish | source
    alias z 'zoxide query --exclude (pwd)'
    alias zi 'zoxide query --interactive'
    alias za 'zoxide add'      # Add a directory manually
    alias zr 'zoxide remove'   # Remove a directory
    alias zri 'zoxide remove --interactive'  # Remove interactively
end

# -----------------------------
# Personal Scripts
# -----------------------------

set -x SCRIPTS_DIR "$HOME/Repos/dotfiles/.scripts/tools"

alias backup_gnome '$SCRIPTS_DIR/run_backup_gnome_settings.sh'
alias btrfs_backup '$SCRIPTS_DIR/run_btrfs_backup.sh'
alias bulk_rename '$SCRIPTS_DIR/run_bulk_rename.sh'
alias wifi_signal '$SCRIPTS_DIR/run_check_wifi_signal.sh'
alias convert_video '$SCRIPTS_DIR/run_convert_video.sh'
alias diagnostics '$SCRIPTS_DIR/run_diagnostics.sh'
alias dnf_refresh '$SCRIPTS_DIR/run_dnf_refresh.sh'
alias find_large_files '$SCRIPTS_DIR/run_find_large_files.sh'
alias kill_high_cpu '$SCRIPTS_DIR/run_kill_high_cpu.sh'
alias mount_usb '$SCRIPTS_DIR/run_mount_usb.sh'
alias move_flatpaks '$SCRIPTS_DIR/run_move_flatpaks.sh'
alias benchmark '$SCRIPTS_DIR/run_performance_benchmark.sh'
alias record_terminal '$SCRIPTS_DIR/run_record_terminal.sh'
alias screenshot_ocr '$SCRIPTS_DIR/run_screenshot_ocr.sh'
alias network_diag '$SCRIPTS_DIR/run_network_diagnostics.sh'
alias system_diag '$SCRIPTS_DIR/run_system_diagnostics.sh'
alias system_migrate '$SCRIPTS_DIR/run_system_migration.sh'
alias watch_directory '$SCRIPTS_DIR/run_watch_directory.sh'

# The following command makes scripts executable. This is generally fine.
# However, you might want to run this once manually rather than on every shell start.
# chmod +x $SCRIPTS_DIR/*.sh

alias chrome 'google-chrome-stable --ozone-platform=wayland'
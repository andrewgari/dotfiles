#!/bin/bash

# Dotfiles Download Script
# Syncs files from the dotfiles repository to the home directory.

DOTFILES_REPO="$HOME/Repos/dotfiles"
DOTFILES_REMOTE="git@github.com:andrewgari/.dotfiles"
BACKUP_DIR="$HOME/backups/dotfiles"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
DRY_RUN=false

# Parse arguments
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo -e "\n🟡 Running in dry-run mode (no changes will be made)."
fi

echo -e "\n🚀 Starting dotfiles download...\n"

# Ensure dotfiles repo exists
if [ ! -d "$DOTFILES_REPO/.git" ]; then
    echo "⚠️  Dotfiles repository not found. Cloning..."
    rm -rf "$DOTFILES_REPO"
    git clone "$DOTFILES_REMOTE" "$DOTFILES_REPO"
else
    echo "✅ Dotfiles repository found. Fetching latest changes..."
    cd "$DOTFILES_REPO" || { echo "❌ Error: Could not enter repo directory."; exit 1; }
    echo "⚠️  Force pulling latest changes (resetting local changes)..."
    git reset --hard origin/main
    git pull --force origin main
fi

# Backup before syncing
mkdir -p "$BACKUP_DIR"
BACKUP_FILE="$BACKUP_DIR/dotfiles-backup-$TIMESTAMP.tar.gz"
echo -e "\n💾 Creating backup of existing dotfiles at $BACKUP_FILE..."
tar -czf "$BACKUP_FILE" -C "$HOME" $(cd "$DOTFILES_REPO" && git ls-files) || { echo "❌ Error: Backup failed!"; exit 1; }
echo "✅ Backup complete."

# Sync dotfiles from repo to home
echo -e "\n🔄 Syncing dotfiles from repo to home...\n"

file_list=($(cd "$DOTFILES_REPO" && git ls-files))

for file in "${file_list[@]}"; do
    repo_file="$DOTFILES_REPO/$file"
    home_file="$HOME/$file"

    if [ -f "$repo_file" ]; then
        mkdir -p "$(dirname "$home_file")"
        if [ "$DRY_RUN" = true ]; then
            printf "🟡 [Dry Run] %-60s → %s\n" "$repo_file" "$home_file"
        else
            rsync -a "$repo_file" "$home_file" > /dev/null
            printf "✅ Synced: %-60s → %s\n" "$repo_file" "$home_file"
        fi
    fi
done

# Always sync .scripts/ folder
echo -e "\n🔄 Copying .scripts/ from repo to home (regardless of tracking status)...\n"

if [ "$DRY_RUN" = true ]; then
    printf "🟡 [Dry Run] %-60s → %s\n" "$DOTFILES_REPO/.scripts" "$HOME/.scripts"
else
    rsync -a "$DOTFILES_REPO/.scripts" "$HOME/.scripts" > /dev/null
    printf "✅ Synced: %-60s → %s\n" "$DOTFILES_REPO/.scripts" "$HOME/.scripts"
fi

echo -e "\n🎉 Dotfiles download complete!"
if [ "$DRY_RUN" = true ]; then
    echo "🟡 Dry-run mode: No changes were actually made."
fi

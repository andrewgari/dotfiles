#!/bin/bash

# Set paths
DOTFILES_REPO="$HOME/Repos/dotfiles"
BACKUP_DIR="$HOME/backups/dotfiles"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="$BACKUP_DIR/dotfiles-backup-$TIMESTAMP.tar.gz"
DRY_RUN=false

# Parse arguments
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "🟡 Running in dry-run mode (no changes will be made)."
fi

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Check if repo exists
if [ ! -d "$DOTFILES_REPO/.git" ]; then
    echo "📂 Dotfiles repository not found. Cloning fresh..."
    rm -rf "$DOTFILES_REPO"  # Ensure a clean state
    git clone --depth=1 git@github.com:andrewgari/.dotfiles "$DOTFILES_REPO"
else
    echo "✅ Dotfiles repository found. Fetching latest changes..."
    git -C "$DOTFILES_REPO" fetch --all
    echo "⚠️ Force pulling latest changes (resetting local changes)..."
    git -C "$DOTFILES_REPO" reset --hard origin/main
    git -C "$DOTFILES_REPO" clean -fd
fi

# Backup tracked home dotfiles before applying repo changes
if [ "$DRY_RUN" = false ]; then
    valid_files=""
    for file in $(git -C "$DOTFILES_REPO" ls-files); do
        if [ -f "$HOME/$file" ]; then
            valid_files="$valid_files $file"
        fi
    done

    if [ -n "$valid_files" ]; then
        tar -czf "$BACKUP_FILE" -C "$HOME" $valid_files
        printf "✅ Backup saved at: %s\n" "$BACKUP_FILE"
    else
        echo "⚠️ No valid files to back up."
    fi
else
    echo "🟡 [Dry Run] Would backup tracked files."
fi

# Sync repo → home (overwrite always)
echo -e "\n🔄 Syncing dotfiles from repo to home..."
if [ "$DRY_RUN" = true ]; then
    printf "🟡 [Dry Run] Would sync repo to home (without deletion): %-60s → %s\n" "$DOTFILES_REPO/" "$HOME/"
else
    rsync -a --update --exclude ".git" "$DOTFILES_REPO/" "$HOME/"
    printf "✅ Synced repo to home safely (only updating older files).\n"
fi

# Sync home → repo (only if home file is newer)
echo -e "\n🔄 Syncing tracked files from home to repo..."
file_list=($(git -C "$DOTFILES_REPO" ls-files))

for file in "${file_list[@]}"; do
    home_file="$HOME/$file"
    repo_file="$DOTFILES_REPO/$file"

    if [ -f "$home_file" ]; then
        mkdir -p "$(dirname "$repo_file")"

        # Compare timestamps to avoid overwriting newer files in the repo
        if [ "$home_file" -nt "$repo_file" ]; then
            if [ "$DRY_RUN" = true ]; then
                printf "🟡 [Dry Run] Would sync: %-60s → %s\n" "$home_file" "$repo_file"
            else
                rsync -a "$home_file" "$repo_file"
                printf "✅ Synced: %-60s → %s\n" "$home_file" "$repo_file"
            fi
        fi
    fi
done

# Stage, commit, and push changes
echo -e "\n📝 Staging and committing changes..."
if [ "$DRY_RUN" = true ]; then
    printf "🟡 [Dry Run] Would stage changes in repo.\n"
else
    git -C "$DOTFILES_REPO" add .
fi

if git -C "$DOTFILES_REPO" diff --cached --quiet; then
    echo "✅ No changes to commit."
else
    CHANGED_FILES=$(git -C "$DOTFILES_REPO" diff --cached --name-only | sed 's/^/- /')
    COMMIT_MSG="🔄 Automated sync of dotfiles"
    
    if [ "$DRY_RUN" = true ]; then
        printf "🟡 [Dry Run] Would commit changes: %s\n" "$COMMIT_MSG"
    else
        git -C "$DOTFILES_REPO" commit -m "$COMMIT_MSG"
        git -C "$DOTFILES_REPO" push origin main
        printf "✅ Committed and pushed changes.\n"
    fi
fi

echo -e "\n🎉 Dotfiles sync complete!"
if [ "$DRY_RUN" = true ]; then
    echo "🟡 Dry-run mode: No changes were actually made."
fi

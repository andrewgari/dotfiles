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

# Ensure dotfiles repo exists
if [ ! -d "$DOTFILES_REPO/.git" ]; then
    echo "📂 Dotfiles repository not found. Cloning fresh..."
    rm -rf "$DOTFILES_REPO"  # Ensure a clean state
    git clone --depth=1 --quiet git@github.com:andrewgari/.dotfiles "$DOTFILES_REPO"
else
    echo "✅ Dotfiles repository found. Fetching latest changes..."
    git -C "$DOTFILES_REPO" fetch --all --quiet
    echo "⚠️ Force pulling latest changes (resetting local changes)..."
    git -C "$DOTFILES_REPO" reset --hard origin/main --quiet
    git -C "$DOTFILES_REPO" clean -fd --quiet
fi

# Backup existing dotfiles in home before adding new ones
echo "📦 Creating backup of current tracked dotfiles before adding..."
tracked_files=$(git -C "$DOTFILES_REPO" ls-files)

if [ "$DRY_RUN" = true ]; then
    printf "🟡 [Dry Run] Would backup home files to: %s\n" "$BACKUP_FILE"
else
    tar -czf "$BACKUP_FILE" -C "$HOME" $tracked_files
    printf "✅ Backup saved at: %s\n" "$BACKUP_FILE"
fi

# Keep only the last 10 backups
BACKUP_COUNT=$(ls -t "$BACKUP_DIR"/dotfiles-backup-* 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt 10 ]; then
    echo "🗑 Keeping only the latest 10 backups, deleting older ones..."
    if [ "$DRY_RUN" = true ]; then
        ls -t "$BACKUP_DIR"/dotfiles-backup-* 2>/dev/null | tail -n +11 | xargs -I {} echo "🟡 [Dry Run] Would delete: {}"
    else
        ls -t "$BACKUP_DIR"/dotfiles-backup-* 2>/dev/null | tail -n +11 | xargs rm -rf
    fi
fi

# Add new files to the repo
echo -e "\n➕ Adding new dotfiles to the repo..."
while IFS= read -r file; do
    home_file="$HOME/$file"
    repo_file="$DOTFILES_REPO/$file"

    if [ -f "$home_file" ]; then
        mkdir -p "$(dirname "$repo_file")"
        
        if [ "$DRY_RUN" = true ]; then
            printf "🟡 [Dry Run] Would add: %-60s → %s\n" "$home_file" "$repo_file"
        else
            cp "$home_file" "$repo_file"
            printf "✅ Added: %-60s → %s\n" "$home_file" "$repo_file"
        fi
    else
        echo "⚠️ Skipping: $home_file (does not exist)"
    fi
done <<< "$(git -C "$DOTFILES_REPO" ls-files --others --exclude-standard)"

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
    COMMIT_MSG="➕ Automated addition of new dotfiles"

    if [ "$DRY_RUN" = true ]; then
        printf "🟡 [Dry Run] Would commit changes: %s\n" "$COMMIT_MSG"
    else
        git -C "$DOTFILES_REPO" commit -m "$COMMIT_MSG" --quiet
        git -C "$DOTFILES_REPO" push origin main --quiet
        printf "✅ Committed and pushed changes.\n"
    fi
fi

echo -e "\n🎉 Dotfiles add complete!"
if [ "$DRY_RUN" = true ]; then
    echo "🟡 Dry-run mode: No changes were actually made."
fi


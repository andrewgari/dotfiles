#!/bin/bash

# Dotfiles Upload Script
# Syncs tracked files from home to the dotfiles repository.

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

echo -e "\n🚀 Starting dotfiles upload...\n"

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
echo -e "\n💾 Creating backup of tracked dotfiles at $BACKUP_FILE..."

tracked_files=$(cd "$DOTFILES_REPO" && git ls-files)
if [ -n "$tracked_files" ]; then
    tar -czf "$BACKUP_FILE" -C "$HOME" $tracked_files || { echo "❌ Error: Backup failed!"; exit 1; }
    echo "✅ Backup complete."
else
    echo "⚠️ No tracked files found to backup."
fi

# 🔄 **Sync ONLY tracked dotfiles from home to repo**
echo -e "\n🔄 Syncing tracked dotfiles from home to repo...\n"

while IFS= read -r file; do
    home_file="$HOME/$file"
    repo_file="$DOTFILES_REPO/$file"

    if [ -f "$home_file" ] || [ -d "$home_file" ]; then
        mkdir -p "$(dirname "$repo_file")"
        if [ "$DRY_RUN" = true ]; then
            printf "🟡 [Dry Run] %-60s → %s\n" "$home_file" "$repo_file"
        else
            cp -r --preserve=all "$home_file" "$repo_file"
            git -C "$DOTFILES_REPO" add "$repo_file"
            printf "✅ Synced: %-60s → %s\n" "$home_file" "$repo_file"
        fi
    fi
done < <(cd "$DOTFILES_REPO" && git ls-files)

# 🔄 **Fix `.scripts/` Sync (No Nesting)**
echo -e "\n🔄 Copying .scripts/ (ensuring no .scripts/.scripts/ nesting)...\n"

mkdir -p "$DOTFILES_REPO/.scripts"

find "$HOME/.scripts" -type f | while IFS= read -r file; do
    relative_path="${file#$HOME/}"  # Get relative path
    repo_file="$DOTFILES_REPO/$relative_path"

    mkdir -p "$(dirname "$repo_file")"
    
    if [ "$DRY_RUN" = true ]; then
        printf "🟡 [Dry Run] %-60s → %s\n" "$file" "$repo_file"
    else
        cp --preserve=all "$file" "$repo_file"
        git -C "$DOTFILES_REPO" add "$repo_file"
        printf "✅ Synced: %-60s → %s\n" "$file" "$repo_file"
    fi
done

# Commit and push changes if any
if git -C "$DOTFILES_REPO" diff --cached --quiet; then
    echo -e "\n✅ No changes to commit."
else
    CHANGED_FILES=$(git -C "$DOTFILES_REPO" diff --cached --name-only | sed 's/^/- /')
    LAST_COMMIT_MSG=$(git -C "$DOTFILES_REPO" log -1 --pretty=%s)

    if [[ "$LAST_COMMIT_MSG" =~ ^🔄\ Automated\ push\ of\ dotfiles ]]; then
        echo "🔄 Amending last commit..."
        if [ "$DRY_RUN" = true ]; then
            echo "🟡 [Dry Run] Would amend last commit."
        else
            git -C "$DOTFILES_REPO" commit --amend -m "🔄 Automated push of dotfiles\n\nChanged files:\n$CHANGED_FILES"
        fi
    else
        echo "📝 Creating a new commit..."
        if [ "$DRY_RUN" = true ]; then
            echo "🟡 [Dry Run] Would create a new commit."
        else
            git -C "$DOTFILES_REPO" commit -m "🔄 Automated push of dotfiles\n\nChanged files:\n$CHANGED_FILES"
        fi
    fi

    if [ "$DRY_RUN" = true ]; then
        echo "🟡 [Dry Run] Would push changes to remote."
    else
        git -C "$DOTFILES_REPO" push origin main
    fi
fi

echo -e "\n🎉 Dotfiles upload complete!"
if [ "$DRY_RUN" = true ]; then
    echo "🟡 Dry-run mode: No changes were actually made."
fi


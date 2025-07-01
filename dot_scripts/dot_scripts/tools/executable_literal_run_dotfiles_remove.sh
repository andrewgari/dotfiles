#!/bin/bash

# Script to remove dotfiles from the dotfiles repository
DOTFILES_REPO=git@github.com:andrewgari/.dotfiles
DOTFILES_DIR=~/Repos/dotfiles
DRY_RUN=false

# Parse arguments
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    shift  # Remove --dry-run from argument list
fi

# Ensure repository exists
if [ ! -d "$DOTFILES_DIR/.git" ]; then
    echo "📥 Cloning dotfiles repository..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

if [ $# -eq 0 ]; then
    echo "❌ Please specify at least one file to remove."
    exit 1
fi

# Function to display a progress bar
progress_bar() {
    local total=$1
    local current=$2
    local width=40  # Width of the progress bar

    local progress=$(( current * width / total ))
    local remaining=$(( width - progress ))

    printf "\r["
    printf "%0.s#" $(seq 1 $progress)  # Filled part
    printf "%0.s-" $(seq 1 $remaining)  # Empty part
    printf "] %d%% - Processing: %s" $(( current * 100 / total )) "$3"
}

# Convert all file paths to their corresponding repo paths
file_list=()
for file in "$@"; do
    if [ -e "$file" ]; then
        file_list+=("$(realpath "$file")")
    else
        echo "⚠️ Warning: File $file does not exist, skipping."
    fi
done

total_files=${#file_list[@]}
current_file=0

# Process each file
for file_path in "${file_list[@]}"; do
    ((current_file++))
    progress_bar "$total_files" "$current_file" "$file_path"

    relative_path="${file_path#$HOME/}"
    target_path="$DOTFILES_DIR/$relative_path"

    if [ -f "$target_path" ]; then
        if [ "$DRY_RUN" = true ]; then
            echo -e "\n🟡 [Dry Run] Would remove: $target_path"
        else
            rm "$target_path"
            git -C "$DOTFILES_DIR" rm "$relative_path" > /dev/null
        fi
    else
        echo -e "\n⚠️ File $relative_path does not exist in the repository, skipping."
    fi
done

# Move to a new line after progress bar completion
echo ""
echo "✅ Dotfiles removal complete."
if [ "$DRY_RUN" = true ]; then
    echo "🟡 Dry-run mode: No changes were actually made."
fi


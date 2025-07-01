#!/bin/bash
set -e  # Exit on error

GITHUB_EMAIL="covadax.ag@gmail.com"
GITHUB_USERNAME="andrewgari"

echo "🔑 Checking for an existing GitHub SSH key..."

SSH_DIR="$HOME/.ssh"
SSH_KEY="$SSH_DIR/github_rsa"
SSH_CONFIG="$SSH_DIR/config"

mkdir -p "$SSH_DIR"  # Ensure SSH directory exists

if [[ -f "$SSH_KEY" ]]; then
    echo "✅ SSH key already exists: $SSH_KEY"
else
    echo "🛠 Generating a new SSH key for GitHub..."
    ssh-keygen -t rsa -b 4096 -C "$GITHUB_EMAIL" -f "$SSH_KEY" -N ""
    echo "✅ SSH key generated: $SSH_KEY"
fi

echo "🔓 Adding SSH key to the SSH agent..."
eval "$(ssh-agent -s)"
ssh-add "$SSH_KEY"

echo "🔧 Configuring SSH for GitHub..."
if ! grep -q "Host github.com" "$SSH_CONFIG" 2>/dev/null; then
    cat <<EOF >> "$SSH_CONFIG"

Host github.com
  User git
  IdentityFile $SSH_KEY
  AddKeysToAgent yes
EOF
    echo "✅ SSH config updated: $SSH_CONFIG"
else
    echo "✅ SSH config already set for GitHub."
fi

echo "📋 Copying SSH key..."
SSH_PUB_KEY=$(cat "$SSH_KEY.pub")

echo "🔗 Adding SSH key to GitHub..."
if gh auth status &>/dev/null; then
    gh ssh-key add "$SSH_KEY.pub" --title "$(hostname) GitHub SSH Key"
    echo "✅ SSH key added to GitHub."
else
    echo "❌ GitHub CLI is not authenticated. Run 'gh auth login' first."
    exit 1
fi

echo "🔄 Testing GitHub SSH access..."
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "✅ SSH authentication with GitHub is successful!"
else
    echo "❌ SSH authentication failed. Check your SSH config."
    exit 1
fi

echo "🔧 Configuring Git to use SSH..."
git config --global user.name "$GITHUB_USERNAME"
git config --global user.email "$GITHUB_EMAIL"
git config --global url."git@github.com:".insteadOf "https://github.com/"

echo "✅ GitHub SSH setup and Git config complete!"


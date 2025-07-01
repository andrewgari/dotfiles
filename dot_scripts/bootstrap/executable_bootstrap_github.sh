#!/bin/bash

set -e  # Exit on error

GITHUB_USERNAME="andrewgari"
GITHUB_EMAIL="covadax.ag@gmail.com"
GIT_CONFIG_DIR="$HOME/.config/git"
GIT_CREDENTIALS_FILE="$GIT_CONFIG_DIR/credentials"
KEY_DIR="$HOME/.ssh"
KEY_FILE="$KEY_DIR/github_rsa"
SSH_CONFIG_FILE="$KEY_DIR/config"

# Git Configuration
echo "🔧 Configuring Git..."
git config --global url."git@github.com:".insteadOf "https://github.com/"
git config --global user.name "$GITHUB_USERNAME"
git config --global user.email "$GITHUB_EMAIL"
git config --global core.editor "nvim"
git config --global credential.helper store
git config --global init.defaultBranch main
echo "✅ Git configuration updated."

# Git Aliases
echo "🔧 Setting up Git aliases..."
git config --global alias.undo 'reset --soft HEAD~1'
git config --global alias.undo-hard 'reset --hard HEAD~1'
git config --global alias.amend 'commit --amend --no-edit'
git config --global alias.unstage 'reset HEAD --'
git config --global alias.restore 'checkout --'
git config --global alias.lg "log --oneline --graph --decorate --all"
git config --global alias.last "log -1 HEAD --stat"
git config --global alias.changes "diff --name-only HEAD~1"
git config --global alias.blame 'blame -w -M -C --show-email'
git config --global alias.st 'status -sb'
git config --global alias.clean-untracked 'clean -fd'
git config --global alias.flush 'gc --prune=now'
git config --global alias.br 'branch -a'
git config --global alias.co 'checkout'
git config --global alias.rename-branch 'branch -m'
git config --global alias.up 'pull --rebase'
git config --global alias.sync 'fetch --all --prune'
git config --global alias.pushf 'push --force-with-lease'
git config --global alias.rebase-main 'rebase origin/main'
git config --global alias.rebase-dev 'rebase origin/develop'
git config --global alias.s 'stash'
git config --global alias.slist 'stash list'
git config --global alias.spop 'stash pop'
git config --global alias.sdrop 'stash drop'
git config --global alias.ssave 'stash push -m'
git config --global alias.patch "diff --staged > patch.diff"
git config --global alias.apply-patch "apply patch.diff"
git config --global alias.fuck-hard "reset --hard HEAD~1"
git config --global alias.fuck "reset --soft HEAD~1"
git config --global alias.ohfuck "checkout ."
git config --global alias.fuckoff "stash push -m 'WIP'"
git config --global alias.unfuck "stash pop"
git config --global alias.fuckit "commit -am 'Fix shit'"
git config --global alias.nope "revert HEAD"
git config --global alias.fix '!~/.scripts/git-fix.sh'
git config --global alias.time-travel '!~/.scripts/git-time-travel.sh'
git config --global alias.clone-setup '!~/.scripts/git-clone-setup.sh'
git config --global alias.cleanup '!~/.scripts/git-cleanup.sh'
git config --global alias.what-if '!~/.scripts/git-what-if.sh'
git config --global alias.issue '!~/.scripts/gh-issue.sh'
git config --global alias.push-rebase '!~/.scripts/git-push-rebase.sh'
echo "✅ Git aliases configured."

# GPG Signing
echo "🔐 Setting up GPG signing..."
# Get the GPG key ID
GPG_KEY_ID="$(gpg --list-secret-keys --keyid-format=long | grep sec | awk '{print $2}' | cut -d '/' -f2 | head -n 1)"

if [ -z "$GPG_KEY_ID" ]; then
    echo "No GPG key found. Generating new key..."
    # Generate a new GPG key
    gpg --batch --generate-key <<EOF
%echo Generating a GPG key
Key-Type: ED25519
Key-Length: 4096
Name-Real: $GITHUB_USERNAME
Name-Email: $GITHUB_EMAIL
Expire-Date: 0
%no-protection
%commit
%echo Done
EOF
    GPG_KEY_ID="$(gpg --list-secret-keys --keyid-format=long | grep sec | awk '{print $2}' | cut -d '/' -f2 | head -n 1)"
fi

# Configure Git to use GPG
git config --global commit.gpgSign true
git config --global user.signingkey "$GPG_KEY_ID"
echo "✅ GPG signing configured."

# Git Hooks
echo "🔧 Creating pre-push hook..."
GIT_HOOKS_DIR="$HOME/.git-hooks"
mkdir -p "$GIT_HOOKS_DIR"

cat << 'EOF' > "$GIT_HOOKS_DIR/pre-push"
#!/bin/bash
echo "🔍 Running pre-push checks..."
if command -v eslint &> /dev/null; then
    echo "✅ Running ESLint..."
    eslint .
elif command -v golangci-lint &> /dev/null; then
    echo "✅ Running Go lint..."
    golangci-lint run
elif command -v shellcheck &> /dev/null; then
    echo "✅ Running ShellCheck..."
    shellcheck **/*.sh
else
    echo "⚠️  No linter found! Consider installing one."
    # Don't exit with error, just warn
fi
echo "✅ Pre-push checks passed!"
EOF

chmod +x "$GIT_HOOKS_DIR/pre-push"
git config --global core.hooksPath "$GIT_HOOKS_DIR"
echo "✅ Global Git hooks enabled at $GIT_HOOKS_DIR"

# GitHub CLI Configuration
echo "🔧 Configuring GitHub CLI (gh)..."
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) not found. Installing..."
    if command -v dnf &> /dev/null; then
        sudo dnf install -y gh
    elif command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y gh
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm github-cli
    else
        echo "Unsupported package manager. Install GitHub CLI manually."
        exit 1
    fi
fi
echo "✅ GitHub CLI configured."

# SSH Key Setup
echo "🔑 Setting up SSH Key for GitHub..."
mkdir -p "$KEY_DIR"
chmod 700 "$KEY_DIR"
if [ ! -f "$KEY_FILE" ]; then
    ssh-keygen -t rsa -b 4096 -C "$GITHUB_EMAIL" -f "$KEY_FILE" -N ""
fi

# Configure SSH to always use this key for GitHub
echo "🔧 Configuring SSH for GitHub..."
if [ ! -f "$SSH_CONFIG_FILE" ]; then
    touch "$SSH_CONFIG_FILE"
fi

# Remove any existing GitHub host config
sed -i '/^Host github.com/,/^$/{/^$/!d}' "$SSH_CONFIG_FILE"

# Add GitHub configuration
cat << EOF >> "$SSH_CONFIG_FILE"
Host github.com
    HostName github.com
    User git
    IdentityFile $KEY_FILE
    AddKeysToAgent yes
    IdentitiesOnly yes
EOF

chmod 600 "$SSH_CONFIG_FILE"

# Start ssh-agent and add key
eval "$(ssh-agent -s)"
ssh-add "$KEY_FILE"

# Set correct permissions
chmod 600 "$KEY_FILE"
chmod 644 "$KEY_FILE.pub"

# Add ssh-agent autostart to shell rc file
SHELL_RC="$HOME/.$(basename "$SHELL")rc"
if [ -f "$SHELL_RC" ]; then
    if ! grep -q "ssh-agent" "$SHELL_RC"; then
        echo '# Start SSH agent if not running' >> "$SHELL_RC"
        echo 'if [ -z "$SSH_AUTH_SOCK" ]; then' >> "$SHELL_RC"
        echo '    eval "$(ssh-agent -s)" > /dev/null' >> "$SHELL_RC"
        echo '    ssh-add "$HOME/.ssh/github_rsa" 2>/dev/null' >> "$SHELL_RC"
        echo 'fi' >> "$SHELL_RC"
    fi
fi

echo "✅ SSH Key setup complete. Add this key to GitHub:"
cat "$KEY_FILE.pub"

echo "🎉 Git and GitHub setup completed successfully!"


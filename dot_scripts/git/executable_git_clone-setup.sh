#!/bin/bash
if [ -z "$1" ]; then
    echo "❌ Usage: $0 <repo-url>"
    exit 1
fi

REPO_NAME=$(basename "$1" .git)

echo "🚀 Cloning $1..."
git clone "$1"
cd "$REPO_NAME" || exit

echo "⚡ Running setup..."
if [ -f "package.json" ]; then
    npm install
elif [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
elif [ -f "Makefile" ]; then
    make
fi

echo "✅ Setup complete!"


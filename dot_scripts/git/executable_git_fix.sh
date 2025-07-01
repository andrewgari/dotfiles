#!/bin/bash
set -e  # Exit on error

MSG=${1:-"🔧 Quick fix"}

echo "🛠 Staging all changes..."
git add .

echo "📝 Committing with message: $MSG"
git commit -m "$MSG"

echo "🚀 Pushing to remote..."
git push

echo "✅ Done!"


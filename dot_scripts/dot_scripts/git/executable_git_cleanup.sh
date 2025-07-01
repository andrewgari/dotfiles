#!/bin/bash
echo "🧹 Cleaning up merged branches..."
git branch --merged | grep -v "\*" | xargs -r git branch -d

echo "🔄 Pruning remote branches..."
git fetch --prune

echo "✅ Cleanup complete!"


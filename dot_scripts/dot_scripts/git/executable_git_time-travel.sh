#!/bin/bash
if [ -z "$1" ]; then
    echo "❌ Usage: $0 <time> (e.g., '3 days ago', 'last week')"
    exit 1
fi

echo "⏳ Checking out commit from: $1"
COMMIT=$(git rev-list -n 1 --before="$1" HEAD)

if [ -z "$COMMIT" ]; then
    echo "❌ No commits found for that time!"
    exit 1
fi

git checkout "$COMMIT"
echo "✅ You are now in the past!"


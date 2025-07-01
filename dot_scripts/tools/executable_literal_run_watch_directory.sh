#!/bin/bash

DIRECTORY="$1"

if [[ -z "$DIRECTORY" ]]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

echo "Watching $DIRECTORY for changes..."
inotifywait -m -r -e create,delete,modify $DIRECTORY

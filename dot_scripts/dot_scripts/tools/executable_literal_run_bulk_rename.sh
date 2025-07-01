#!/bin/bash

COUNT=1
for FILE in *; do
    if [ -f "$FILE" ]; then
        EXT="${FILE##*.}"
        mv "$FILE" "file_$COUNT.$EXT"
        ((COUNT++))
    fi
done

echo "Files renamed successfully."

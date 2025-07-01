#!/bin/bash

INPUT_FILE="$1"
OUTPUT_FILE="${INPUT_FILE%.*}.mp4"

if [ -z "$INPUT_FILE" ]; then
    echo "Usage: $0 <video_file>"
    exit 1
fi

echo "Converting $INPUT_FILE to MP4..."
ffmpeg -i "$INPUT_FILE" -vcodec libx264 -crf 23 -preset fast -acodec aac -b:a 192k "$OUTPUT_FILE"

if [ $? -eq 0 ]; then
    echo "Conversion complete: $OUTPUT_FILE"
else
    echo "Conversion failed."
fi

#!/bin/bash

FILE="screenshot.png"

echo "Taking screenshot..."
gnome-screenshot -f $FILE

echo "Extracting text..."
tesseract $FILE output.txt

echo "OCR Result:"
cat output.txt

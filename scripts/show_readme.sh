#!/bin/bash

# Define paths
REPO_ROOT="$(dirname "$0")/.."  # Move up one level from scripts/
MISC_DIR="$REPO_ROOT/misc_files"
README_SRC="$MISC_DIR/README.txt"
README_DEST="$HOME/README.txt"

# Ensure README.txt exists before moving
if [ -f "$README_SRC" ]; then
    mv "$README_SRC" "$README_DEST"
    echo "📄 README.txt moved to $README_DEST"
else
    echo "⚠ README.txt not found in $MISC_DIR."
    exit 1
fi

# Open README.txt with the default text editor
if command -v xdg-open &>/dev/null; then
    xdg-open "$README_DEST"
elif command -v gnome-text-editor &>/dev/null; then
    gnome-text-editor "$README_DEST"
elif command -v nano &>/dev/null; then
    nano "$README_DEST"
else
    echo "⚠ No suitable text editor found to open README.txt."
fi

exit 0

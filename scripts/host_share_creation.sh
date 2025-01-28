#!/bin/bash

# Directory where host shared folders are mounted
HGFS_DIR="/mnt/hgfs"
# Directory to store the .desktop files (default is the user's Desktop)
DESKTOP_DIR="$HOME/Desktop"

# Check if /mnt/hgfs exists
if [[ ! -d "$HGFS_DIR" ]]; then
  echo "Error: $HGFS_DIR does not exist. Ensure your shared folders are mounted."
  exit 1
fi

# Create shortcuts for each folder in /mnt/hgfs
for folder in "$HGFS_DIR"/*; do
  if [[ -d "$folder" ]]; then
    folder_name=$(basename "$folder")
    desktop_file="$DESKTOP_DIR/Host_Share_${folder_name}.desktop"

    # Generate .desktop file content
    cat <<EOL > "$desktop_file"
[Desktop Entry]
Name=Host Share - $folder_name
Comment=Shortcut for access to $folder_name on the host machine
Exec=xdg-open "$folder"
Icon=folder
Terminal=false
Type=Application
EOL

    # Make the .desktop file executable
    chmod +x "$desktop_file"
    echo "Shortcut created: $desktop_file"
  fi
done

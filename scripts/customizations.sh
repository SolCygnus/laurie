#!/bin/bash

# Purpose: Create a host share folder, set custom background, and update Bash prompt.

# Directory where host shared folders are mounted
HGFS_DIR="/mnt/hgfs"
# Directory to store the .desktop files (default is the user's Desktop)
DESKTOP_DIR="$HOME/Desktop"

# Ensure xdg-utils is installed for opening directories
if ! command -v xdg-open &>/dev/null; then
    echo "🔧 Installing xdg-utils for shortcut functionality..."
    if ! apt install -y xdg-utils; then
        echo "❌ Failed to install xdg-utils. Exiting."
        exit 1
    fi
fi

# Ensure /mnt/hgfs exists
if [[ ! -d "$HGFS_DIR" ]]; then
    echo "❌ Error: $HGFS_DIR does not exist. Ensure VMware Tools or open-vm-tools are installed."
    exit 1
fi

# Ensure Desktop directory exists
mkdir -p "$DESKTOP_DIR"

# Create shortcuts for each folder in /mnt/hgfs
echo "🔗 Creating shared folder shortcuts..."
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
        echo "✅ Shortcut created: $desktop_file"
    fi
done

echo "🎉 Host share shortcuts setup complete!"

### Set Custom Background ###

# Define the absolute path to the background image
BACKGROUND_IMAGE="/usr/share/backgrounds/custom_wallpaper.jpg"  # Update this path

# Ensure the file exists before applying
if [[ -f "$BACKGROUND_IMAGE" ]]; then
    gsettings set org.cinnamon.desktop.background picture-uri "file://$BACKGROUND_IMAGE"
    gsettings set org.cinnamon.desktop.background picture-options "zoom"  # Options: none, wallpaper, centered, scaled, stretched, zoom, spanned
    echo "✅ Desktop background set successfully: $BACKGROUND_IMAGE"
else
    echo "❌ Background image not found. Please check the path: $BACKGROUND_IMAGE"
    exit 1
fi

### Set Custom Bash Prompt ###
SWORD="
▬▬ι═════════════ﺤ
"
QUOTE="With great power comes great responsibility."

# Define the color codes (ANSI escape sequences)
RED='\[\e[31m\]'
GREEN='\[\e[32m\]'
BLUE='\[\e[34m\]'
WHITE='\[\e[37m\]'
RESET='\[\e[0m\]'

# Construct the PS1 prompt
CUSTOM_PS1="${RED}${SWORD}${WHITE}${QUOTE}\n${GREEN}\u@\h:\w \$ ${RESET}"

# Persist the change in ~/.bashrc
if ! grep -q "CUSTOM_PS1" ~/.bashrc; then
    echo -e "\n# Custom Bash Prompt with ASCII Sword" >> ~/.bashrc
    echo "export PS1='${CUSTOM_PS1//\\/\\\\}'" >> ~/.bashrc
    echo "✅ Custom prompt added to ~/.bashrc."
else
    echo "ℹ️ Custom prompt already exists in ~/.bashrc."
fi

# Reload ~/.bashrc (will not apply in non-interactive shells)
echo "🔄 Reloading Bash configuration..."
source ~/.bashrc || echo "ℹ️ Changes will apply on next login."

echo "✅ Setup complete!"
exit 0
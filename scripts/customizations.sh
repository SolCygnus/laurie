#!/bin/bash

# Purpose: Create a host share folder, set a custom background, and update the Bash prompt.

# Directory where host shared folders are mounted
HGFS_DIR="/mnt/hgfs"
DESKTOP_DIR="$HOME/Desktop"

# Ensure xdg-utils is installed
install_xdg_utils() {
    if ! command -v xdg-open &>/dev/null; then
        echo "🔧 Installing xdg-utils..."
        if ! apt install -y xdg-utils; then
            echo "❌ Failed to install xdg-utils."
            return 1
        fi
    fi
    echo "✅ xdg-utils is installed."
}

# Setup host shared folders
setup_shared_folder() {
    if [[ ! -d "$HGFS_DIR" ]]; then
        echo "❌ $HGFS_DIR does not exist. Ensure VMware Tools or open-vm-tools are installed."
        return 1
    fi

    mkdir -p "$DESKTOP_DIR"

    echo "🔗 Creating shared folder shortcuts..."
    for folder in "$HGFS_DIR"/*; do
        if [[ -d "$folder" ]]; then
            folder_name=$(basename "$folder")
            desktop_file="$DESKTOP_DIR/Host_Share_${folder_name}.desktop"

            cat <<EOL > "$desktop_file"
[Desktop Entry]
Name=Host Share - $folder_name
Comment=Shortcut for access to $folder_name on the host machine
Exec=xdg-open "$folder"
Icon=folder
Terminal=false
Type=Application
EOL

            chmod +x "$desktop_file"
            echo "✅ Shortcut created: $desktop_file"
        fi
    done
    echo "🎉 Host share shortcuts setup complete!"
}

# Set custom background
set_background_image() {
    REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    BACKGROUND_IMAGE="$REPO_DIR/background/E61317.jpg"
    TARGET_PATH="/usr/share/backgrounds/E61317.jpg"

    if [[ -f "$BACKGROUND_IMAGE" ]]; then
        sudo cp "$BACKGROUND_IMAGE" "$TARGET_PATH"
        echo "✅ Background image copied successfully."
    else
        echo "❌ Background image not found: $BACKGROUND_IMAGE."
        return 1
    fi

    gsettings set org.cinnamon.desktop.background picture-uri "file://$TARGET_PATH"
    gsettings set org.cinnamon.desktop.background picture-options "zoom"
    echo "🖼️ Background set successfully."
}

# Set custom Bash prompt
set_bash_prompt() {
    SWORD="
▬▬ι═════════════ﺤ
"
    QUOTE="With great power comes great responsibility."
    RED='\[\e[31m\]'
    GREEN='\[\e[32m\]'
    WHITE='\[\e[37m\]'
    RESET='\[\e[0m\]'
    CUSTOM_PS1="${RED}${SWORD}${WHITE}${QUOTE}\n${GREEN}\u@\h:\w \$ ${RESET}"

    if ! grep -q "CUSTOM_PS1" ~/.bashrc; then
        echo -e "\n# Custom Bash Prompt" >> ~/.bashrc
        echo "export PS1='${CUSTOM_PS1//\\/\\\\}'" >> ~/.bashrc
        echo "✅ Custom prompt added to ~/.bashrc."
    else
        echo "ℹ️ Custom prompt already exists in ~/.bashrc."
    fi

    source ~/.bashrc || echo "ℹ️ Changes will apply on next login."
}

# Move utilities folder
move_utilities() {
    SOURCE_DIR="$(pwd)/utilities"
    DEST_DIR="$HOME/Documents"

    if [[ -d "$SOURCE_DIR" ]]; then
        mv "$SOURCE_DIR" "$DEST_DIR"
        if [[ $? -eq 0 ]]; then
            echo "✅ 'utilities' moved to $DEST_DIR."
        else
            echo "❌ Failed to move 'utilities'."
            return 1
        fi
    else
        echo "❌ 'utilities' directory not found!"
        return 1
    fi
}

# Run functions
echo "🚀 Starting setup process..."
install_xdg_utils
setup_shared_folder
set_background_image
set_bash_prompt
move_utilities

echo "✅ Setup process complete!"
exit 0
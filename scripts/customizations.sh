#!/bin/bash

# Purpose: Create a host share folder, set a custom background, and update the Bash prompt.

# Ensure script is run as root
if [[ "$(id -u)" -ne 0 ]]; then
    echo "❌ This script must be run as root (use sudo)."
    exit 1
fi

# Determine the non-root user running the script
if [[ -z "$SUDO_USER" ]]; then
    echo "❌ This script must be run with sudo."
    exit 1
fi

USER_HOME=$(eval echo ~$SUDO_USER)
DESKTOP_DIR="$USER_HOME/Desktop"
BASHRC="$USER_HOME/.bashrc"

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
    MNT_DIR="/mnt/"

    if [[ ! -d "$MNT_DIR" ]]; then
        echo "❌ $HGFS_DIR does not exist. Ensure Guest additions is installed and share folder is setup."
        return 1
    fi

    mkdir -p "$DESKTOP_DIR"
    chown "$SUDO_USER:$SUDO_USER" "$DESKTOP_DIR"

    echo "🔗 Creating shared folder shortcuts..."
    for folder in "$MNT_DIR"/*; do
        if [[ -d "$folder" ]]; then
            folder_name=$(basename "$folder")
            desktop_file="$DESKTOP_DIR/Host_Share_${folder_name}.desktop"

            sudo -u "$SUDO_USER" bash -c "cat <<EOL > '$desktop_file'
[Desktop Entry]
Name=Host Share - $folder_name
Comment=Shortcut for access to $folder_name on the host machine
Exec=xdg-open \"$folder\"
Icon=folder
Terminal=false
Type=Application
EOL"

            chmod +x "$desktop_file"
            chown "$SUDO_USER:$SUDO_USER" "$desktop_file"
            echo "✅ Shortcut created: $desktop_file"
        fi
    done
    echo "🎉 Host share shortcuts setup complete!"
}

# Set custom background
set_background_image() {
    REPO_DIR="$(git rev-parse --show-toplevel 2>/dev/null || echo "/home/$SUDO_USER/laurie")"
    BACKGROUND_IMAGE="$REPO_DIR/background/E61317.jpg"
    TARGET_PATH="/usr/share/backgrounds/E61317.jpg"

    if [[ -f "$BACKGROUND_IMAGE" ]]; then
        cp "$BACKGROUND_IMAGE" "$TARGET_PATH"
        echo "✅ Background image copied successfully."
    else
        echo "❌ Background image not found: $BACKGROUND_IMAGE."
        return 1
    fi

    sudo -u "$SUDO_USER" gsettings set org.cinnamon.desktop.background picture-uri "file://$TARGET_PATH"
    sudo -u "$SUDO_USER" gsettings set org.cinnamon.desktop.background picture-options "zoom"
    echo "🖼️ Background set successfully."
}

set_terminal_banner() {
    BASHRC="/home/$SUDO_USER/.bashrc"

    BANNER="
▬▬ι═════════════ﺤ
With great power comes great responsibility.
▬▬ι═════════════ﺤ
"

    # Check if the banner already exists
    if ! grep -q "With great power comes great responsibility" "$BASHRC"; then
        echo -e "\n# Custom Terminal Banner" >> "$BASHRC"
        echo "echo -e \"$BANNER\"" >> "$BASHRC"
        chown "$SUDO_USER:$SUDO_USER" "$BASHRC"
        echo "✅ Banner added to $BASHRC."
    else
        echo "ℹ️ Banner already exists in $BASHRC."
    fi
}

# Move utilities folder
move_utilities() {
    SOURCE_DIR="$(pwd)/utilities"
    DEST_DIR="$USER_HOME/Documents"

    if [[ -d "$SOURCE_DIR" ]]; then
        mv "$SOURCE_DIR" "$DEST_DIR"
        chown -R "$SUDO_USER:$SUDO_USER" "$DEST_DIR/utilities"
        echo "✅ 'utilities' moved to $DEST_DIR."
    else
        echo "❌ 'utilities' directory not found!"
        return 1
    fi
}

add_favorite_apps() {
    # Define apps to add
    NEW_APPS=("code.desktop" "gnome-terminal.desktop" "google-chrome.desktop" "brave-browser.desktop" "xed.desktop" "gnome-calculator.desktop") 

    # Read the current favorite apps
    CURRENT_FAVORITES=$(sudo -u "$SUDO_USER" dconf read /org/cinnamon/favorite-apps | tr -d "[]'")

    # Convert to an array
    IFS=', ' read -r -a FAVORITE_APPS <<< "$CURRENT_FAVORITES"

    # Add new apps if they are not already present
    for app in "${NEW_APPS[@]}"; do
        if [[ ! " ${FAVORITE_APPS[@]} " =~ " ${app} " ]]; then
            FAVORITE_APPS+=("$app")
        fi
    done

    # Convert back to a dconf-compatible string
    NEW_FAVORITES="['$(IFS=','; echo "${FAVORITE_APPS[*]}")']"

    # Apply the new favorites
    sudo -u "$SUDO_USER" dconf write /org/cinnamon/favorite-apps "$NEW_FAVORITES"

    echo "✅ Favorite applications updated: $NEW_FAVORITES"
}

# Run functions
echo "Starting setup process..."
install_xdg_utils
setup_shared_folder
set_background_image
set_terminal_banner
move_utilities
add_favorite_apps

echo "✅ Setup process complete!"
exit 0
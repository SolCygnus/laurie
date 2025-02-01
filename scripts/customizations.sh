#!/bin/bash

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root (use sudo)."
    exit 1
fi

# Determine the non-root user
REAL_USER=${SUDO_USER:-$(who am i | awk '{print $1}')}
if [[ -z "$REAL_USER" || "$REAL_USER" == "root" ]]; then
    echo "❌ Script must be run as sudo but for a non-root user."
    exit 1
fi

USER_HOME=$(eval echo ~$REAL_USER)
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

# Setup shared folders
setup_shared_folder() {
    MNT_DIR="/mnt/"
    
    if [[ ! -d "$MNT_DIR" || -z "$(ls -A "$MNT_DIR")" ]]; then
        echo "❌ No shared folders found in $MNT_DIR."
        return 1
    fi

    echo "🔗 Creating shared folder symbolic links..."
    for folder in "$MNT_DIR"/*; do
        if [[ -d "$folder" ]]; then
            folder_name=$(basename "$folder")
            symlink_target="$DESKTOP_DIR/${folder_name}"

            [[ -L "$symlink_target" ]] && rm "$symlink_target"
            ln -s "$folder" "$symlink_target"
            chown -h "$REAL_USER:$REAL_USER" "$symlink_target"
            echo "✅ Symlink created: $symlink_target -> $folder"

            usermod -aG vboxsf "$REAL_USER"
            echo "User added to vboxsf group"
        fi
    done

    echo "🎉 Host share symlinks setup complete!"
}

# Set custom background
set_background_image() {
    REPO_DIR="/home/$REAL_USER/laurie"
    if git rev-parse --show-toplevel &>/dev/null; then
        REPO_DIR=$(git rev-parse --show-toplevel)
    fi
    BACKGROUND_IMAGE="$REPO_DIR/background/E61317.jpg"
    TARGET_PATH="/usr/share/backgrounds/E61317.jpg"

    if [[ -f "$BACKGROUND_IMAGE" ]]; then
        cp "$BACKGROUND_IMAGE" "$TARGET_PATH"
        echo "✅ Background image copied successfully."
    else
        echo "❌ Background image not found: $BACKGROUND_IMAGE."
        return 1
    fi
    sudo chmod 644 $TARGET_PATH
    chown "$REAL_USER:$REAL_USER" "$TARGET_PATH"
    sudo -u "$REAL_USER" DISPLAY=:0 XDG_RUNTIME_DIR=/run/user/$(id -u $REAL_USER) \
    gsettings set org.cinnamon.desktop.background picture-uri "file://$TARGET_PATH"
    sudo -u "$REAL_USER" gsettings set org.cinnamon.desktop.background picture-options "zoom"
    cinnamon --replace &
    echo "🖼️ Background set successfully."
}

# Set terminal banner
set_terminal_banner() {
    BANNER="
▬▬ι═════════════ﺤ
With great power comes great responsibility.
▬▬ι═════════════ﺤ
"
    if ! grep -q "With great power comes great responsibility" "$BASHRC"; then
        echo -e "\n# Custom Terminal Banner" >> "$BASHRC"
        echo "echo -e \"$BANNER\"" >> "$BASHRC"
        chown "$REAL_USER:$REAL_USER" "$BASHRC"
        echo "✅ Banner added to $BASHRC."
    else
        echo "ℹ️ Banner already exists in $BASHRC."
    fi
}

#Move utilities to /usr/local/bin for global accessaility
move_utilities() {
    SOURCE_DIR="$(pwd)/utilities"
    DEST_DIR="/usr/local/bin"

    if [[ ! -d "$SOURCE_DIR" ]]; then
        echo "❌ 'utilities' directory not found!"
        return 1
    fi

    echo "Moving utilities to $DEST_DIR..."

    # Loop through all files in the utilities directory
    for file in "$SOURCE_DIR"/*; do
        if [[ -f "$file" ]]; then
            filename=$(basename "$file")
            target_path="$DEST_DIR/$filename"

            # Move the file
            sudo mv "$file" "$target_path"

            # Set correct ownership and permissions
            sudo chown root:root "$target_path"
            sudo chmod 755 "$target_path"

            echo "✅ Moved and set executable: $target_path"
        fi
    done

    echo "🎉 All utilities are now globally available!"
}

add_apps_to_desktop() {
    TARGET_USER=${REAL_USER:-$USER}
    USER_DESKTOP="/home/$TARGET_USER/Desktop"

    if [[ -z "$TARGET_USER" || "$TARGET_USER" == "root" ]]; then
        echo "❌ Cannot modify desktop for root. Run as a normal user with sudo."
        return 1
    fi

    # Ensure the Desktop directory exists
    mkdir -p "$USER_DESKTOP"

    # Define applications to add (These must exist in /usr/share/applications/)
    APPS=("code.desktop" "gnome-terminal.desktop" "google-chrome.desktop" "brave-browser.desktop" "xed.desktop" "gnome-calculator.desktop") 

    echo "📌 Adding applications to the Desktop..."

    for app in "${APPS[@]}"; do
        SRC_FILE="/usr/share/applications/$app"
        DEST_FILE="$USER_DESKTOP/$app"

        if [[ -f "$SRC_FILE" ]]; then
            # Copy the .desktop file to the Desktop
            cp "$SRC_FILE" "$DEST_FILE"

            # Ensure the file is owned by the user
            chown "$TARGET_USER:$TARGET_USER" "$DEST_FILE"

            # Make it executable so it appears as an application shortcut
            chmod +x "$DEST_FILE"

            echo "✅ Added $app to the Desktop."
        else
            echo "⚠️ $app not found in /usr/share/applications/"
        fi
    done

    echo "🎉 All requested applications have been added to the Desktop!"
}


# Run functions
echo "Starting setup process..."
install_xdg_utils
setup_shared_folder
set_background_image
set_terminal_banner
move_utilities
add_apps_to_desktop

echo "✅ Setup process complete!"
exit 0

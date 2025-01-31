#!/bin/bash

# Purpose: Create a host share folder, set a custom background, and update the Bash prompt.

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root (use sudo)."
    exit 1
fi

# Determine the non-root user running the script
REAL_USER=$(logname)

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

# Setup host shared folders with symbolic links
setup_shared_folder() {
    MNT_DIR="/mnt/"
    DESKTOP_DIR="/home/$REAL_USER/Desktop"

#    if [[ ! -d "$MNT_DIR" ]]; then
#        echo "❌ $MNT_DIR does not exist. Ensure Guest Additions is installed and shared folders are set up."
#        return 1
#    fi
#
#    mkdir -p "$DESKTOP_DIR"
#    chown "$REAL_USER:$REAL_USER" "$DESKTOP_DIR"

    echo "🔗 Creating shared folder symbolic links..."
    for folder in "$MNT_DIR"/*; do
        if [[ -d "$folder" ]]; then
            folder_name=$(basename "$folder")
            symlink_target="$DESKTOP_DIR/${folder_name}"

            # Remove existing symlink if it exists
            [[ -L "$symlink_target" ]] && rm "$symlink_target"

            # Create the symbolic link
            ln -s "$folder" "$symlink_target"
            chown -h "$REAL_USER:$REAL_USER" "$symlink_target"
            echo "✅ Symlink created: $symlink_target -> $folder"

            # Add user to vboxsf group
            usermod -aG vboxsf "$REAL_USER" #removed sudo. script running as root.
            echo "User added to vboxsf group"
        fi
    done

    echo "🎉 Host share symlinks setup complete!"
}

# Run the function
setup_shared_folder

# Set custom background
set_background_image() {
    REPO_DIR="$(git rev-parse --show-toplevel 2>/dev/null || echo "/home/$REAL_USER/laurie")"
    BACKGROUND_IMAGE="$REPO_DIR/background/E61317.jpg"
    TARGET_PATH="/usr/share/backgrounds/E61317.jpg"

    if [[ -f "$BACKGROUND_IMAGE" ]]; then
        cp "$BACKGROUND_IMAGE" "$TARGET_PATH"
        echo "✅ Background image copied successfully."
    else
        echo "❌ Background image not found: $BACKGROUND_IMAGE."
        return 1
    fi

    sudo -u "$REAL_USER" DISPLAY=:0 XDG_RUNTIME_DIR=/run/user/$(id -u $REAL_USER) \
    gsettings set org.cinnamon.desktop.background picture-uri "file://$TARGET_PATH"
    sudo -u "$REAL_USER" gsettings set org.cinnamon.desktop.background picture-options "zoom"
    cinnamon --replace &
    echo "🖼️ Background set successfully."
}

set_terminal_banner() {
    BASHRC="/home/$REAL_USER/.bashrc"

    BANNER="
▬▬ι═════════════ﺤ
With great power comes great responsibility.
▬▬ι═════════════ﺤ
"

    # Check if the banner already exists
    if ! grep -q "With great power comes great responsibility" "$BASHRC"; then
        echo -e "\n# Custom Terminal Banner" >> "$BASHRC"
        echo "echo -e \"$BANNER\"" >> "$BASHRC"
        chown "$REAL_USER:$REAL_USER" "$BASHRC"
        echo "✅ Banner added to $BASHRC."
    else
        echo "ℹ️ Banner already exists in $BASHRC."
    fi
}

# Move utilities folder to /usr/local/bin/
#currently moves whole folder. make sure there are no issues with calling the scripts from /local/bin sub folders.

move_utilities() {
    SOURCE_DIR="$(pwd)/utilities"
    DEST_DIR="/usr/local/bin"

    if [[ -d "$SOURCE_DIR" ]]; then
        # Move the directory to /usr/local/bin/
        sudo mv "$SOURCE_DIR" "$DEST_DIR"

        # Set correct permissions (owned by root but executable by everyone)
        sudo chown -R root:root "$DEST_DIR/utilities"
        sudo chmod -R 755 "$DEST_DIR/utilities"

        echo "✅ 'utilities' moved to $DEST_DIR."
    else
        echo "❌ 'utilities' directory not found!"
        return 1
    fi
}

add_favorite_apps() {
    # Ensure the script is run as root. already performing function at start of script.
#    if [[ $EUID -ne 0 ]]; then
#        echo "❌ This script must be run as root (use sudo)."
#        exit 1
    fi

    # Determine the correct user to apply changes
    TARGET_USER=${REAL_USER:-$USER}
    if [[ -z "$TARGET_USER" || "$TARGET_USER" == "root" ]]; then
        echo "❌ Cannot modify favorite apps for root. Run as a normal user with sudo."
        return 1
    fi

    # Define apps to add
    NEW_APPS=("code.desktop" "gnome-terminal.desktop" "google-chrome.desktop" "brave-browser.desktop" "xed.desktop" "gnome-calculator.desktop") 

    # Read the current favorite apps
    CURRENT_FAVORITES=$(sudo -u "$TARGET_USER" dconf read /org/cinnamon/favorite-apps)
    [[ "$CURRENT_FAVORITES" == "null" || -z "$CURRENT_FAVORITES" ]] && CURRENT_FAVORITES="[]"

    # Clean up the list formatting
    CURRENT_FAVORITES=$(echo "$CURRENT_FAVORITES" | sed -E "s/^\[//; s/\]$//; s/'//g")

    # Convert to an array
    IFS=',' read -r -a FAVORITE_APPS <<< "$CURRENT_FAVORITES"

    # Add new apps if not already present
    for app in "${NEW_APPS[@]}"; do
        if [[ ! " ${FAVORITE_APPS[*]} " =~ " $app " ]]; then
            FAVORITE_APPS+=("$app")
        fi
    done

    # Convert back to a dconf-compatible string
    NEW_FAVORITES="['$(IFS=','; echo "${FAVORITE_APPS[*]}" | sed "s/,/, /g")']"

    # Apply the new favorites
    sudo -u "$TARGET_USER" dconf write /org/cinnamon/favorite-apps "$NEW_FAVORITES"

    echo "✅ Favorite applications updated for $TARGET_USER: $NEW_FAVORITES"

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
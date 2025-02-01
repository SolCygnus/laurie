#!/bin/bash
#v2

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
    # Determine the real user, fallback to $SUDO_USER if running with sudo
    TARGET_USER=${REAL_USER:-${SUDO_USER:-$USER}}

    # Get the user's Desktop directory (handles non-standard locations)
    USER_DESKTOP=$(sudo -u "$TARGET_USER" xdg-user-dir DESKTOP 2>/dev/null)
    USER_DESKTOP=${USER_DESKTOP:-"/home/$TARGET_USER/Desktop"}

    # Prevent running as root
    if [[ "$TARGET_USER" == "root" || -z "$TARGET_USER" ]]; then
        echo "❌ Cannot modify the desktop for root. Run as a normal user with sudo."
        return 1
    fi

    # Ensure the Desktop directory exists
    sudo -u "$TARGET_USER" mkdir -p "$USER_DESKTOP"

    # Define applications to add (must exist in /usr/share/applications/)
    APPS=(
        "brave-browser.desktop"
        "code.desktop"
        "firefox.desktop"
        "gufw.desktop"
        "libreoffice-calc.desktop"
        "lynis.desktop"
        "org.gnome.Calculator.desktop"
        "org.gnome.Calendar.desktop"
        "org.gnome.Terminal.desktop"
        "org.keepassxc.KeePassXC.desktop"
        "org.x.editor.desktop"
        "torbrowser.desktop"
        "vlc.desktop"
        "google-chrome.desktop"
        "torbrowser.desktop"
        "obsidian.desktop"
    )

    echo "📌 Adding applications to the Desktop for user: $TARGET_USER..."

    for app in "${APPS[@]}"; do
        SRC_FILE="/usr/share/applications/$app"
        DEST_FILE="$USER_DESKTOP/$app"

        if [[ -f "$SRC_FILE" ]]; then
            # Use install to copy and set ownership/permissions
            install -m 755 -o "$TARGET_USER" -g "$TARGET_USER" "$SRC_FILE" "$DEST_FILE"

            echo "✅ Added $app to $USER_DESKTOP."
        else
            echo "⚠️ Warning: $app not found in /usr/share/applications/"
        fi
    done

    echo "🎉 All requested applications have been added to $USER_DESKTOP!"
}

setup_expiration_check() {
    echo "Setting up system expiration check..."

    # Define paths
    INSTALL_DATE_FILE="/etc/install_date"
    EXPIRATION_SCRIPT="/usr/local/bin/check_expiration.sh"
    SYSTEMD_SERVICE="/etc/systemd/system/expiration-check.service"

    # Define repo locations (Update these paths based on your repository structure)
    REPO_EXPIRATION_SCRIPT="./check_expiration.sh"
    REPO_SYSTEMD_SERVICE="./expiration-check.service"

    # Store install date
    echo "Storing installation date..."
    date +%s > "$INSTALL_DATE_FILE"

    # Move the expiration check script
    if [[ -f "$REPO_EXPIRATION_SCRIPT" ]]; then
        echo "Moving expiration script to /usr/local/bin/..."
        mv "$REPO_EXPIRATION_SCRIPT" "$EXPIRATION_SCRIPT"
        chmod +x "$EXPIRATION_SCRIPT"
    else
        echo "Error: Expiration script not found in repo."
        return 1
    fi

    # Move the systemd service file
    if [[ -f "$REPO_SYSTEMD_SERVICE" ]]; then
        echo "Moving systemd service file to /etc/systemd/system/..."
        mv "$REPO_SYSTEMD_SERVICE" "$SYSTEMD_SERVICE"
    else
        echo "Error: Systemd service file not found in repo."
        return 1
    fi

    # Reload systemd, enable and start service
    echo "Enabling and starting the expiration-check service..."
    systemctl daemon-reload
    systemctl enable expiration-check.service
    systemctl start expiration-check.service

    echo "System expiration setup complete."
}

# Run functions
echo "Starting setup process..."
install_xdg_utils
setup_shared_folder
set_background_image
set_terminal_banner
move_utilities
add_apps_to_desktop
setup_expiration_check

echo "✅ Setup process complete!"
exit 0

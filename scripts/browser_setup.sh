#!/bin/bash

# Script to install and set up web browsers (Google Chrome and Brave) on a Linux system.
# Author: SillyPenguin
# Date: 25 Jan 25

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root."
    exit 1
fi

# Function to check if a package is installed
is_installed() {
    dpkg -l | grep -q "^ii  $1 "
}

echo "🔄 Checking and installing prerequisites (apt-transport-https, curl, and gpg)..."

PACKAGES=("apt-transport-https" "curl" "gpg")

for pkg in "${PACKAGES[@]}"; do
    if is_installed "$pkg"; then
        echo "✅ $pkg is already installed. Skipping."
    else
        echo "📦 Installing $pkg..."
        if ! sudo apt-get install -y "$pkg"; then
            echo "❌ Failed to install $pkg. Exiting."
            exit 1
        fi
    fi
done

echo "✅ All prerequisites installed successfully."

# Install Google Chrome
install_google_chrome() {
    echo "🌐 Installing Google Chrome..."

    # Download the Chrome package
    if ! curl -sSL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o google-chrome.deb; then
        echo "❌ Failed to download Google Chrome package. Skipping installation."
        return 1
    fi

    # Install the package
    if ! sudo apt-get install -y ./google-chrome.deb; then
        echo "❌ Failed to install Google Chrome. Skipping installation."
        rm -f google-chrome.deb
        return 1
    fi

    # Clean up
    rm -f google-chrome.deb
    echo "✅ Google Chrome installed successfully."
}

# Install Brave Browser Function
install_brave_browser() {
    echo "Installing Brave Browser..."

    # Download and add the Brave keyring
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
        https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    if [ $? -ne 0 ]; then
        echo "Failed to download Brave keyring. Skipping Brave installation."
        return 1
    fi

    # Add Brave repository
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
        | sudo tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null
    if [ $? -ne 0 ]; then
        echo "Failed to add Brave repository. Skipping Brave installation."
        return 1
    fi

    # Update package lists
    sudo apt update
    if [ $? -ne 0 ]; then
        echo "Failed to update package list. Skipping Brave installation."
        return 1
    fi

    # Install Brave Browser
    sudo apt install -y brave-browser
    if [ $? -ne 0 ]; then
        echo "Failed to install Brave Browser."
        return 1
    fi

    echo "Brave Browser installed successfully."
}

# Function to ensure Firefox is launched at least once to create the profile directory
initialize_firefox_profile() {
    FIREFOX_DIR="$HOME/.mozilla/firefox"

    # Check if Firefox profile directory exists
    if [[ -d "$FIREFOX_DIR" ]]; then
        echo "✅ Firefox profile directory already exists."
        return 0
    fi

    echo "🔄 Launching Firefox to initialize profile..."

    # Launch Firefox in the background and store its PID
    firefox &>/dev/null &
    FIREFOX_PID=$!

    # Give it time to create the profile directory
    sleep 5  # Adjust this delay if necessary

    # Gracefully terminate Firefox
    kill "$FIREFOX_PID"
    sleep 2  # Allow process to exit properly

    # Check if profile directory was created
    if [[ -d "$FIREFOX_DIR" ]]; then
        echo "✅ Firefox profile directory successfully created."
        return 0
    else
        echo "❌ Failed to initialize Firefox profile directory."
        return 1
    fi
}

# Function to replace the default Firefox profile with a custom one
replace_firefox_profile() {
    FIREFOX_DIR="$HOME/.mozilla/firefox"
    REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"  # Assumes script is inside the repo
    CUSTOM_PROFILE_SRC="$REPO_DIR/misc_files/profile"  # Custom profile location inside the repo
    BACKUP_DIR="$HOME/firefox-profile-backup"

    # Ensure Firefox profile directory exists
    if [[ ! -d "$FIREFOX_DIR" ]]; then
        echo "❌ Firefox profile directory not found. Ensure Firefox is installed and run it once."
        return 1
    fi

    # Identify the default profile folder
    DEFAULT_PROFILE=$(grep -oP '(?<=Path=).+' "$FIREFOX_DIR/profiles.ini" | head -n 1)
    DEFAULT_PROFILE_DIR="$FIREFOX_DIR/$DEFAULT_PROFILE"

    if [[ ! -d "$DEFAULT_PROFILE_DIR" ]]; then
        echo "❌ Default profile directory not found."
        return 1
    fi

    # Backup the existing default profile
    mkdir -p "$BACKUP_DIR"
    cp -r "$DEFAULT_PROFILE_DIR" "$BACKUP_DIR"
    echo "✅ Backup of existing profile saved to $BACKUP_DIR"

    # Replace the default profile with the custom one from the repo
    rm -rf "$DEFAULT_PROFILE_DIR"
    cp -r "$CUSTOM_PROFILE_SRC" "$DEFAULT_PROFILE_DIR"
    echo "✅ Custom profile copied from $CUSTOM_PROFILE_SRC to $DEFAULT_PROFILE_DIR"

    # Ensure correct ownership
    chown -R "$USER:$USER" "$DEFAULT_PROFILE_DIR"

    # Set profile as default in profiles.ini
    PROFILE_NAME=$(basename "$CUSTOM_PROFILE_SRC")
    sed -i "s|Path=.*|Path=$PROFILE_NAME|g" "$FIREFOX_DIR/profiles.ini"

    echo "🎉 Firefox profile replaced successfully! Restart Firefox to apply changes."
}

#Main 
main() {
    echo "Starting installation process..."

    install_brave_browser
    install_google_chrome
    initialize_firefox_profile
    replace_firefox_profile

    echo "Continuing with the rest of the script..."
}

main
exit 0
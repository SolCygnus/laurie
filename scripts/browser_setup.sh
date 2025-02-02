#!/bin/bash

# Script to install and set up web browsers (Google Chrome and Brave) on a Linux system.

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root."
    exit 1
fi

# Function to check if a package is installed
is_installed() {
    dpkg -s "$1" &>/dev/null
}

# Update package lists before installing anything
echo "🔄 Updating package list..."
apt update

# Install prerequisites
echo "🔄 Checking and installing prerequisites (apt-transport-https, curl, and gpg)..."
PACKAGES=("apt-transport-https" "curl" "gpg")
for pkg in "${PACKAGES[@]}"; do
    if is_installed "$pkg"; then
        echo "✅ $pkg is already installed. Skipping."
    else
        echo "📦 Installing $pkg..."
        if ! apt-get install -y "$pkg"; then
            echo "❌ Failed to install $pkg. Exiting."
            exit 1
        fi
    fi
done

echo "✅ All prerequisites installed successfully."

# Install Google Chrome
install_google_chrome() {
    echo "🌐 Installing Google Chrome..."
    if ! curl -sSL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o google-chrome.deb; then
        echo "❌ Failed to download Google Chrome package. Skipping installation."
        return 1
    fi
    if ! apt-get install -y ./google-chrome.deb; then
        echo "❌ Failed to install Google Chrome. Skipping installation."
        rm -f google-chrome.deb
        return 1
    fi
    rm -f google-chrome.deb
    echo "✅ Google Chrome installed successfully."
}

# Install Brave Browser
install_brave_browser() {
    echo "Installing Brave Browser..."
    if ! curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
        https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg; then
        echo "Failed to download Brave keyring. Skipping Brave installation."
        return 1
    fi
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
        | tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null
    if ! apt update; then
        echo "Failed to update package list. Removing broken repository."
        rm -f /etc/apt/sources.list.d/brave-browser-release.list
        return 1
    fi
    if ! apt install -y brave-browser; then
        echo "Failed to install Brave Browser."
        return 1
    fi
    echo "Brave Browser installed successfully."
}

# Main function
main() {
    echo "Starting installation process..."
    install_brave_browser
    install_google_chrome
    echo "Continuing with the rest of the script..."
}

main
exit 0


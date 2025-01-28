#!/bin/bash

# Script to install and set up web browsers (Google Chrome and Brave) on a Linux system.
# Author: SillyPenguin
# Date: 25 Jan 25

# Function to log messages
echo_log() {
    echo "$1"
}

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root." >&2
    exit 1
fi

# Update package lists
echo_log "Updating package lists..."
if ! apt-get update >/dev/null 2>&1; then
    echo "Failed to update package lists. Exiting." >&2
    exit 1
fi

# Install prerequisites
echo_log "Installing prerequisites (apt-transport-https, curl, and gpg)..."
if ! apt-get install -y apt-transport-https curl gpg >/dev/null 2>&1; then
    echo "Failed to install prerequisites. Exiting." >&2
    exit 1
fi

# Install Google Chrome
echo_log "Installing Google Chrome..."
if ! curl -sSL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o google-chrome.deb; then
    echo "Failed to download Google Chrome package. Exiting." >&2
    exit 1
fi
if ! apt-get install -y ./google-chrome.deb >/dev/null 2>&1; then
    echo "Failed to install Google Chrome. Exiting." >&2
    rm -f google-chrome.deb
    exit 1
fi
rm -f google-chrome.deb

echo_log "Google Chrome installation completed successfully."

# Install Brave Browser
echo_log "Installing Brave Browser..."
if ! curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | gpg --dearmor -o /usr/share/keyrings/brave-browser-archive-keyring.gpg; then
    echo "Failed to download Brave Browser GPG key. Exiting." >&2
    exit 1
fi
if ! echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" > /etc/apt/sources.list.d/brave-browser-release.list; then
    echo "Failed to add Brave Browser repository. Exiting." >&2
    exit 1
fi
if ! apt-get update >/dev/null 2>&1; then
    echo "Failed to update package lists after adding Brave Browser repository. Exiting." >&2
    exit 1
fi
if ! apt-get install -y brave-browser >/dev/null 2>&1; then
    echo "Failed to install Brave Browser. Exiting." >&2
    exit 1
fi

echo_log "Brave Browser installation completed successfully."

echo_log "Web browser installations completed successfully."
exit 0

#!/bin/bash

# Script to install and set up web browsers (Google Chrome and Brave) on a Linux system.
# Author: SillyPenguin
# Date: 25 Jan 25

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root."
    exit 1
fi

# Update package lists
echo "🔄 Updating package lists..."
if ! apt-get update; then
    echo "❌ Failed to update package lists. Exiting."
    exit 1
fi

# Install prerequisites
echo "🔄 Installing prerequisites (apt-transport-https, curl, and gpg)..."
if ! apt-get install -y apt-transport-https curl gpg; then
    echo "❌ Failed to install prerequisites. Exiting."
    exit 1
fi

# Install Google Chrome
echo "🌐 Installing Google Chrome..."
if ! curl -sSL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o google-chrome.deb; then
    echo "❌ Failed to download Google Chrome package. Exiting."
    exit 1
fi
if ! apt-get install -y ./google-chrome.deb; then
    echo "❌ Failed to install Google Chrome. Exiting."
    rm -f google-chrome.deb
    exit 1
fi
rm -f google-chrome.deb
echo "✅ Google Chrome installed successfully."

# Install Brave Browser
echo "Installing Brave Browser..."
mkdir -p /usr/share/keyrings
if ! curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | gpg --dearmor -o /usr/share/keyrings/brave-browser-archive-keyring.gpg; then
    echo "❌ Failed to download Brave Browser GPG key. Exiting."
    exit 1
fi
if ! echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" > /etc/apt/sources.list.d/brave-browser-release.list; then
    echo "❌ Failed to add Brave Browser repository. Exiting."
    exit 1
fi
if ! apt-get update; then
    echo "❌ Failed to update package lists after adding Brave Browser repository. Exiting."
    exit 1
fi
if ! apt-get install -y brave-browser; then
    echo "❌ Failed to install Brave Browser. Exiting."
    exit 1
fi
echo "✅ Brave Browser installed successfully."

echo "🎉 Web browser installations completed successfully."
exit 0
#!/bin/bash

# Purpose: to setup the kali repo and then allow for installing specific applications from kali repo for OSR.

# List of essential packages for Linux Mint
PACKAGES=(
    "recon-ng"
    "sherlock"
    "metagoofil"
    "spiderfoot"
    "spiderfoot-cli"
    "Amass"
    "holehe"
    "shodan"
    "tor"
    "torbrowser-launcher"
)

# Backup sources.list
echo "Backing up current sources list..."
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup

# Add Kali Rolling Repository
echo "Adding Kali Rolling repository..."
echo 'deb https://http.kali.org/kali kali-rolling main non-free contrib' | sudo tee /etc/apt/sources.list.d/kali.list

# Install required package for key management
echo "Installing gnupg..."
sudo apt install -y gnupg

# Download and add Kali's GPG key
echo "Downloading Kali archive key..."
wget -q 'https://archive.kali.org/archive-key.asc'

echo "Adding Kali GPG key..."
sudo apt-key add archive-key.asc

# Set up package priority preferences
echo "Setting package priorities for Kali repository..."
echo 'Package: *' | sudo tee /etc/apt/preferences.d/kali.pref
echo 'Pin: release a=kali-rolling' | sudo tee -a /etc/apt/preferences.d/kali.pref
echo 'Pin-Priority: 50' | sudo tee -a /etc/apt/preferences.d/kali.pref

# Update package lists
echo "Updating package lists..."
sudo apt update

echo "Kali repository setup completed successfully."

# Function to install a package via APT
install_package() {
    local package="$1"
    if dpkg -s "$package" &>/dev/null; then
        echo "✅ $package is already installed. Skipping..."
    else
        echo "📦 Installing $package..."
        sudo apt install -t kali-rolling "$package" -y
        if [[ $? -eq 0 ]]; then
            echo "✅ Successfully installed: $package"
        else
            echo "❌ Failed to install: $package"
        fi
    fi
}

# Function to install all essential packages
install_packages() {
    echo "🔄 Updating package lists..."
    sudo apt update

    echo "📦 Installing essential packages..."
    for pkg in "${PACKAGES[@]}"; do
        install_package "$pkg"
    done
}

# Install all essential kali packages
install_packages
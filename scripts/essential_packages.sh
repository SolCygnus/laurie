#!/bin/bash

# List of essential packages for Linux Mint
PACKAGES=(
    "yt-dlp"
    "ffmpeg"
    "python3-pip"
    "wget"
    "gpg"
    "apt-transport-https"
    "git"
    "protonvpn"
    "steghide"
    "exiftool"
    "curl"
    "vlc"
)

# Function to install a package via APT
install_package() {
    local package="$1"
    if dpkg -s "$package" &>/dev/null; then
        echo "✅ $package is already installed. Skipping..."
    else
        echo "📦 Installing $package..."
        sudo apt install -y "$package"
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

# Function to set up ProtonVPN repository and install GUI
setup_protonvpn_gui() {
    echo "🌐 Setting up ProtonVPN repository for GUI..."
    wget -q -O - https://repo.protonvpn.com/debian/public_key.asc | sudo gpg --dearmor -o /usr/share/keyrings/protonvpn.asc
    echo "deb [signed-by=/usr/share/keyrings/protonvpn.asc] https://repo.protonvpn.com/debian stable main" | sudo tee /etc/apt/sources.list.d/protonvpn.list
    sudo apt update
    install_package "protonvpn"
    install_package "protonvpn-gui"
}

# Function to install Shodan CLI
setup_shodan_cli() {
    echo "📡 Installing Shodan CLI..."
    sudo pip3 install -U --user shodan
    if [[ $? -ne 0 ]]; then
        echo "❌ Failed to install Shodan CLI."
        return 1
    fi

    # Verify installation
    echo "🔍 Verifying Shodan installation..."
    if python3 -m shodan --help &>/dev/null; then
        echo "✅ Shodan installed and verified!"
    else
        echo "❌ Shodan installation verification failed."
        return 1
    fi
}

# Function to install Anaconda
install_anaconda() {
    if command -v conda &>/dev/null; then
        echo "✅ Anaconda is already installed. Skipping..."
        return 0
    fi

    echo "🟢 Downloading and installing Anaconda..."
    wget -O ~/anaconda.sh https://repo.anaconda.com/archive/Anaconda3-latest-Linux-x86_64.sh
    bash ~/anaconda.sh -b -p "$HOME/anaconda3"
    rm ~/anaconda.sh
    echo "🔧 Adding Anaconda to PATH..."
    echo 'export PATH="$HOME/anaconda3/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
    echo "✅ Anaconda installed successfully!"
}

# Function to install Spyder via Conda
install_spyder() {
    if command -v spyder &>/dev/null; then
        echo "✅ Spyder is already installed. Skipping..."
        return 0
    fi

    if command -v conda &>/dev/null; then
        echo "🖥️ Installing Spyder via Anaconda..."
        conda install -y -c conda-forge spyder
        echo "✅ Spyder installed successfully!"
    else
        echo "⚠️ Conda is not installed. Skipping Spyder installation."
    fi
}

# Main script execution
echo "Starting essential package installation for Linux Mint..."

# Ensure script is running on a Debian-based system
if ! command -v apt &>/dev/null; then
    echo "❌ This script is intended for Debian-based systems (e.g., Linux Mint). Exiting."
    exit 1
fi

# Install all essential packages
install_packages

# Setup ProtonVPN GUI (Commented out for now, will return once isssues fixed)
# setup_protonvpn_gui

# Install Shodan CLI
setup_shodan_cli

# Install Anaconda
install_anaconda

# Install Spyder
install_spyder

echo "🎉 All essential packages, Anaconda, and Spyder have been installed!"

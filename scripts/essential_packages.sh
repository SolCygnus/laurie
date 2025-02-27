#!/bin/bash
#v3

# List of essential packages for Linux Mint
PACKAGES=(
    "yt-dlp"
    "ffmpeg"
    "python3-pip"
    "wget"
    "gpg"
    "apt-transport-https"
    "git"
    "steghide"
    "exiftool"
    "curl"
    "vlc"
    "keepassxc"
    "python3-venv"
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

# Install Anaconda
install_anaconda

# Install Spyder
install_spyder

echo "🎉 All essential packages have been installed!"
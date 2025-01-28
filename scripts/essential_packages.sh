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
)

# Function to set up ProtonVPN repository and install ProtonVPN GUI
setup_protonvpn_gui() {
    echo "Setting up ProtonVPN repository for GUI..."
    wget -q -O - https://repo.protonvpn.com/debian/public_key.asc | sudo gpg --dearmor -o /usr/share/keyrings/protonvpn.asc
    echo "deb [signed-by=/usr/share/keyrings/protonvpn.asc] https://repo.protonvpn.com/debian stable main" | sudo tee /etc/apt/sources.list.d/protonvpn.list
    sudo apt update
    echo "Installing ProtonVPN GUI..."
    sudo apt install -y protonvpn protonvpn-gui
}

# Function to Install Shodan Comand Line interface
setup_shodan_cli() {
    echo "Downloading and Installing Shodan CLI"
    sudo pip3 install -U shodan
    if [ $? -ne 0 ]; then
        echo "[ERROR] Failed to install Shodan. Exiting."
        exit 1
    fi

    # Verify installation
    echo "[INFO] Verifying Shodan installation..."
    if python3 -m shodan --help &>/dev/null; then
        echo "[SUCCESS] Shodan installed and verified successfully!"
    else
        echo "[ERROR] Shodan installation verification failed."
        exit 1
    fi
}

# Function to install Anaconda
install_anaconda() {
    echo "Downloading and installing Anaconda..."
    wget -O ~/anaconda.sh https://repo.anaconda.com/archive/Anaconda3-latest-Linux-x86_64.sh
    bash ~/anaconda.sh -b -p $HOME/anaconda3
    rm ~/anaconda.sh
    echo "Adding Anaconda to PATH..."
    echo 'export PATH="$HOME/anaconda3/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
    echo "Anaconda installed successfully!"
}

# Function to install Spyder via Conda
install_spyder() {
    echo "Installing Spyder through Anaconda..."
    if command -v conda > /dev/null; then
        conda install -y -c conda-forge spyder
        echo "Spyder installed successfully!"
    else
        echo "Conda is not installed. Skipping Spyder installation."
    fi
}

# Function to install essential packages using APT
install_packages() {
    echo "Updating package lists..."
    sudo apt update

    echo "Installing essential packages..."
    sudo apt install -y "${PACKAGES[@]}"
}

# Main script execution
echo "Starting package installation for Linux Mint..."

# Check if running on a Debian-based system
if ! command -v apt > /dev/null; then
    echo "This script is intended for Debian-based systems (like Linux Mint)."
    exit 1
fi

# Set up ProtonVPN GUI
setup_protonvpn_gui

# Install packages via APT
install_packages

# Install Anaconda
install_anaconda

# Install Spyder
install_spyder

echo "All essential packages, including ProtonVPN GUI, Anaconda, and Spyder, have been installed successfully!"

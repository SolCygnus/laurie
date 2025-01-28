#!/bin/bash

# Script to install and set up Visual Studio Code on a Linux system with extensions for python and hex editing.
# Author: SillyPenguin
# Date: 25 January 2025

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

# Import Microsoft GPG key
echo_log "Importing Microsoft GPG key..."
if ! curl -s https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/packages.microsoft.gpg; then
    echo "Failed to import Microsoft GPG key. Exiting." >&2
    exit 1
fi

# Add Microsoft repository
echo_log "Adding Microsoft repository..."
if ! echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list; then
    echo "Failed to add Microsoft repository. Exiting." >&2
    exit 1
fi

# Update package lists after adding the repository
echo_log "Updating package lists after adding Microsoft repository..."
if ! apt-get update >/dev/null 2>&1; then
    echo "Failed to update package lists after adding repository. Exiting." >&2
    exit 1
fi

# Install Visual Studio Code
echo_log "Installing Visual Studio Code..."
if ! apt-get install -y code >/dev/null 2>&1; then
    echo "Failed to install Visual Studio Code. Exiting." >&2
    exit 1
fi

# Install VSCode extensions
echo_log "Installing VSCode extensions: Python and Python Debugger..."
if ! code --install-extension ms-python.python >/dev/null 2>&1; then
    echo "Failed to install Python extension. Exiting." >&2
    exit 1
fi

if ! code --install-extension ms-python.debugger >/dev/null 2>&1; then
    echo "Failed to install Python Debugger extension. Exiting." >&2
    exit 1
fi


if ! code --install-extension tao-cumplido.hex-viewer >/dev/null 2>&1; then
    echo "Failed to install Python Debugger extension. Exiting." >&2
    exit 1
fi

if ! code --install-extension ms-vscode.hexeditor >/dev/null 2>&1; then
    echo "Failed to install Python Debugger extension. Exiting." >&2
    exit 1
fi


code --install-extension tao-cumplido.hex-viewer

echo_log "VSCode extensions installed successfully."

echo_log "Visual Studio Code installation completed successfully."
exit 0

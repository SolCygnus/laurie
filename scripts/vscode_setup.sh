#!/bin/bash

# Script to install and set up Visual Studio Code on a Linux system with extensions for Python and Hex Editing.
# Author: SillyPenguin
# Date: 25 January 2025

# Update package lists
echo "🔄 Updating package lists..."
if ! apt-get update; then
    echo "❌ Failed to update package lists. Exiting."
    exit 1
fi

# Install prerequisites
echo "🔧 Installing prerequisites (apt-transport-https, curl, and gpg)..."
if ! apt-get install -y apt-transport-https curl gpg; then
    echo "❌ Failed to install prerequisites. Exiting."
    exit 1
fi

# Import Microsoft GPG key
echo "🔑 Importing Microsoft GPG key..."
if ! curl -s https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/packages.microsoft.gpg; then
    echo "❌ Failed to import Microsoft GPG key. Exiting."
    exit 1
fi

# Add Microsoft repository
echo "➕ Adding Microsoft repository..."
if ! echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list; then
    echo "❌ Failed to add Microsoft repository. Exiting."
    exit 1
fi

# Update package lists after adding the repository
echo "🔄 Updating package lists after adding Microsoft repository..."
if ! apt-get update; then
    echo "❌ Failed to update package lists after adding repository. Exiting."
    exit 1
fi

# Install Visual Studio Code
echo "💻 Installing Visual Studio Code..."
if ! apt-get install -y code; then
    echo "❌ Failed to install Visual Studio Code. Exiting."
    exit 1
fi

# Verify VSCode Installation
if ! command -v code &>/dev/null; then
    echo "❌ VSCode is not installed properly. Exiting."
    exit 1
fi

# Install VSCode extensions
echo "🔌 Installing VSCode extensions: Python, Debugger, and Hex Editor..."

EXTENSIONS=(
    "ms-python.python"
    "ms-python.debugger"
    "tao-cumplido.hex-viewer"
    "ms-vscode.hexeditor"
)

for extension in "${EXTENSIONS[@]}"; do
    echo "Installing $extension..."
    if ! code --install-extension "$extension"; then
        echo "❌ Failed to install $extension."
        exit 1
    fi
done

echo "✅ VSCode extensions installed successfully."
echo "🎉 Visual Studio Code installation completed successfully."
exit 0
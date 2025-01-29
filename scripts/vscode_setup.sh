#!/bin/bash

# Script to install and set up Visual Studio Code on a Linux system with extensions for Python and Hex Editing.
# Author: SillyPenguin
# Date: 25 January 2025

# Function to update package lists
update_system() {
    echo "🔄 Updating package lists..."
    if ! apt-get update; then
        echo "❌ Failed to update package lists."
    fi
}

# Function to install prerequisites
install_prerequisites() {
    echo "🔧 Installing prerequisites (apt-transport-https, curl, and gpg)..."
    if ! apt-get install -y apt-transport-https curl gpg; then
        echo "❌ Failed to install prerequisites."
    fi
}

# Function to import Microsoft GPG key
import_microsoft_gpg_key() {
    echo "🔑 Importing Microsoft GPG key..."
    if ! curl -s https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/packages.microsoft.gpg; then
        echo "❌ Failed to import Microsoft GPG key."
    fi
}

# Function to add Microsoft repository
add_microsoft_repository() {
    echo "➕ Adding Microsoft repository..."
    if ! echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list; then
        echo "❌ Failed to add Microsoft repository."
    fi
}

# Function to install Visual Studio Code
install_vscode() {
    echo "💻 Installing Visual Studio Code..."
    if ! apt-get install -y code; then
        echo "❌ Failed to install Visual Studio Code."
    fi

    # Verify VSCode Installation
    if ! command -v code &>/dev/null; then
        echo "❌ VSCode is not installed properly."
    else
        echo "✅ VSCode installed successfully."
    fi
}

# Function to install VSCode extensions
install_vscode_extensions() {
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
        else
            echo "✅ Successfully installed: $extension"
        fi
    done
}

# Main execution
echo "Starting Visual Studio Code installation process..."
update_system
install_prerequisites
import_microsoft_gpg_key
add_microsoft_repository
update_system  # Update again after adding the repository
install_vscode
install_vscode_extensions

echo "🎉 Visual Studio Code installation process completed!"
exit 0
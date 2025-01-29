#!/bin/bash

# Script to install and set up Visual Studio Code with extensions
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
    echo "🔧 Installing prerequisites..."
    if ! apt-get install -y apt-transport-https curl gpg; then
        echo "❌ Failed to install prerequisites."
    fi
}

# Function to import Microsoft GPG key
import_microsoft_gpg_key() {
    echo "🔑 Importing Microsoft GPG key..."
    if ! curl -sSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft.gpg > /dev/null; then
        echo "❌ Failed to import Microsoft GPG key."
    fi
}

# Function to add Microsoft repository
add_microsoft_repository() {
    echo "➕ Adding Microsoft repository..."
    if ! echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null; then
        echo "❌ Failed to add Microsoft repository."
    fi
}

# Function to install VS Code
install_vscode() {
    echo "💻 Installing Visual Studio Code..."
    if ! apt-get install -y code; then
        echo "❌ Failed to install Visual Studio Code."
        exit 1
    fi

    # Verify installation
    if ! command -v code &>/dev/null; then
        echo "❌ VS Code installation failed."
        exit 1
    fi
    echo "✅ VS Code installed successfully."
}

# Function to install VS Code extensions
install_vscode_extensions() {
    echo "🔌 Installing VSCode extensions..."

    EXTENSIONS=(
        "ms-python.python"
        "ms-python.debugger"
        "tao-cumplido.hex-viewer"
        "ms-vscode.hexeditor"
    )

    # Determine the user to run VS Code commands
    USER_TO_USE=${SUDO_USER:-$USER}
    USER_HOME=$(eval echo ~$USER_TO_USE)

    # Ensure VS Code is available for the user
    echo "🔄 Checking if VS Code is in PATH for user: $USER_TO_USE"

    # Check in the system PATH
    if ! command -v code &>/dev/null; then
        # Try adding the VS Code path manually if not found
        echo "❌ VS Code not found in system PATH. Checking user-specific directories..."
        
        # Common locations where VS Code might be installed but not in PATH
        POSSIBLE_PATHS=(
            "$USER_HOME/.vscode/bin"
            "/usr/local/bin"
            "/usr/bin"
            "/snap/bin"
        )

        for path in "${POSSIBLE_PATHS[@]}"; do
            if [ -x "$path/code" ]; then
                echo "✅ Found VS Code in: $path"
                export PATH="$path:$PATH"
                break
            fi
        done
    fi

    # Final check
    if ! command -v code &>/dev/null; then
        echo "❌ VS Code command is still not found. Exiting."
        exit 1
    fi

    echo "✅ VS Code command is available."

    # Install extensions
    for extension in "${EXTENSIONS[@]}"; do
        echo "Installing $extension..."
        if [ -n "$SUDO_USER" ]; then
            sudo -u "$SUDO_USER" code --install-extension "$extension"
        else
            code --install-extension "$extension"
        fi

        if [ $? -ne 0 ]; then
            echo "❌ Failed to install $extension."
        else
            echo "✅ Successfully installed: $extension"
        fi
    done
}

# Main execution
echo "🚀 Starting Visual Studio Code installation process..."
update_system
install_prerequisites
import_microsoft_gpg_key
add_microsoft_repository
update_system  # Update again after adding repo
install_vscode
install_vscode_extensions

echo "🎉 VS Code installation complete!"
exit 0

#!/bin/bash
#v2

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root (use sudo)."
    exit 1
fi

# Determine the non-root user
REAL_USER=${SUDO_USER:-$(who am i | awk '{print $1}')}
if [[ -z "$REAL_USER" || "$REAL_USER" == "root" ]]; then
    echo "❌ Script must be run as sudo but for a non-root user."
    exit 1
fi

USER_HOME=$(eval echo ~$REAL_USER)
DESKTOP_DIR="$USER_HOME/Desktop"
BASHRC="$USER_HOME/.bashrc"

setup_expiration_check() {
    echo "Setting up system expiration check..."

    # Define paths
    INSTALL_DATE_FILE="/etc/install_date"
    EXPIRATION_SCRIPT="/usr/local/bin/check_expiration.sh"
    SYSTEMD_SERVICE="/etc/systemd/system/expiration-check.service"

    # Get the directory of the currently running script
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Define repo locations relative to the script directory
    REPO_EXPIRATION_SCRIPT="$SCRIPT_DIR/../misc_files/check_expiration.sh"
    REPO_SYSTEMD_SERVICE="$SCRIPT_DIR/../misc_files/expiration-check.service"

    # Store install date
    echo "Storing installation date..."
    date +%s > "$INSTALL_DATE_FILE"

    # Move the expiration check script
    if [[ -f "$REPO_EXPIRATION_SCRIPT" ]]; then
        echo "Moving expiration script to /usr/local/bin/..."
        mv "$REPO_EXPIRATION_SCRIPT" "$EXPIRATION_SCRIPT"
        chmod +x "$EXPIRATION_SCRIPT"
    else
        echo "Error: Expiration script not found in repo."
        return 1
    fi

    # Move the systemd service file
    if [[ -f "$REPO_SYSTEMD_SERVICE" ]]; then
        echo "Moving systemd service file to /etc/systemd/system/..."
        mv "$REPO_SYSTEMD_SERVICE" "$SYSTEMD_SERVICE"
    else
        echo "Error: Systemd service file not found in repo."
        return 1
    fi

    # Reload systemd, enable and start service
    echo "Enabling and starting the expiration-check service..."
    systemctl daemon-reload
    systemctl enable expiration-check.service
    systemctl start expiration-check.service

    echo "System expiration setup complete."
}

# Run functions
echo "Starting setup process..."
setup_expiration_check

echo "✅ Setup process complete!"
exit 0
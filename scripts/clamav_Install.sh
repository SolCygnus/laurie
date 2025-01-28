#!/bin/bash

# Script to install, set up, and use ClamAV on an Ubuntu system
# Author: SillyPenguin
# Date: 25 January 2025

LOGFILE="/var/log/clamav_setup.log"

# Function to log messages
echo_log() {
    echo "$1" | tee -a "$LOGFILE"
}

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root." >&2
    exit 1
fi

# Update package lists
echo_log "Updating package lists..."
if ! apt-get update >> "$LOGFILE" 2>&1; then
    echo_log "Failed to update package lists. Exiting."
    exit 1
fi

# Install ClamAV and ClamAV Daemon
echo_log "Installing ClamAV and ClamAV Daemon..."
if ! apt-get install -y clamav clamav-daemon >> "$LOGFILE" 2>&1; then
    echo_log "Failed to install ClamAV. Exiting."
    exit 1
fi

# Stop ClamAV Freshclam service to update the database manually
echo_log "Stopping ClamAV Freshclam service..."
if ! systemctl stop clamav-freshclam >> "$LOGFILE" 2>&1; then
    echo_log "Failed to stop ClamAV Freshclam service. Exiting."
    exit 1
fi

# Update virus signatures
echo_log "Updating ClamAV signature database..."
if ! freshclam >> "$LOGFILE" 2>&1; then
    echo_log "Failed to update ClamAV signature database. Exiting."
    exit 1
fi

# Restart ClamAV Freshclam service
echo_log "Restarting ClamAV Freshclam service..."
if ! systemctl start clamav-freshclam >> "$LOGFILE" 2>&1; then
    echo_log "Failed to restart ClamAV Freshclam service. Exiting."
    exit 1
fi

# Set up a weekly cron job for updating and scanning
echo_log "Setting up a weekly cron job for ClamAV..."
CRONJOB="0 3 * * 0 /usr/bin/freshclam && /usr/bin/clamscan -r / | grep FOUND >> /var/log/clamav_scan.log"
if ! (crontab -l 2>/dev/null; echo "$CRONJOB") | crontab -; then
    echo_log "Failed to set up the cron job. Exiting."
    exit 1
fi

echo_log "Weekly cron job added: Runs every Sunday at 3 AM. Logs stored in /var/log/clamav_scan.log."

# Display basic usage instructions
echo_log "ClamAV installed and configured successfully. Here are some common usage examples:"
echo -e "\nScan all files from the root directory:\n    clamscan -r /\n"
echo -e "Scan files but only show infected files:\n    clamscan -r -i /path-to-folder\n"
echo -e "Scan files but don’t show 'OK' files:\n    clamscan -r -o /path-to-folder\n"
echo -e "Scan files and save results of infected files:\n    clamscan -r /path-to-folder | grep FOUND >> /path-to-folder/file.txt\n"
echo -e "Scan files and move infected files to a quarantine folder:\n    clamscan -r --move=/path-to-quarantine-folder /path-to-folder\n"

echo_log "Check the manual for more options: man clamscan"

echo_log "Setup complete. Log file saved at $LOGFILE."
exit 0

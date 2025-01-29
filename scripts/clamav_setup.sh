#!/bin/bash

# Script to install, set up, and use ClamAV on an Ubuntu system
# Author: SillyPenguin
# Date: 25 January 2025

# Install ClamAV and ClamAV Daemon
echo "Installing ClamAV and ClamAV Daemon..."
if ! apt-get install -y clamav clamav-daemon; then
    echo "❌ Failed to install ClamAV. Exiting."
    exit 1
fi

# Stop ClamAV Freshclam service to update the database manually
echo "Stopping ClamAV Freshclam service..."
if ! systemctl stop clamav-freshclam; then
    echo "❌ Failed to stop ClamAV Freshclam service. Exiting."
    exit 1
fi

# Update virus signatures
echo "Updating ClamAV signature database..."
if ! freshclam; then
    echo "❌ Failed to update ClamAV signature database. Exiting."
    exit 1
fi

# Restart ClamAV Freshclam service
echo "Restarting ClamAV Freshclam service..."
if ! systemctl start clamav-freshclam; then
    echo "❌ Failed to restart ClamAV Freshclam service. Exiting."
    exit 1
fi

# Set up a weekly cron job for updating and scanning
echo "Setting up a weekly cron job for ClamAV..."
CRONJOB="0 3 * * 0 /usr/bin/freshclam && /usr/bin/clamscan -r / | grep FOUND >> /var/log/clamav_scan.log"
(crontab -l 2>/dev/null; echo "$CRONJOB") | crontab -

if [ $? -eq 0 ]; then
    echo "✅ Weekly cron job added: Runs every Sunday at 3 AM. Logs stored in /var/log/clamav_scan.log."
else
    echo "❌ Failed to set up the cron job. Exiting."
    exit 1
fi

echo "✅ Setup complete."
exit 0
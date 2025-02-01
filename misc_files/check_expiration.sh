#!/bin/bash

# File containing install date
INSTALL_DATE_FILE="/etc/install_date"
EXPIRATION_DAYS=365
WARNING_1_DAYS=60
WARNING_2_DAYS=30

# File to store whether warnings were displayed
WARNING_TRACKER="/var/tmp/expiration_warnings.log"

# Function to display notifications (GUI and Terminal)
notify_user() {
    MESSAGE=$1
    echo "$MESSAGE"

    # If GUI session is detected, show a pop-up
    if command -v zenity &>/dev/null; then
        sudo -u $(logname) DISPLAY=:0 zenity --warning --text="$MESSAGE"
    elif command -v notify-send &>/dev/null; then
        sudo -u $(logname) DISPLAY=:0 notify-send "System Expiration Notice" "$MESSAGE"
    fi
}

# Check if install date exists
if [[ ! -f $INSTALL_DATE_FILE ]]; then
    echo "Error: Install date not found. Exiting..."
    exit 1
fi

# Read install date
INSTALL_DATE=$(cat "$INSTALL_DATE_FILE")
CURRENT_DATE=$(date +%s)
DAYS_ELAPSED=$(( (CURRENT_DATE - INSTALL_DATE) / 86400 ))
DAYS_REMAINING=$(( EXPIRATION_DAYS - DAYS_ELAPSED ))

# Show warnings at 60 and 30 days remaining
if [[ $DAYS_REMAINING -le $WARNING_1_DAYS && $DAYS_REMAINING -gt $WARNING_2_DAYS ]]; then
    if ! grep -q "warn60" "$WARNING_TRACKER" 2>/dev/null; then
        notify_user "Warning: Your system will expire in $DAYS_REMAINING days!"
        echo "warn60" >> "$WARNING_TRACKER"
    fi
elif [[ $DAYS_REMAINING -le $WARNING_2_DAYS && $DAYS_REMAINING -gt 0 ]]; then
    if ! grep -q "warn30" "$WARNING_TRACKER" 2>/dev/null; then
        notify_user "Urgent: Your system will expire in $DAYS_REMAINING days! Please download a new version."
        echo "warn30" >> "$WARNING_TRACKER"
    fi
fi

# If system is expired, remove all repos and halt the system
if [[ $DAYS_ELAPSED -ge $EXPIRATION_DAYS ]]; then
    notify_user "System expired! Removing software repositories..."
    
    # Backup sources list before deletion
    cp /etc/apt/sources.list /etc/apt/sources.list.bak
    cp -r /etc/apt/sources.list.d /etc/apt/sources.list.d.bak

    # Remove all repositories
    echo "" > /etc/apt/sources.list
    rm -rf /etc/apt/sources.list.d/*

    notify_user "Repositories have been removed. The system will shut down now."
    sleep 10
    systemctl poweroff
fi
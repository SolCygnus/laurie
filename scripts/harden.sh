#!/bin/bash
# Author: SillyPenguin
# Date: 25 January 2025

# Function to update and upgrade the system
update_system() {
    echo "🔄 Updating and upgrading system..."
    if ! apt update && apt upgrade -y; then
        echo "❌ Failed to update system."
    fi
}

# Function to disable unnecessary services
disable_services() {
    echo "🛑 Disabling and removing unnecessary services..."
    local services=("bluetooth" "cups" "avahi-daemon" "ModemManager" "whoopsie" "apport")

    for service in "${services[@]}"; do
        echo "🔹 Removing $service..."
        systemctl disable "$service" --now
        if ! apt remove --purge -y "$service"; then
            echo "❌ Failed to remove $service."
        fi
    done
}

# Function to remove update notifier
remove_update_notifier() {
    echo "🚫 Removing update notifier..."
    if ! apt remove --purge -y update-notifier update-notifier-common; then
        echo "❌ Failed to remove update notifier."
    fi
}

# Function to configure password policies
configure_password_policies() {
    echo "🔐 Configuring password policies..."
    sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs
    sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   7/' /etc/login.defs
    sed -i 's/^PASS_MIN_LEN.*/PASS_MIN_LEN    12/' /etc/login.defs
    sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   14/' /etc/login.defs
}

# Function to lock the root account
lock_root_account() {
    echo "🔒 Locking the root account..."
    passwd -l root
}

# Function to disable guest account
disable_guest_account() {
    echo "🚫 Disabling guest account..."
    mkdir -p /etc/lightdm/lightdm.conf.d
    echo -e "[Seat:*]\nallow-guest=false" > /etc/lightdm/lightdm.conf.d/50-no-guest.conf
}

# Function to secure home directories
secure_home_directories() {
    echo "🛡️ Securing home directories..."
    chmod -R 700 /home/*
}

# Function to apply filesystem restrictions
apply_filesystem_restrictions() {
    echo "📁 Applying filesystem restrictions..."
    if ! grep -q "/tmp" /etc/fstab; then
        cat <<EOF >> /etc/fstab
/tmp            tmpfs   defaults,noexec,nosuid,nodev 0 0
/var/tmp        tmpfs   defaults,noexec,nosuid,nodev 0 0
EOF
    fi
    mount -o remount /tmp
    mount -o remount /var/tmp
}

# Function to install and check AppArmor
install_apparmor() {
    echo "🛡️ Checking AppArmor status..."
    if ! command -v aa-status &>/dev/null; then
        echo "🔧 Installing missing AppArmor profiles..."
        if ! apt install -y apparmor-profiles apparmor-profiles-extra; then
            echo "❌ Failed to install AppArmor profiles."
        fi
    fi
}

# Function to install and configure Fail2ban
install_fail2ban() {
    echo "🛑 Installing and configuring Fail2ban..."
    if ! apt install -y fail2ban; then
        echo "❌ Failed to install Fail2ban."
    fi

    systemctl enable fail2ban
    cat <<EOF > /etc/fail2ban/jail.local
[ufw]
enabled = true
EOF
    systemctl restart fail2ban
}

# Function to configure UFW firewall rules
configure_ufw() {
    echo "🔥 Configuring UFW with strict rules..."
    ufw default deny incoming
    ufw default deny outgoing

    echo "🔗 Allowing essential outbound traffic..."
    for port in 80 443 53; do
        ufw allow out "$port"/tcp
        ufw allow out "$port"/udp
    done

    echo "📜 Enabling UFW logging..."
    ufw logging on

    echo "🔐 Enabling UFW..."
    ufw --force enable
}

# Function to install and configure auditd
install_auditd() {
    echo "🛡️ Installing and configuring auditd..."
    if ! apt install -y auditd; then
        echo "❌ Failed to install auditd."
    fi

    systemctl enable auditd
    cat <<EOF > /etc/audit/rules.d/hardening.rules
-w /etc/passwd -p wa -k passwd_changes
-w /etc/shadow -p wa -k shadow_changes
EOF
    systemctl restart auditd
}

# Function to install and configure Firejail
install_firejail() {
    echo "🔥 Installing Firejail for browser isolation..."
    if ! apt install -y firejail; then
        echo "❌ Failed to install Firejail."
        return 1
    fi
    echo "alias firefox='firejail firefox'" >> ~/.bashrc
}

# Function to install and run Lynis for security auditing
install_lynis() {
    echo "🔍 Installing and running Lynis..."
    if ! apt install -y lynis; then
        echo "❌ Failed to install Lynis."
    fi
    lynis audit system
}

# Main execution
echo "🚀 Starting Linux hardening process..."
update_system
disable_services
remove_update_notifier
configure_password_policies
lock_root_account
disable_guest_account
secure_home_directories
apply_filesystem_restrictions
install_apparmor
install_fail2ban
configure_ufw
install_auditd
install_firejail
install_lynis

echo "✅ Hardening complete!"
exit 0
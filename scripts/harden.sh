#!/bin/bash
# Author: SillyPenguin
# Date: 25 January 2025

# Update and upgrade the system
echo "🔄 Updating and upgrading system..."
if ! apt update && apt upgrade -y; then
    echo "❌ Failed to update system. Exiting."
    exit 1
fi

# Disable unnecessary services and remove related packages
echo "🛑 Disabling and removing unnecessary services..."
for service in bluetooth cups avahi-daemon ModemManager whoopsie apport; do
    echo "🔹 Removing $service..."
    systemctl disable "$service" --now
    if ! apt remove --purge -y "$service"; then
        echo "❌ Failed to remove $service."
        exit 1
    fi
done

# Remove update notifier
echo "🚫 Removing update notifier..."
if ! apt remove --purge -y update-notifier update-notifier-common; then
    echo "❌ Failed to remove update notifier."
    exit 1
fi

# Configure password policies
echo "🔐 Configuring password policies..."
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   7/' /etc/login.defs
sed -i 's/^PASS_MIN_LEN.*/PASS_MIN_LEN    12/' /etc/login.defs
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   14/' /etc/login.defs

# Lock the root account
echo "🔒 Locking the root account..."
passwd -l root

# Disable guest account
echo "🚫 Disabling guest account..."
mkdir -p /etc/lightdm/lightdm.conf.d
echo -e "[Seat:*]\nallow-guest=false" > /etc/lightdm/lightdm.conf.d/50-no-guest.conf

# Secure home directories
echo "🛡️ Securing home directories..."
chmod -R 700 /home/*

# Apply filesystem restrictions
echo "📁 Applying filesystem restrictions..."
if ! grep -q "/tmp" /etc/fstab; then
    cat <<EOF >> /etc/fstab
/tmp            tmpfs   defaults,noexec,nosuid,nodev 0 0
/var/tmp        tmpfs   defaults,noexec,nosuid,nodev 0 0
EOF
fi
mount -o remount /tmp
mount -o remount /var/tmp

# Verify AppArmor is running
echo "🛡️ Checking AppArmor status..."
if ! aa-status; then
    echo "🔧 Installing missing AppArmor profiles..."
    if ! apt install -y apparmor-profiles apparmor-profiles-extra; then
        echo "❌ Failed to install AppArmor profiles."
        exit 1
    fi
fi

# Install and configure Fail2ban
echo "🛑 Installing and configuring Fail2ban..."
if ! apt install -y fail2ban; then
    echo "❌ Failed to install Fail2ban."
    exit 1
fi
systemctl enable fail2ban
cat <<EOF > /etc/fail2ban/jail.local
[ufw]
enabled = true
EOF
systemctl restart fail2ban

# Harden UFW with tight outbound traffic control
echo "🔥 Configuring UFW with strict rules..."
ufw default deny incoming
ufw default deny outgoing

# Allow only essential outbound traffic
echo "🔗 Allowing essential outbound traffic..."
for port in 80 443 53; do
    ufw allow out "$port"/tcp
    ufw allow out "$port"/udp
done

# Enable UFW logging
echo "📜 Enabling UFW logging..."
ufw logging on

# Enable UFW
echo "🔐 Enabling UFW..."
ufw --force enable

# Install and configure auditd
echo "🛡️ Installing and configuring auditd..."
if ! apt install -y auditd; then
    echo "❌ Failed to install auditd."
    exit 1
fi
systemctl enable auditd
cat <<EOF > /etc/audit/rules.d/hardening.rules
-w /etc/passwd -p wa -k passwd_changes
-w /etc/shadow -p wa -k shadow_changes
EOF
systemctl restart auditd

# Install and configure Firejail for browser isolation
echo "🔥 Installing Firejail for browser isolation..."
if ! apt install -y firejail; then
    echo "❌ Failed to install Firejail."
    exit 1
fi
echo "alias firefox='firejail firefox'" >> ~/.bashrc

# Install and run Lynis for system auditing
echo "🔍 Installing and running Lynis..."
if ! apt install -y lynis; then
    echo "❌ Failed to install Lynis."
    exit 1
fi
lynis audit system

echo "✅ Hardening complete!"
exit 0
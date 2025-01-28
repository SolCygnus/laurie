#!/bin/bash
# Author: SillyPenguin
# Date: 25 January 2025

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Update and upgrade the system
echo "Updating system..."
apt update && apt upgrade -y

# Disable unnecessary services and remove related packages
echo "Disabling and removing unnecessary services..."

# Disable and remove Bluetooth
echo "Removing Bluetooth services..."
systemctl disable bluetooth --now
apt remove --purge bluez -y

# Disable and remove printing services (CUPS)
echo "Removing printing services..."
systemctl disable cups --now
apt remove --purge cups -y

# Disable and remove Avahi (network discovery service)
echo "Removing Avahi daemon..."
systemctl disable avahi-daemon --now
apt remove --purge avahi-daemon -y

# Disable and remove ModemManager (mobile broadband management)
echo "Removing ModemManager..."
systemctl disable ModemManager --now
apt remove --purge modemmanager -y

# Disable and remove error reporting tools (Whoopsie and Apport)
echo "Removing error reporting tools..."
systemctl disable whoopsie --now
apt remove --purge whoopsie -y
systemctl disable apport.service --now
apt remove --purge apport -y

# Remove update notifier
echo "Removing update notifier..."
apt remove --purge update-notifier update-notifier-common -y

# Configure password policies
echo "Configuring password policies..."
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   7/' /etc/login.defs
sed -i 's/^PASS_MIN_LEN.*/PASS_MIN_LEN    12/' /etc/login.defs
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   14/' /etc/login.defs

# Lock the root account
echo "Locking the root account..."
passwd -l root

# Disable guest account
echo "Disabling guest account..."
mkdir -p /etc/lightdm/lightdm.conf.d
echo -e "[Seat:*]\nallow-guest=false" > /etc/lightdm/lightdm.conf.d/50-no-guest.conf

# Secure home directories
echo "Securing home directories..."
chmod -R 700 /home/*

# Apply filesystem restrictions
echo "Applying filesystem restrictions..."
cat <<EOF >> /etc/fstab
/tmp            tmpfs   defaults,noexec,nosuid,nodev 0 0
/var/tmp        tmpfs   defaults,noexec,nosuid,nodev 0 0
EOF
mount -o remount /tmp
mount -o remount /var/tmp

# Verify AppArmor is running
echo "Checking AppArmor status..."
aa-status || apt install apparmor-profiles apparmor-profiles-extra -y

# Install and configure Fail2ban
echo "Installing and configuring Fail2ban..."
apt install fail2ban -y
systemctl enable fail2ban
cat <<EOF > /etc/fail2ban/jail.local
[ufw]
enabled = true
EOF
systemctl restart fail2ban

# Harden UFW with tight outbound traffic control
echo "Configuring UFW with strict rules..."
ufw default deny incoming
ufw default deny outgoing

# Allow only essential outbound traffic
echo "Allowing essential outbound traffic..."
ufw allow out 80/tcp      # HTTP
ufw allow out 443/tcp     # HTTPS
ufw allow out 53/udp      # DNS

# Enable UFW logging
echo "Enabling UFW logging..."
ufw logging on

# Enable UFW
ufw --force enable

# Install and configure auditd
echo "Installing and configuring auditd..."
apt install auditd -y
systemctl enable auditd
cat <<EOF > /etc/audit/rules.d/hardening.rules
-w /etc/passwd -p wa -k passwd_changes
-w /etc/shadow -p wa -k shadow_changes
EOF
systemctl restart auditd

# Install and configure Firejail for browser isolation
echo "Installing Firejail for browser isolation..."
apt install firejail -y
echo "alias firefox='firejail firefox'" >> ~/.bashrc

# Install and run Lynis for system auditing
echo "Installing and running Lynis..."
apt install lynis -y
lynis audit system

echo "Hardening complete!"

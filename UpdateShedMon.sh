#!/bin/bash

# This script enables and configures unattended-upgrades to automatically patch Ubuntu servers every week at 17:00.

# Exit if not running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

# Update package information
apt-get update

# Install unattended-upgrades package if not already installed
if ! dpkg -l | grep -q "unattended-upgrades"; then
    apt-get install -y unattended-upgrades
fi

# Configure unattended-upgrades
cat <<EOF > /etc/apt/apt.conf.d/20auto-upgrades
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF

# Enable and start the unattended-upgrades service
systemctl enable unattended-upgrades
systemctl start unattended-upgrades

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Check if cron is active
if systemctl is-active --quiet cron; then
  echo "Cron is already running."
else
  echo "Starting Cron..."
  systemctl start cron
  echo "Cron started."
fi

# Create a cron job for Monday at 6 AM
(crontab -l ; echo "0 6 * * 1 /path/to/your/patch_server.sh") | crontab -

echo "Updates scheduled for Monday at 6AM -8AM "

exit 0

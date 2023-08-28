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

# Create a cron job to run the updates every week at 17:00
CRONJOB="0 17 * * 0 /usr/bin/unattended-upgrade"
(crontab -l ; echo "$CRONJOB") | sort - | uniq - | crontab -

echo "Automatic patching using unattended-upgrades is now set up and scheduled for every week at 17:00."

exit 0

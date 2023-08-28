#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Update package lists
apt-get update

# Upgrade packages
apt-get upgrade -y

# Dist-upgrade (handles package changes that require new dependencies)
apt-get dist-upgrade -y

# Clean up obsolete packages
apt-get autoremove -y

# Clean up cached package files
apt-get clean

echo "Server patched successfully"

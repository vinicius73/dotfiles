#!/usr/bin/env bash

set -euo pipefail

# Change ownership of directories securely
sudo chown "$USER:users" /usr/local/bin || { echo "Failed to change ownership of /usr/local/bin"; exit 1; }
sudo chown "$USER:users" /opt || { echo "Failed to change ownership of /opt"; exit 1; }

# Increase inotify watches limit
INOTIFY_CONF="fs.inotify.max_user_watches=524288"
echo "$INOTIFY_CONF" | sudo tee -a /etc/sysctl.conf > /dev/null || { echo "Failed to update /etc/sysctl.conf"; exit 1; }
sudo sysctl -p || { echo "Failed to reload sysctl.conf"; exit 1; }

echo "$INOTIFY_CONF" | sudo tee -a /etc/sysctl.d/99-sysctl.conf > /dev/null || { echo "Failed to update /etc/sysctl.d/99-sysctl.conf"; exit 1; }
sudo sysctl --system || { echo "Failed to reload sysctl system settings"; exit 1; }

echo "Script executed successfully."
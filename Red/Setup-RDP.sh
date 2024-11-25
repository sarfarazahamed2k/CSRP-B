#!/bin/bash

# Fix broken or incomplete installations
# sudo dpkg --configure -a
# sudo apt --fix-broken install -y

# Update and upgrade the system
sudo apt update && sudo apt upgrade -y

# Install XRDP
sudo DEBIAN_FRONTEND=noninteractive apt install xrdp -y

# Install UFW
sudo DEBIAN_FRONTEND=noninteractive apt install ufw -y

# Install XFCE desktop environment
sudo DEBIAN_FRONTEND=noninteractive apt install xfce4 xfce4-goodies -y

# # Configure xrdp to use XFCE by default
echo xfce4-session > ~/.xsession

# # Modify the xrdp startup script
sudo sed -i.bak 's|test -x /etc/X11/Xsession && exec /etc/X11/Xsession|#&|' /etc/xrdp/startwm.sh
sudo sed -i 's|exec /bin/sh /etc/X11/Xsession|#&|' /etc/xrdp/startwm.sh
echo "startxfce4" | sudo tee -a /etc/xrdp/startwm.sh

# Start XRDP service
sudo systemctl start xrdp

# Enable XRDP service to start at boot
sudo systemctl enable xrdp

# Allow RDP traffic on port 3389 through the firewall
sudo ufw allow 3389/tcp

# Reload the firewall rules
sudo ufw reload

# Ensure that default configurations are used without prompts
echo "xrdp installation and configuration completed. The default options have been applied automatically."

wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb

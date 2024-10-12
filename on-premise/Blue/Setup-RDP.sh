#!/bin/bash

# Update the system
sudo apt update && sudo apt upgrade -y

# Install xrdp
sudo apt install xrdp -y

# Install XFCE desktop environment
sudo apt install xfce4 xfce4-goodies -y

# Configure xrdp to use XFCE by default
echo xfce4-session > ~/.xsession

# Modify the xrdp startup script
sudo sed -i.bak 's|test -x /etc/X11/Xsession && exec /etc/X11/Xsession|#&|' /etc/xrdp/startwm.sh
sudo sed -i 's|exec /bin/sh /etc/X11/Xsession|#&|' /etc/xrdp/startwm.sh
echo "startxfce4" | sudo tee -a /etc/xrdp/startwm.sh

# Start and enable xrdp service
sudo systemctl start xrdp
sudo systemctl enable xrdp

# Allow RDP through the firewall
sudo ufw allow 3389/tcp

# Restart the xrdp service
sudo systemctl restart xrdp

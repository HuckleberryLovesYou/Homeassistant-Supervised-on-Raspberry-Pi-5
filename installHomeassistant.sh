#!/bin/sh
os_info=$(hostnamectl status | grep "Operating System:" | cut -d: -f2 | xargs); [ "$os_info" = "Debian GNU/Linux 12 (bookworm)" ] && echo "OS used is supported" || { echo "OS does not match. Exiting."; exit 1; }
echo "I: Homeassistant Supervised will now be installed:"

# Kernel config
echo "Adding kernel configurations..."
sudo apt install nano -y && sudo bash -c 'echo "kernel=kernel8.img" | cat - config.txt > temp && mv temp config.txt' && echo "apparmor=1 security=apparmor" | sudo tee -a cmdline.txt && sudo reboot

# Update system
echo "I: Updating the system..."
sudo apt update -y && sudo apt upgrade -y

# Docker-ce and Docker compose installation
echo "I: Installing Docker and Docker-compose..."
sudo apt install curl -y && sudo curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh && sudo rm get-docker.sh && sudo apt install -y libffi-dev libssl-dev python3-dev python3 python3-pip && sudo apt install docker-compose -y && sudo systemctl enable docker && user=$(whoami) && sudo usermod -aG docker $user && sudo mkdir -p $HOME/docker-data

echo "I: Entering root mode to configure system for Home Assistant..."
sudo su -

# Installation of Dependencies
echo "I: Installing dependencies..."
apt install apparmor jq wget curl udisks2 libglib2.0-bin network-manager dbus systemd-journal-remote cifs-utils lsb-release nfs-common systemd-resolved -y && systemctl restart systemd-resolved.service

# Downloading and installing of OS-Agent
echo "Downloading and installing os-agent..."
wget -O os-agent_linux_aarch64.deb $(curl -s https://api.github.com/repos/home-assistant/os-agent/releases/latest | grep "browser_download_url.*linux_aarch64.deb" | cut -d '"' -f 4)
dpkg -i os-agent_linux_aarch64.deb

# Downloading and installation of Homeassistant Supervised
echo "Downloading and installing Home Assistant Supervised..."
wget -O homeassistant-supervised.deb https://github.com/home-assistant/supervised-installer/releases/latest/download/homeassistant-supervised.deb
apt install ./homeassistant-supervised.deb -y

# Finish output
echo "Installation is now finished. Your system will restart soon."
hostname=$(hostname)
echo .
echo .
echo .
echo .
echo "After the reboot you will be able to reach Home Assistant at http://$hostname:8123"

# Reboot
sleep 5 ; reboot
echo "Restarting the system..."
reboot

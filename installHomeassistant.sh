#!/bin/sh
echo "Hello world"

# Actualizar el sistema
echo "Updating the system..."
sudo apt-get update && sudo apt-get upgrade -y

# Instalación de Docker y Docker-compose
echo "Installing Docker and Docker-compose..."
sudo apt-get install curl -y
sudo curl -fsSL https://get.docker.com | sudo bash
sudo apt-get install -y libffi-dev libssl-dev python3-dev python3 python3-pip
sudo apt-get install docker-compose -y
sudo systemctl enable docker
user=$(whoami)
sudo usermod -aG docker $user

# Verificar la instalación de Docker
echo "Checking Docker installation..."
sudo docker run hello-world

# Configuraciones del sistema necesarias para Home Assistant
echo "Entering root mode to configure system for Home Assistant..."
sudo su -

# Instalar dependencias
echo "Installing necessary dependencies..."
apt-get install apparmor jq wget curl udisks2 libglib2.0-bin network-manager dbus systemd-journal-remote cifs-utils lsb-release nfs-common systemd-resolved -y

# Descargar e instalar os-agent
echo "Downloading and installing os-agent..."
wget https://github.com/home-assistant/os-agent/releases/download/1.6.0/os-agent_1.6.0_linux_aarch64.deb
dpkg -i os-agent_1.6.0_linux_aarch64.deb

# Verificar la instalación de os-agent
echo "Verifying os-agent installation..."
gdbus introspect --system --dest io.hass.os --object-path /io/hass/os || echo "Error: os-agent installation failed."

# Descargar e instalar Home Assistant Supervised
echo "Downloading and installing Home Assistant Supervised..."
wget -O homeassistant-supervised.deb https://github.com/home-assistant/supervised-installer/releases/latest/download/homeassistant-supervised.deb
apt-get install ./homeassistant-supervised.deb

# Reiniciar el sistema
echo "Restarting the system..."
reboot

echo "Installation completed. You can now access Home Assistant at: http://<Your Pi's IP Address>:8123 or http://homeassistant.local:8123"

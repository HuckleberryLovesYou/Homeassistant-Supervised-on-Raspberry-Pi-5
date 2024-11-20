#!/bin/bash

set -e

FLAG_FILE="/tmp/installHomeassistant_incomplete.flag"
CONFIG_PROGRESS="/tmp/installHomeassistant_progress"
SCRIPT_PATH="$(realpath "$0")"

# prompt user function
prompt_user() {
    echo "The script has rebooted your system, but hasn't finished. Would you like to continue? (y/n)"
    read -r choice
    if [[ $choice != "y" ]]; then
        echo "Aborting the script. Re-running the script may break the system. Follow manual steps instead."
        rm -f "$FLAG_FILE" "$CONFIG_PROGRESS"
        exit 0
    fi
}

# Checks if root executed the script
if [[ $EUID -eq 0 ]]; then
    echo "Please run this script as a user with sudo. Aborting."
    exit 1
fi

# Check if the script is incomplete
if [[ -f "$FLAG_FILE" ]]; then
    prompt_user
    STEP=$(cat "$CONFIG_PROGRESS")
else
    STEP=0
	echo "No flag file found."
    echo "Starting new execution..."
    touch "$FLAG_FILE"
	echo "flag file created"
fi


case $STEP in
    0)
        echo "I: This script is making kernel configuration changes."
		echo "I: Re-running the script may break the system. Follow manual steps instead."
		echo "I: The script has to reboot the system multiple times. Save your work before continuing"
		echo "I: You'll get prompted to resume the script after every reboot."
		echo "Do you want to continue (y/n)"
		read -r continue
		if [[ $continue != "y" ]]; then
			echo "Aborting the script. Re-running the script may break the system. Follow manual steps instead."
			rm -f "$FLAG_FILE" "$CONFIG_PROGRESS"
			exit 0
		fi

		BASHRC_FILE="$HOME/.bashrc"

		# Add content to .bashrc
		if ! grep -Fxq "if [[ -f $FLAG_FILE ]]; then" "$BASHRC_FILE"; then
			# Append the lines to the .bashrc file
			echo -e "\n# Run script after reboot if it's incomplete" >> "$BASHRC_FILE"
			echo "if [[ -f $FLAG_FILE ]]; then" >> "$BASHRC_FILE"
			echo "    $SCRIPT_PATH" >> "$BASHRC_FILE"
			echo "fi" >> "$BASHRC_FILE"
			echo "I: Added script resume logic to .bashrc."
			echo "N: Don't add anything else to .bashrc while script is running."
		else
			echo ".bashrc already contains the resume logic."
		fi

		
		echo "I: Step 0: Making kernel configuration changes..."
        # Step 0
		
		# Check OS compatibility
		os_info=$(hostnamectl status | grep "Operating System:" | cut -d: -f2 | xargs)
		if [ "$os_info" != "Debian GNU/Linux 12 (bookworm)" ]; then
			echo "E: OS does not match. Exiting."
			exit 1
		fi
		echo "I: OS used is supported"
		echo "I: Home Assistant Supervised will now be installed:"
		
		# Kernel config
		echo "I: Adding kernel configurations..."
		if ! grep -q "kernel=kernel8.img" /boot/firmware/config.txt; then
			sed -i '1s/^/kernel=kernel8.img\n/' /boot/firmware/config.txt # adds string at the top of the file
		fi
		if ! grep -q "apparmor=1 security=apparmor" /boot/firmware/cmdline.txt; then
			echo "apparmor=1 security=apparmor" >> /boot/firmware/cmdline.txt # appends the string
		fi
		
		echo "I: A reboot is now required."
		echo "I: System will reboot in 5 seconds."
		sleep 5
		
        echo "1" > "$CONFIG_PROGRESS"
        reboot
        ;;
    1)
        echo "I: Step 1: Resuming after first reboot..."
		
        # Update system
		echo "I: Updating the system..."
		apt update -y && apt upgrade -y && apt autoremove -y # added autoremove to ensure clean installation

		# Docker-ce and Docker Compose installation
		echo "I: Installing Docker and Docker Compose..."
		apt install curl -y
		curl -fsSL https://get.docker.com -o get-docker.sh
		sh get-docker.sh
		rm get-docker.sh
		apt install -y libffi-dev libssl-dev python3-dev python3 python3-pip docker-compose
		systemctl enable docker
		user=$(whoami)
		usermod -aG docker $user
		mkdir -p "$HOME/docker-data"
		echo "I: A directory was created for your docker data."
		echo "I: You can change the location, but it makes sense to store your data in a organized file structure."
		echo "I: You need to log out and back in for Docker group changes to take effect."

		
		# Installation of Dependencies
		echo "I: Installing dependencies..."
		apt install apparmor jq wget curl udisks2 libglib2.0-bin network-manager dbus systemd-journal-remote cifs-utils lsb-release nfs-common systemd-resolved -y
		systemctl restart systemd-resolved.service

		# Downloading and installing OS-Agent
		echo "I: Downloading and installing OS-Agent..."
		wget -O os-agent_linux_aarch64.deb $(curl -s https://api.github.com/repos/home-assistant/os-agent/releases/latest | grep "browser_download_url.*linux_aarch64.deb" | cut -d '"' -f 4)
		dpkg -i os-agent_linux_aarch64.deb || { echo "Error: OS-Agent installation failed." >&2; exit 1; }

		# Downloading and installing Home Assistant Supervised
		echo "I: Downloading and installing Home Assistant Supervised..."
		wget -O homeassistant-supervised.deb https://github.com/home-assistant/supervised-installer/releases/latest/download/homeassistant-supervised.deb
		apt install ./homeassistant-supervised.deb -y || { echo "Error: Home Assistant Supervised installation failed." >&2; exit 1; }
		
		# Removing .bashrc content
		sed -i '/# Run script after reboot if it'\''s incomplete/,/fi/d' "$BASHRC_FILE"
		echo "Removed added content from .bashrc"
		
		hostname=$(hostname)
		echo "I: Installation is now finished. Your system will restart soon."
		echo "N: A reboot is now required."
		echo "I: After the reboot, you will be able to reach Home Assistant at http://$hostname:8123"
		echo "I: System will reboot in 5 seconds."
		sleep 5
        echo "2" > "$CONFIG_PROGRESS"
		rm -f "$FLAG_FILE" "$CONFIG_PROGRESS"
        echo "I: Script finished successfully!"
        reboot
        ;;
    *)
        echo "E: Unknown state. Aborting."
        exit 1
        ;;
esac

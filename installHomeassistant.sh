#!/bin/bash

# By default, skip checks is set to 0. If you want to skip the OS and Architecture checks, set variable below to 1
SKIP_CHECKS=0  # Set variable to 1 to skip

set -e

FLAG_FILE="/var/tmp/installHomeassistant_incomplete.flag"
CONFIG_PROGRESS="/var/tmp/installHomeassistant_progress"
SCRIPT_PATH="$(realpath "$0")"
BASHRC_FILE="$HOME/.bashrc"

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
			echo "Aborting the script. Re-running the script should be safe."
			rm -f "$FLAG_FILE" "$CONFIG_PROGRESS"
			exit 0
		fi


		# Add resume logic to .bashrc
		if ! grep -Fxq "if [[ -f $FLAG_FILE ]]; then" "$BASHRC_FILE"; then
			# Appends the following lines to the .bashrc file
			printf "\n# Run script after reboot if it's incomplete\n" >> "$BASHRC_FILE"
			echo "if [[ -f $FLAG_FILE ]]; then" >> "$BASHRC_FILE"
			echo "    $SCRIPT_PATH" >> "$BASHRC_FILE"
			echo "fi" >> "$BASHRC_FILE"
			echo "I: Added script resume logic to .bashrc."
			echo "To continue script after reboot login to the shell with current user."
			echo "N: Don't add anything else to .bashrc while script is running."
		else
			echo ".bashrc already contains the resume logic."
		fi

		
		echo "I: Step 0: Making kernel configuration changes..."
        # Step 0
		
		# If SKIP_CHECKS is 1, skip the checks
		if [ "$SKIP_CHECKS" -eq 0 ]; then
		    # Check OS compatibility
		    os_info=$(hostnamectl status | grep "Operating System:" | cut -d: -f2 | xargs)
		    if [ "$os_info" != "Debian GNU/Linux 12 (bookworm)" ]; then
		        echo "E: OS does not match an OS where the script was tested on. Exiting."
		        echo "I: If you still want to try the automatic installation (which might work), edit the script to ignore these checks."
		        echo "I: To do this, enter an editor and uncomment the following line at the top of the script: 'SKIP_CHECKS=1'"
		        echo "I: If your untested OS works, please open an issue at https://github.com/HuckleberryLovesYou/Homeassistant-Supervised-on-Raspberry-Pi-5/issues for this OS to be added."
		        exit 1
		    fi
		    echo "I: OS used is supported"
		    
		    # Check Architecture
		    if [ "$(uname -m)" != "aarch64" ]; then
		        echo "E: Architecture is not 64-bit. Exiting."
		        echo "I: If you still want to try the automatic installation, edit the script to ignore these checks."
		        echo "I: To do this, enter an editor and uncomment the following line at the top of the script: 'SKIP_CHECKS=1'"
		        echo "I: If your untested architecture works, please open an issue at https://github.com/HuckleberryLovesYou/Homeassistant-Supervised-on-Raspberry-Pi-5/issues for this architecture to be added."
		        exit 1
		    fi
		    echo "I: Architecture used is supported"
		else
		    echo "I: The OS and Architecture checks were skipped because SKIP_CHECKS was equal to 1."
		fi
		echo "I: OS used is supported"
		echo "I: Home Assistant Supervised will now be installed:"
		
		# Kernel config
		echo "I: Adding kernel configurations..."
		if ! grep -q "kernel=kernel8.img" /boot/firmware/config.txt; then
			sed -i '1s/^/kernel=kernel8.img\n/' /boot/firmware/config.txt # adds string at the top of the file
		fi
		if ! grep -q "apparmor=1 security=apparmor" /boot/firmware/cmdline.txt; then
			sed -z '$ s/\n$//' /boot/firmware/cmdline.txt > /tmp/cmdline.txt && mv /tmp/cmdline.txt /boot/firmware/cmdline.txt && printf " apparmor=1 security=apparmor" >> /boot/firmware/cmdline.txt
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
		echo "I: Installing dependencies for Homeassistant..."
		apt install apparmor jq wget curl udisks2 libglib2.0-bin network-manager dbus systemd-journal-remote cifs-utils lsb-release nfs-common systemd-resolved -y
		systemctl restart systemd-resolved.service

		# Downloading and installing OS-Agent
		echo "I: Downloading OS-Agent..."
		wget -O os-agent_linux_aarch64.deb $(curl -s https://api.github.com/repos/home-assistant/os-agent/releases/latest | grep "browser_download_url.*linux_aarch64.deb" | cut -d '"' -f 4)
        echo "I: Installing OS-Agent..."
		dpkg -i os-agent_linux_aarch64.deb || { echo "E: OS-Agent installation failed." >&2; exit 1; }
        echo "I: OS-Agent was succesfully installed."

		# Downloading and installing Home Assistant Supervised
		echo "I: Downloading Home Assistant Supervised..."
		wget -O homeassistant-supervised.deb https://github.com/home-assistant/supervised-installer/releases/latest/download/homeassistant-supervised.deb
        echo "I: Installing Home Assistant Supervised..."
        echo "In the next step you get to select the maschine type for homeassistant-supervised."
        echo "You have to select 'pi5-64bit'. Press enter to continue."
		read -r continue_maschine_type
		apt install ./homeassistant-supervised.deb -y || { echo "E: Home Assistant Supervised installation failed." >&2; exit 1; }
		echo "I: Homeassistant Supervised was succesfully installed."
        
        echo "I: A reboot is now required."
		echo "I: System will reboot in 5 seconds."
        echo "2" > "$CONFIG_PROGRESS"
        sleep 5
        reboot
        ;;
    2)
        echo "I: Starting cleanup..."
        # Removing .bashrc content
        echo "I: Removing resume logic added to .bashrc..."
        sed -i '/# Run script after reboot if it'\''s incomplete/,/fi/d' "$BASHRC_FILE"

        # Removing flag file and progress file
        echo "I: Removing configuration files..."
        rm -f "$FLAG_FILE" "$CONFIG_PROGRESS"

        # Removing downlaoded OS-Agent and homeassistant-supervised installer
        echo "I: Removing downloaded installers..."
        rm -f homeassistant-supervised.deb
        rm -f os-agent_linux_aarch64.deb
        
        # Removing unused packages
        apt autoremove -y
        
        
        sleep 10
        echo "I: Finished cleanup."


        hostname=$(hostname)
        echo "I: You are now able to reach Home Assistant at http://$hostname:8123. Keep in mind, it could take some time to start Homeassistant."
        sleep 2
        echo "I: Script finished successfully!"
        ;;
    *)
        echo "E: Unknown state. Aborting."
        exit 1
        ;;
esac

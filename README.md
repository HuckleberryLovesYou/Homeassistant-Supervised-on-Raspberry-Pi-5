# Homeassistant-Supervised-on-Raspberry-Pi-5
This is a tutorial about the installation of Homeassistant Supervised on your Raspberry Pi 5 running Raspberry Pi OS 64bit.
### If something doesn't work, make sure to check out the Troubleshooting Section at the bottom of this Readme.

## [Skip the blah](https://github.com/HuckleberryLovesYou/Homeassistant-Supervised-on-Raspberry-Pi-5/blob/main/README.md#kernel-setup)

Didn't found a fix for your Prolbem? Feel free to open an issue in this repository!

Found something, which wasn't described right or bad? Feel free to open an issue in this repository!

## First of all - Why even HA-Supervised? 
It's pretty simple:

```python
want_addons = %true/false%
want_control_over_system = %true/false%

if want_addons == true:
   if want_control_over_system == true:
      print("Get HA-Supervised")
   else:
     print("Get HA-OS") 
else:
   print("Get HA-Core")
```
Or in words:
If you want to use add-ons then the only option is to use HA-OS or HA-Supervised.
If you don't want add-ons and only care about integrations, then you can use HA-Core.
If you decide to want add-ons you can now either decide between, giving away all of your possibilities and just have wasted 90 bucks on a pi 5 which isn't used more than 10% or having nearly every possible control about your system and not being restricted by your OS.

Or click [here](https://community-assets.home-assistant.io/original/4X/c/c/e/ccef6f3b100c0ca1c135851dbdea598502440711.png) to see the overview of all installation methods

### Supported or Unsupported

When am I running a unsupported System?
For the entire list take a look [here](https://github.com/home-assistant/architecture/blob/master/adr/0014-home-assistant-supervised.md)


What could be the problem with having a unsupported system?

- No support from HA-Mods
- No way of reporting bugs.
[more Info](https://github.com/home-assistant/architecture/blob/master/adr/0014-home-assistant-supervised.md)

# Requirements
- Access to the Terminal of you Raspberry Pi 5 (SSH recommended)
- OS: Raspberry Pi OS (can be checked with `hostnamectl`)
```
Operating System: Debian GNU/Linux 12 (bookworm)
          Kernel: Linux 6.1.0-rpi8-rpi-v8
    Architecture: arm64
```
- Unrestriced Internet Access for your Raspberry Pi 5
- Privileges to change to root

# kernel setup
Follow the instructions given to you by the comments in each code section.
```
# execute the following to edit the config.txt
sudo apt install nano
sudo nano /boot/firmware/config.txt
```
```
# put the next lines **somewhere** in your **config.txt**-File
# Own Edits
apparmor=1 security=apparmor
kernel=kernel8.img
# exit nano with saving
```
```
# execute the following to edit the cmdline.txt
sudo nano /boot/firmware/cmdline.txt
```
```
# Append the following to the **end** of the line in the **cmdline.txt**-File
apparmor=1 security=apparmor
# exit nano with saving
```
```
# reboot now to let the edits take effect
sudo reboot
```

# Installation of docker and docker-compose

## Variant 1: Install docker and docker-compose **quickly**
```
#Paste in this script
sudo apt-get update
sudo apt install curl -y
sudo curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo rm get-docker.sh
sudo apt install -y libffi-dev libssl-dev python3-dev python3 python3-pip
sudo apt install docker-compose -y
sudo systemctl enable docker
user=$(whoami)
sudo usermod -aG docker $user
sudo mkdir -p $HOME/docker-compose-data
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
You can check if the docker-installation works by using the following command
```
sudo docker run hello-world
```
If it works skip to [here](https://github.com/HuckleberryLovesYou/Homeassistant-Supervised-on-Raspberry-Pi-5?tab=readme-ov-file#making-your-device-ready-to-run-homeassistant) else try variant 2.

## Variant 2: Download and Install [The Banger Tech Utility](https://github.com/BangerTech/The-BangerTECH-Utility/tree/development) tool for **easier** installation of Docker and docker-compose
```
sudo wget https://raw.githubusercontent.com/BangerTech/The-BangerTECH-Utility/development/bangertech_utility_arm.sh
```

Change the permissions
```
sudo chmod +x bangertech_utility_arm.sh
```

execute the utility by using sh like shown in the following
It takes about 20 seconds to start
```
sh bangertech_utility_arm.sh
```

### Now the main installation of docker
**It might take up to a minute. Don’t cancel at any time!**


**By installing e.g. Portainer or other unsupported software, Homeassistant might not start**


Now with that out of the way, you can navigate with the arrow keys, select or deselect with the space bar and finish by hitting enter.
If getting prompted if you want to reboot, hit enter to reboot.
In the following fields, you should only pick “Docker+Docker-Compose” and then follow the Steps presented by the Tool.

You can check if the docker-installation works by using the following command
```
sudo docker run hello-world
```
# Making your device ready to run Homeassistant

### If you want to run Portainer as well take a look [here](https://github.com/HuckleberryLovesYou/Homeassistant-Supervised-on-Raspberry-Pi-5?tab=readme-ov-file#use-portainer-anyway)

From now on everything needs to be executed as root and does **NOT** support sudo anymore.
So, change into root-mode:
```
sudo su -
```

Update every Package on your Device.
```
apt update && apt upgrade -y
```

## Installation of dependencies
Now install all the required Dependencies. 
You might have to restart depending on of there was a kernel update going on or not.
```
apt install apparmor jq wget curl udisks2 libglib2.0-bin network-manager dbus systemd-journal-remote cifs-utils lsb-release nfs-common systemd-resolved -y
```

# Download os-agent
Today, the newest verison is 1.6.0
If you do that in the future, you may want to check for a newer version.
To do that, go to this [GitHub page](https://github.com/home-assistant/os-agent/releases) 
Scroll to the newest assets and right-click on the asset called os-agent_%Newest Version%_linux_**aarch64.deb**
Hit right click while hovering the file. Then click on **copy link address** and put it in the command below.
```
wget %Your above copied link%
```
It should then look like the following example except the version-number.
```
wget https://github.com/home-assistant/os-agent/releases/download/1.6.0/os-agent_1.6.0_linux_aarch64.deb
# You can type "ls" to ensure the download was succesful
```

# Install os-agent
To do that, we use dpkg.
Using Tab, the filename completes itself after a few characters.
```
dpkg -i os-agent_%Your Version Number_linux_x86_64.deb
```
You can test if the installation was successful by running:
```
gdbus introspect --system --dest io.hass.os --object-path /io/hass/os
```
This should **NOT** return an error.
You might need to install libglib2.0-bin to get the gdbus command.
If you get an object introspection with interface etc. OS Agent is working as expected.

# Download homeassistant-supervised
Today, the newest version is 1.6.0.
By using the following command you automatically download the latest version of Homeassistant.
If you still want to check, you can do this on this [Github page](https://github.com/home-assistant/supervised-installer/releases/)
```
wget -O homeassistant-supervised.deb https://github.com/home-assistant/supervised-installer/releases/latest/download/homeassistant-supervised.deb
# You can type "ls" to ensure the download was succesful
# The -O  is there to overwrite exiting files if there are, which makes troubleshooting easier, by having no need to uninstall it after an error.
```

# Install Homeassistant
To install execute the following command.
```
apt install ./homeassistant-supervised.deb
```

During the Installation, you get asked “Select machine type”.
Choose the "pi4-64bit" version or use the not by me tested version "pi5-64bit".

Near the end there should be this output.
```
[info] Install supervisor startup scripts
[info] Install AppArmor scripts
[info] Start Home Assistant Supervised
[info] Installing the ‘ha’ cli
[info] Switching to cgroup v1
[info] Within a few minutes you will be able to reach Home Assistant at:
[info] http://homeassistant.local:8123 or using the IP address of Raspberry Pi
[info] machine: http://<Your Pi’s IP Address>:8123
```
After setup finished without errors you can go on.

Restart your **entire** system with the following command.
```
reboot
```
# Accessing your Homeassistant WebGUI
Access your Homeassistant-WebGUI by entering the following in your browser’s address bar.
Make sure to use **http** and **NOT** https.
You can also use the hostname that you set, like shown in the second example.
To find out your Pi's IP you can either look in your routers network tab or use the following command.
The standard homeassistant port is **8123**.
```
hostname -I
```
```
http://<Your Pi's IP-Adress>:8123
```
E.g.http://192.168.2.5:8123
```
http://<Your Pi’s hostname>:8123
```
E.g.http://raspberrypi:8123 # Standard hostname is raspberrypi




# Troubleshooting
## Error while installing Homeassistant-Supervised.deb caused by wrong os-agent
If something goes wrong by the Installation of Homeassistant Installer, you can try to uninstall the OS-Agent with the following
```
sudo dpkg -r os-agent
```
After that you can dwonload the right version of the os-agent and reinstall it.
```
dpkg -i os-agent_%Your Version Number%_linux_x86_64.deb
```
Now, install Homeassistant with the same command as mentioned above, because it already overwrites everything.


## Use Portainer anyway
To bypass the container-name-check you have to name the portainer-container different. 
Remove any old Portainer images like shown below:
```
sudo docker rmi portainer/portainer-ce
```
Now pull the image again.
```
sudo docker pull portainer/portainer-ce:latest
```
Now rename the image
```
sudo docker tag  portainer/portainer-ce:latest iamnotportainer
```
Now start a docker-container
```
sudo docker run -d -p 9000:9000 -p 8000:8000 --name iamnotportainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data iamnotportainer
```
Now check if the container was named the right way
```
sudo docker ps -a
```
After that you can restart HA

If you run into any problems you mighty want to try the following commands:
```
sudo systemctl daemon-reload
```
```
sudo systemctl restart docker
```

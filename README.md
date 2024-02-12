# Homeassistant-Supervised-on-Raspberry-Pi-5
This is a tutorial about the installation of Homeassistant Supervised on your Raspberry Pi 5

# Setting up your kernel settingy
Put the following 3 lines in your config.txt-File in the boot folder of your Raspberry Pi 5
```
apparmor=1
security=apparmor
kernel=kernel8.img # at least required if you use pi4 as homeassistant version
```

# Download and Install [The Banger Tech Utility](https://github.com/BangerTech/The-BangerTECH-Utility/tree/development) tool for easier installation of Docker-ce
```
sudo wget https://raw.githubuserconten>.com/BangerTech/The-BangerTECH-Utility/development/bangertech_utility_arm.sh
```

Change the permissions of the tool
```
sudo chmod +x bangertech_utility_arm.sh
```

exec the utility by using sh like shown in the following
It takes about 20 seconds to start
```
sh bangertech_utility_arm.sh
```

# Now the main installation of docker-ce
**It might take up to a minute. Don’t cancel at any time!**

## Very Important
**By installing e.g. Portainer or other completely unsupported software, Homeassistant might not start or will print out an critical error. By having a critical error you won't be able to restore a Backup and add an add-on!**
### Make sure to look into [here](https://github.com/HuckleberryLovesYou/Homeassistant-Supervised-on-Raspberry-Pi-5/blob/main/Homeassistant%20Supervised%20not%20working%20with%20Portainer.md) to find a workaround


Now with that out of the way, you can navigate with the arrow keys, select or deselect with the space bar and finish by hitting enter
If getting prompted if you want to reboot, hit enter to reboot
In the following fields, you should only pick “Docker+Docker-Compose” and then follow the Steps presented by the Tool

You can check if the docker-installation works by using the following command
```
sudo docker run hello-world
```
# Making your device ready to run Homeassistant
From now on everything needs to be executed as root and does **NOT** support sudo anymore
So, change into root-mode
```
sudo su -
```

Update every Package on your Device
```
apt update && apt upgrade -y
```

## Installation of dependencies
Now install all the required Dependencies by using the next two commands
You might have to restart depending on of there were a kernel update going on or not. Do, if prompted so.
1. Command
```
apt install apparmor jq wget curl udisks2 libglib2.0-bin network-manager dbus systemd-journal-remote -y
```

3. Command
```
apt install \
apparmor \
cifs-utils \
curl \
dbus \
jq \
libglib2.0-bin \
lsb-release \
network-manager \
nfs-common \
systemd-journal-remote \
systemd-resolved \
udisks2 \
wget -y
```

# Download os-agent
Today, the newest verison is 1.6.0
If you do that in the future, you may want to check for a newer version.
To do that, go to this [GitHub page](https://github.com/home-assistant/os-agent/releases) 
Scroll to the newest assets and right-click on the asset called os-agent_%Newest Version%_linux_**aarch64.deb**
Then click on **copy link address** and put it in the command below
```
wget %Your above copied link%
```
It should then look like the following example except the version-number
```
wget https://github.com/home-assistant/os-agent/releases/download/1.6.0/os-agent_1.6.0_linux_aarch64.deb
```

# Install os-agent
To do that, we use dpkg
Using Tab, the filename completes itself after a few characters
```
dpkg -i os-agent_%Your Version Number_linux_x86_64.deb
```
You can test if the installation was successful by running:
```
gdbus introspect --system --dest io.hass.os --object-path /io/hass/os
```
This should **NOT** return an error.
You might need to install libglib2.0-bin to get the gdbus command
If you get an object introspection with interface etc. OS Agent is working as expected.

# Download homeassistant-supervised
Today, the newest version is 1.6.0
By using the following command you automatically download the latest version of Homeassistant
If you still want to check, you can do this on this [Github page](https://github.com/home-assistant/supervised-installer/releases/)
```
wget -O homeassistant-supervised.deb https://github.com/home-assistant/supervised-installer/releases/latest/download/homeassistant-supervised.deb
```

# Install Homeassistant
To install execute the following command
```
apt install ./homeassistant-supervised.deb
```

During the Installation, you get asked “Select machine type”
At the day as I’m writing this, you have to select “raspberrypi4-64” or “raspberrypi4-32” depending on your OS
In the future, there might be a pi5-64bit version. If there is, then use that.

If near the end of the output you see following everything worked out fine
```
[info] Install supervisor startup scripts
[info] Install AppArmor scripts
[info] Start Home Assistant Supervised
[info] Installing the ‘ha’ cli
[info] Switching to cgroup v1
[info] Within a few minutes you will be able to reach Home Assistant at:
[info] http://<homeassistant.local>:8123 or using the IP address of your pi # remove the “>” and “<”
[info] machine: http://<Your Pi’s IP Address>:8123
```
After setup finished without errors you can go on

Restart your entire system with the following command
It’s **NOT** enough to have the created docker container restarted
```
reboot
```
# Accessing your Homeassistant WebGUI
Access your Homeassistant-WebGUI by entering the following in your browser’s address bar
Make sure to use **http** and **NOT** https
You can also use the hostname that you set, like shown in the second example
To find out your Pi's IP you can either look at your routers dashboard or use the following command and extract the IP
```
hostname - I
```
```
http://<Your Pi's IP-Adress>:8213
```
E.g.http://192.168.2.5:8213
```
http://<Your Pi’s hostname>:8213
```
E.g.http://raspberrypi:8123 # Standard hostname is raspberrypi

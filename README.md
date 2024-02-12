# Homeassistant-Supervised-on-Raspberry-Pi-5
This is a tutorial about the installation of Homeassistant Supervised on your Raspberry Pi 5


Put the following 3 lines in your config.txt-File in the boot folder of your Raspberry Pi 5
```
apparmor=1
security=apparmor
kernel=kernel8.img # at least required if you use pi4 as homeassistant version
```

# Download and Install [The Banger Tech Utility](https://github.com/BangerTech/The-BangerTECH-Utility/tree/development) tool for easier installation
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
**By installing e.g. Portainer or other unsupported software, Homeassistant might not start or will print out an critical error. By having a critical error you won't be able to restore a Backup and add an add-on!**

You can navigate with the arrow keys, select or deselect with the space bar and finish by hitting enter
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
apt install\
apparmor\
cifs-utils\
curl\
dbus\
jq\
libglib2.0-bin\
lsb-release\
network-manager\
nfs-common\
systemd-journal-remote\
systemd-resolved\
udisks2\
wget -y
```

# Install os-agent
Today, the newest verison is 1.6.0
If you do that in the future, you may want to check for a newer version. To do that, go to the following GitHub page and click on releases
https://<github.com 3>/home-assistant/os-agent/releases
Scroll down a bit and right-click on the asset of the latest version called os-agent__linux_aarch64.deb
Then click on copy link address and put it in the command below
wget

Install os-agent by exec the command below
Using Tab, the file completes itself after a few characters
dpkg -i os-agent__linux_x86_64.deb

Install the newest homeassistant-supervised version
Today, the newest version is 1.6.0
Here you automatically download the latest version
wget -O homeassistant-supervised.deb https://<github.com 3>/home-assistant/supervised-installer/releases/latest/download/homeassistant-supervised.deb

Install Homeassistant
If it fails, it’s not enough to just rm os-agent and homeassistant-supervised.deb
The only solution that I have found was to reinstall your entire os and follow the steps above again
That might not be right. So let me know if there is another way to get it to work!
During the Installation, you get asked “Select machine type”
At the day as I’m writing this, you have to select “raspberrypi4-64” or “raspberrypi4-32” if you have a 32-bit OS
In the future, there might be a pi5-64bit version. If there is, then use that one.
apt install ./homeassistant-supervised.deb

If near the end of the output you see following everything worked
[info] Install supervisor startup scripts
[info] Install AppArmor scripts
[info] Start Home Assistant Supervised
[info] Installing the ‘ha’ cli
[info] Switching to cgroup v1
[info] Within a few minutes you will be able to reach Home Assistant at:
[info] http://<homeassistant.local>:8123 or using the IP address of your pi # remove the “>” and “<”
[info] machine: http://<Your Pi’s IP Address>:8123

Restart your entire system with the following command
It’s not enough to have the created docker container restarted
reboot

Access your Homeassistant-WebGUI by entering the following in your browser’s address bar
Make sure to use http and NOT https
You can also use the hostname that you set, like in the second example
You can find out what IP is assinged to your Pi by using “ifconig” and looking at the used interface in the second line at the point “Inet”
http://:8213 # remove the “>” and “<”

E.g.http://<192.168.2.5>:8213 # remove the “>” and “<”
http://<Your Pi’s hostname>:8213

Standard hostname is raspberrypi
E.g.http://:8123 # remove the “>” and “<”

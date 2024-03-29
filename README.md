# Homeassistant-Supervised-on-Raspberry-Pi-5
This is a tutorial about the installation of Homeassistant Supervised on your Raspberry Pi 5 running Raspberry Pi OS 64bit.
### If something doesn't work, make sure to check out the Troubleshooting Section at the bottom of this Readme.

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

# Setting up your kernel and security settings
Follow the instructions given to you by the comments in each code section.
To take affect, you have to reboot the Pi after editing the file.
```
# execute the following to edit the config.txt
sudo nano /boot/firmware/config.txt # might have to install nano using: sudo apt install nano
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
#reboot now to let the edits take effect
sudo reboot
```
# Download and Install [The Banger Tech Utility](https://github.com/BangerTech/The-BangerTECH-Utility/tree/development) tool for easier installation of Docker-ce
```
sudo wget https://raw.githubusercontent.com/BangerTech/The-BangerTECH-Utility/development/bangertech_utility_arm.sh
```

Change the permissions of the tool
```
sudo chmod +x bangertech_utility_arm.sh
```

execute the utility by using sh like shown in the following
It takes about 20 seconds to start
```
sh bangertech_utility_arm.sh
```

# Now the main installation of docker-ce (community edition)
**It might take up to a minute. Don’t cancel at any time!**


**By installing e.g. Portainer or other unsupported software, Homeassistant might not start or will print out a critical error. By having a critical error you won't be able to restore a Backup and add an add-on!**
### Workaround is to be found in the Troubleshooting section


Now with that out of the way, you can navigate with the arrow keys, select or deselect with the space bar and finish by hitting enter.
If getting prompted if you want to reboot, hit enter to reboot.
In the following fields, you should only pick “Docker+Docker-Compose” and then follow the Steps presented by the Tool.

You can check if the docker-installation works by using the following command
```
sudo docker run hello-world
```
# Making your device ready to run Homeassistant
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
Now install all the required Dependencies by using the next two commands.
You might have to restart depending on of there were a kernel update going on or not. Do, if prompted so.
1. Command
```
apt install apparmor jq wget curl udisks2 libglib2.0-bin network-manager dbus systemd-journal-remote -y
```

2. Command
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
Choose the "pi4-64bit" version. #tested by myself at 15. Jan 2024 or choose "pi5-64bit" #untested

If near the end of the output you see following everything worked out fine.
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
After setup finished without errors you can go on.

Restart your entire system with the following command.
It’s **NOT** enough to have the created docker container restarted.
```
reboot
```
# Accessing your Homeassistant WebGUI
Access your Homeassistant-WebGUI by entering the following in your browser’s address bar.
Make sure to use **http** and **NOT** https.
You can also use the hostname that you set, like shown in the second example.
To find out your Pi's IP you can either look at your routers dashboard or use the following command and extract the IP.
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




# Troubleshooting
## Error while installing Homeassistant-Supervised.deb caused by wrong os-agent
If something goes wrong by the Installation of Homeassistant Installer, you can try to uninstall the OS-Agent with the following
```
sudo dpkg -r os-agent
```
After that you can dwonload the right version of the os-agent and reinstall it.
```
dpkg -i os-agent_%Your Version Number_linux_x86_64.deb
```
Now, install Homeassistant with the same command as mentioned above, because it already overwrites everthing.


## Error installing Homeassistant-Supervised.deb caused by [postinst-script](https://github.com/home-assistant/supervised-installer/blob/main/homeassistant-supervised/DEBIAN/postinst) #untested reffering to this [issue](https://github.com/HuckleberryLovesYou/Homeassistant-Supervised-on-Raspberry-Pi-5/issues/2)
Error looks like the following:
```
needrestart is being skipped since dpkg has failed
N: Download is performed unsandboxed as root as file '/root/homeassistant-supervised.deb' couldn't be accessed by user '_apt'. - pkgAcquire::Run (13: Permission denied)
E: Sub-process /usr/bin/dpkg returned an error code (1)
```
That seems to be caused by systemd.resolved not being installed but try the following first:
```
sudo systemctl restart systemd-resolved
```
If a error occured or it didn't work, execute the following command to install systemd.resolved.
**Ensure that you know what you are doing, because it seems to be possible that a name resolution error occures.**
```
sudo apt install systemd-resolved
```
And restart systemd.resolved
```
sudo systemctl restart systemd-resolved
```
It should work now.
If it doesn't work now, ensure your name resolution still works.
To test your name resolution install dnsutils
```
sudo apt-get install dnsutils
```
Now try a forward lookup with the following
```
host dns.google
```
Response should look like:
```
dns.google has address 8.8.8.8
dns.google has address 8.8.4.4
dns.google has IPv6 address 2001:4860:4860::8844
dns.google has IPv6 address 2001:4860:4860::8888
```
And now try a reverse lookup with the following
```
host 1.1.1.1
```
Your response should look like:
```
1.1.1.1.in-addr.arpa domain name pointer one.one.one.one.
```
If it still doesn't work, take a deeper look into the [this](https://github.com/HuckleberryLovesYou/Homeassistant-Supervised-on-Raspberry-Pi-5/issues/2) issue and also refering to [this](https://github.com/home-assistant/supervised-installer/issues/304#issuecomment-1644070922) issue and open an issue in this repository.


# Portainer isn't working
The well-known and almost everywhere used management service of docker containers "Portainer" isn't working with Homeassistant Supervised
### What is it caused by? 
That is caused by Portainer trying to get privileges about Homeassistant Containers.
By installing Homeassistant Supervised it creates 2 Docker containers which are cordinated by Homeassistant.
Homeassistant doesn't like it to NOT have control about the Containers.
### Symptoms
-The Containers working for Homeassistant are restarting every few seconds.
-Restarting with exit code 1
-Homeassistant WebGUI isn't reachable
# Solutions
## 1. Remove the Portainer Docker Container
```
sudo Docker container stop Portainer
sudo Docker container rm Portainer
```
## 2. Use [Dockge](https://github.com/louislam/dockge) instead
- Do everything above and execute the previous install Utility Tool by using the following command
```
sh bangertech_utility_arm.sh
```
Search the list of available software for Dockge

Select it by using the Space bar and then hit enter to select "Dockge". Now you will get prompted if you want to reboot. Hit enter to reboot.

If everything worked you can now open the WebGUI of Dockge over the port 5001
E.g. http://192.168.2.5:5001

From there on you can use this pretty much same Management Tool as your new Friend instead of Portainer

Homeassistant Supervised will still show you that you are running unsupported Software, 
but it's only a Warn and not a Critical Issue anymore

A Warn doesn't block you from adding add-ons, integrations or making backups

## 3. Use Portainer, but in a edited way
HA-Supervised seems to go trough the names of all running containers and look for Names, which are in it's "Unsupported Software" List.
To get around that you have to rename the portainer container into somthing diffrent, like mine in the following example.

First of all: Remove any old Portainer images like shown below:
```
sudo docker rmi portainer/portainer-ce
```
Now pull the image again.
```
sudo docker pull portainer/portainer-ce:latest
```
Now rename the container
```
sudo docker tag  portainer/portainer-ce:latest iamnotportainer
```
Now execute the docker run command
```
sudo docker run -d -p 9000:9000 -p 8000:8000 --name iamnotportainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data iamnotportainer
```
Now check if the container was named the right way
```
sudo docker ps
```
After that you can restart HA

If you run into any problems you mighty want to try the following commands:
```
sudo systemctl daemon-reload
```
```
sudo systemctl restart docker
```

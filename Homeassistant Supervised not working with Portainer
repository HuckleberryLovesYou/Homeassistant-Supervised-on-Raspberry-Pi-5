# Portainer isn't working
The well-known and almost everywhere used management service of docker containers "Portainer" isn't working
with Homeassistant Supervised
# What is it caused by? 
That is caused by Portainer trying to get privileges about Homeassistant Containers
By installing Homeassistant Supervised it creates 2 Docker containers which are cordinated by Homeassistant
Homeassistant doesn't like it to NOT have control about the Containers
# Symptoms
-The Containers working for Homeassistant are restarting every few seconds.
-Restarting with exit code 1
-Homeassistant WebGUI isn't reachable
# Solutions
1. Remove the Portainer Docker Container by using this command:
```
sudo Docker container stop Portainer
sudo Docker container rm Portainer
```
2. Use a different Management Service like Dockge
- Do everything above and execute the previous install Utility Tool by using the following command
```

```

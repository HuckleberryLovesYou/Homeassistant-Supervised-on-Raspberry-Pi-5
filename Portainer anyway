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

# **Building an image with Dockerhub and Github**



#### **GITHUB**

* Github Actions can be used to build the image with a continuous integration file, bitbucket also offers this service, though currently the CI files from c-omics are configured for github actions.

* Tutorials for using the bitbucket CI can be found here: https://www.atlassian.com/continuous-delivery/tutorials 

* Fork a repository to your github account: https://github.com/c-omics/centos-vnc-xfce
* Set up a Dockerhub account (see DOCKERHUB section)

#### **DOCKERHUB**

* A Dockerhub account needs to be set up in order to build an image using the c-omics continuous integration files

* The username you use will need to be added to the DOCKERHUB_USERNAME secret on the github repository

* Add an organization to dockerhub account, this will need to be added to the DOCKERHUB_ORGANIZATION secret on the github repository

* Create an access token by going to Account Settings>Security

* Copy this access token, this only appears **once**, and this will need to be added to the DOCKERHUB_TOKEN secret on the github repository.

* Once a dockerhub account has been set up (see **Dockerhub** section) add secrets to your forked repository by going to the repository page settings> Secrets

* Add the secrets under the exact names listed below, these match up with the Continuous Integration file:

`DOCKERHUB_ORGANIZATION`  

`DOCKERHUB_TOKEN`

`DOCKERHUB_USERNAME`



* To add packages and make changes to layers of your new image, modify the dockerfile

* In the continuous integration file "CI_to_DockerHub.yml", IMAGE_NAME needs to be changed to match the repo name in dockerhub

  



#### **GITHUB ACTIONS**

* In github actions, find CI_to_Dockerhub and Run workflow, when working this builds an image on dockerhub



#### **INSTALL DOCKER** 

* Follow instructions for installing docker on relevant Linux distribution: https://docs.docker.com/engine/install/



#### **RUNNING CONTAINER LOCALLY**



* Run docker daemon

`sudo dockerd`

* Running from Linux command line

`docker pull "organization_name"/"repository_name"`

`docker run -d -p 8070:5901 "organization_name"/"repository_name"`

where organization_name and repository_name are user defined when setting up a dockerhub account

To see containers that are running:

`docker ps`

To see available images

`docker images`



* The container can then be accessed via a VNC client for example at http://localhost:8070

**Note**: the container cannot be accessed via a normal browser



#### Running container on iago

* iago.container-list.sh
* 



* runAsUser: 1469249
* image: ktp1organoid/test-centos-vnc-xfce:latest




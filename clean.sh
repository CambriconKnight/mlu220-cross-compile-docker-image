#/bin/bash
set -e

VER="1.6.0"
VERSION="v${VER}"
PATH_WORK="mlu220-cross-compile"
NAME_IMAGE="ubuntu16.04_$PATH_WORK:$VERSION"
FILENAME_IMAGE="ubuntu16.04_$PATH_WORK-$VERSION.tar.gz"
#Docker container name
MY_CONTAINER="container-$PATH_WORK-$VERSION"
#Docker image
MY_IMAGE="ubuntu16.04_$PATH_WORK"

# 1.PATH_WORK
sudo rm -rvf ${PATH_WORK}

# 2.FILENAME_IMAGE
sudo rm -vf ${FILENAME_IMAGE}

# 3.rm docker container
#sudo docker stop `sudo docker ps -a | grep container-mlu220-cross-compile | awk '{print $1}'`
num_container=`sudo docker ps -a | grep ${MY_CONTAINER} | awk '{print $1}'`
if [ $num_container ]; then sudo docker stop $num_container;fi
#sudo docker rm `sudo docker ps -a | grep container-mlu220-cross-compile | awk '{print $1}'`
if [ $num_container ]; then sudo docker rm $num_container;fi

# 4.rmi docker image
#sudo docker rmi `sudo docker images | grep ubuntu16.04_mlu220-cross-compile | awk '{print $3}'`
num_images=`sudo docker images | grep ${MY_IMAGE} | awk '{print $3}'`
if [ $num_images ]; then sudo docker rmi $num_images;fi

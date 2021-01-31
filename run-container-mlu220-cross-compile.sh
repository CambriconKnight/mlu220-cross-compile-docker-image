#/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:     run-container-mlu220-cross-compile.sh
# UpdateDate:   2021/01/25
# Description:  Loading docker image.
# Example:      ./run-container-mlu220-cross-compile.sh
# Depends:      container-mlu220-cross-compile-v1.5.0
# Notes:
# -------------------------------------------------------------------------------
#Version
VERSION="v1.6.0"
PATH_WORK="mlu220-cross-compile"
if [[ $# -eq 1 ]];then
    VERSION=$1
fi
#Image name
MY_IMAGES="ubuntu16.04_$PATH_WORK:$VERSION"
#Docker container name
MY_CONTAINER="container-$PATH_WORK-$VERSION"

######Modify according to your development environment#####
#SDK path on the host
PATH_WORKSPACE_HOST="/data/ftp"
#Work path on the docker container
PATH_WORKSPACE_DOCKER="/home/ftp"
#Work2 path on the host
PATH_WORKSPACE2_HOST="$PWD"
#Work2 path on the docker container
PATH_WORKSPACE2_DOCKER="/home/cam"
#Datasets path on the host
PATH_DATASETS_HOST="/data/datasets"
#Datasets path on the docker container
PATH_DATASETS_DOCKER="/data/datasets"
#Models path on the host
PATH_MODELS_HOST="/data/models"
#Models path on the docker container
PATH_MODELS_DOCKER="/data/models"
#TFTP path on the host
PATH_TFTP_HOST="/data/tftp"
#TFTP path on the docker container
PATH_TFTP_DOCKER="/data/tftp"
#NFS path on the host
PATH_NFS_HOST="/data/nfs"
#NFS path on the docker container
PATH_NFS_DOCKER="/data/nfs"

##########################################################

num=`sudo docker ps -a|grep -w "$MY_CONTAINER$"|wc -l`

echo $num
echo $MY_CONTAINER

if [ 0 -eq $num ];then
    #sudo xhost +
    sudo docker run -e DISPLAY=unix$DISPLAY --privileged=true \
        --net=host --pid=host --ipc=host -v /tmp/.X11-unix:/tmp/.X11-unix \
        -it -v $PATH_WORKSPACE_HOST:$PATH_WORKSPACE_DOCKER \
        -it -v $PATH_WORKSPACE2_HOST:$PATH_WORKSPACE2_DOCKER \
        -it -v $PATH_DATASETS_HOST:$PATH_DATASETS_DOCKER \
        -it -v $PATH_MODELS_HOST:$PATH_MODELS_DOCKER \
        -it -v $PATH_TFTP_HOST:$PATH_TFTP_DOCKER \
        -it -v $PATH_NFS_HOST:$PATH_NFS_DOCKER \
        --name $MY_CONTAINER $MY_IMAGES /bin/bash
else
    sudo docker start $MY_CONTAINER
    sudo docker exec -ti $MY_CONTAINER /bin/bash
fi

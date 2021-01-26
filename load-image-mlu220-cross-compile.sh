#/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:     load-image-mlu220-cross-compile.sh
# UpdateDate:   2021/01/25
# Description:  Loading docker image.
# Example:      ./load-image-mlu220-cross-compile.sh
# Depends:      ubuntu16.04_mlu220-cross-compile-$VERSION.tar.gz
# Notes:        
# -------------------------------------------------------------------------------
#Version
VERSION="v1.5.0"
PATH_WORK="mlu220-cross-compile"

if [[ $# -eq 1 ]];then
    VERSION=$1
fi
#Images name
NAME_IMAGE="ubuntu16.04_$PATH_WORK"
FILENAME_IMAGE="ubuntu16.04_$PATH_WORK-$VERSION.tar.gz"

num=`sudo docker images | grep -w "$NAME_IMAGE" | grep -w "$VERSION" | wc -l`
echo $num
echo $NAME_IMAGE:$VERSION

if [ 0 -eq $num ];then
    echo "The image($NAME_IMAGE:$VERSION) is not loaded and is loading......"
    #load image
    sudo docker load < $FILENAME_IMAGE
else
    echo "The image($NAME_IMAGE:$VERSION) is already loaded!"
fi

#echo "All image information:"
#sudo docker images
echo "The image($NAME_IMAGE:$VERSION) information:"
sudo docker images | grep -e "REPOSITORY" -e $NAME_IMAGE

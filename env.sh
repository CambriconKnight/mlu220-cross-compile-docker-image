# -------------------------------------------------------------------------------
# Filename:    env.sh
# Revision:    1.2.0
# Date:        2022/11/26
# Description: Common Environment variable
# Example:
# Depends:
# Notes:
# -------------------------------------------------------------------------------
#################### version ####################
## 以下信息,根据各个版本中文件实际名词填写.
#Version
VER="1.7.610"
#Neuware SDK For MLU270(依操作系统选择)
NeuwarePackageName="cntoolkit_1.7.14-1.ubuntu16.04_amd64.deb"
# Neuware SDK For MLU220
FILENAME_MLU220_CNToolkit="cntoolkit-edge_1.7.14-1_arm64.tar.gz"
# CNCV For MLU220
FILENAME_MLU220_CNCV="cncv-edge_0.4.606-1_arm64.tar.gz"
#ARM64 交叉编译器
FILENAME_MLU220_GCC_LINARO="gcc-linaro-6.2.1-2016.11-x86_64_aarch64-linux-gnu.tgz"
#M0 交叉编译器
FILENAME_MLU220_GCC_ARM="gcc-arm-none-eabi-8-2018-q4-major.tar.gz"

#################### docker ####################
#Work
PATH_WORK="mlu220-cross-compile"
#Dockerfile(16.04/18.04/CentOS)
TYPE_DOCKERFILE="16.04"
#(Dockerfile.16.04/Dockerfile.18.04/Dockerfile.CentOS)
FILENAME_DOCKERFILE="Dockerfile.$TYPE_DOCKERFILE"
DIR_DOCKER="docker"
#Version
VERSION="v${VER}"
#Organization
ORG="kang"
#Operating system
OS="ubuntu16.04"
#Docker image
MY_IMAGE="$ORG/$OS-$PATH_WORK"
#Docker image name
NAME_IMAGE="$MY_IMAGE:$VERSION"
#FileName DockerImage
FILENAME_IMAGE="image-$OS-$PATH_WORK-$VERSION.tar.gz"
FULLNAME_IMAGE="./docker/${FILENAME_IMAGE}"
#Docker container name
MY_CONTAINER="container-$OS-$PATH_WORK-$VERSION"
#################### color ####################
#Font color
none="\033[0m"
black="\033[0;30m"
dark_gray="\033[1;30m"
blue="\033[0;34m"
light_blue="\033[1;34m"
green="\033[0;32m"
light_green="\033[1;32m"
cyan="\033[0;36m"
light_cyan="\033[1;36m"
red="\033[0;31m"
light_red="\033[1;31m"
purple="\033[0;35m"
light_purple="\033[1;35m"
brown="\033[0;33m"
yellow="\033[1;33m"
light_gray="\033[0;37m"
white="\033[1;37m"

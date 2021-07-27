#!/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:     build-mlu220-cross-compile-image.sh
# UpdateDate:   2021/07/14
# Description:  Build docker images for mlu220-cross-compile.
# Example:
#               #Build docker images: install gcc-linaro + cntoolkit-edge
#               ./build-mlu220-cross-compile-image.sh -l 1 -c 1
#               #Build docker images: install Neuware + gcc-linaro + gcc-arm
#               #./build-mlu220-cross-compile-image.sh -n 1 -l 1 -a 1
#               #Build docker images: install Neuware + gcc-linaro
#               #./build-mlu220-cross-compile-image.sh -n 1 -l 1
#               #Build docker images: install Neuware + gcc-arm
#               #./build-mlu220-cross-compile-image.sh -n 1 -a 1
# Depends:
#               neuware-mlu270-$VERSION-1_Ubuntu16.04_amd64.deb(ftp://download.cambricon.com:8821/***/neuware-mlu270-$VERSION-1_Ubuntu16.04_amd64.deb)
#               gcc-linaro-6.2.1-2016.11-x86_64_aarch64-linux-gnu.tgz(ftp://download.cambricon.com:8821/***/gcc-linaro-6.2.1-2016.11-x86_64_aarch64-linux-gnu.tgz)
#               gcc-arm-none-eabi-8-2018-q4-major.tar.gz(ftp://download.cambricon.com:8821/***/gcc-arm-none-eabi-8-2018-q4-major.tar.gz)
#               cntoolkit-edge_1.4.110-1_arm64.tar.gz(ftp://download.cambricon.com:8821/***/cntoolkit-edge_1.4.110-1_arm64.tar.gz)
# Notes:
#               1.gcc-linaro&cntoolkit-edge has been deployed to the container.
#                 gcc-linaro(/opt/work/gcc-linaro-6.2.1-2016.11-x86_64_aarch64-linux-gnu)
#                 cntoolkit-edge-1.4.110(/opt/work/neuware/pc/lib64)
#               2.These environment variables has been set in the container
#                 BIN_DIR_GCC_Linaro=/opt/work/gcc-linaro-6.2.1-2016.11-x86_64_aarch64-linux-gnu/bin
#                 BIN_DIR_GCC_ARM=/opt/work/gcc-arm-none-eabi-8-2018-q4-major/bin
#                 PATH=$BIN_DIR_GCC_Linaro:$BIN_DIR_GCC_ARM:$PATH
#                 NEUWARE_HOME=/opt/work/neuware/pc
# -------------------------------------------------------------------------------
#################### function ####################
help_info() {
    echo "
Build docker images for mlu220-cross-compile.
Usage:
    $0 <command> [arguments]
The commands are:
    -h      Help info.
    -n      FLAG_with_neuware_installed.(0/1;default:0)
    -l      FLAG_with_gcc_linaro_installed.(0/1;default:1)
    -a      FLAG_with_gcc_arm_installed.(0/1;default:0)
    -c      FLAG_with_cntoolkit_edge_installed.(0/1;default:1)
Examples:
    $0 -h
    $0 -n 1 -l 1 -a 1 -c 1
    $0 -n 1 -l 1 -a 1
    $0 -l 1 -c 1
Use '$0 -h' for more information about a command.
    "
}

# Refresh global variables
refresh_global_variables() {
    MLU_Platform=`echo ${MLU} | tr '[a-z]' '[A-Z]'`
    if [[ "${MLU_Platform}" == "MLU270" ]] || [[ "${MLU_Platform}" == "MLU220M.2" ]] ; then
        MLU_Platform="MLU270"
    else
        help_info
    fi
    VERSION="v${VER}"
    #PATH_WORK="mlu220-cross-compile"
    NAME_IMAGE="ubuntu16.04_$PATH_WORK:$VERSION"
    FILENAME_IMAGE="ubuntu16.04_$PATH_WORK-$VERSION.tar.gz"
}

#################### main ####################
# Source env
source "./env.sh"
#MLU Platform
MLU="mlu270"
#Global variables
#UPPERCASE:mlu270--->MLU270
MLU_Platform=`echo ${MLU} | tr '[a-z]' '[A-Z]'`

##FLAG_with_***_installed
FLAG_with_neuware_installed=0
FLAG_with_gcc_linaro_installed=1
FLAG_with_gcc_arm_installed=0
FLAG_with_cntoolkit_edge_installed=1
FLAG_with_neuware_installed2dockerfile="no"
FLAG_with_gcc_linaro_installed2dockerfile="yes"
FLAG_with_gcc_arm_installed2dockerfile="no"
FLAG_with_cntoolkit_edge_installed2dockerfile="yes"


if [[ $# -eq 0 ]];then
    help_info && exit 0
fi

# Get parameters
while getopts "h:m:v:n:l:a:c:" opt; do
    case $opt in
    h) help_info  &&  exit 0
        ;;
    m) MLU="$OPTARG"
        ;;
    v) VER="$OPTARG"
        ;;
    n) FLAG_with_neuware_installed=$OPTARG
        ;;
    l) FLAG_with_gcc_linaro_installed=$OPTARG
        ;;
    a) FLAG_with_gcc_arm_installed=$OPTARG
        ;;
    c) FLAG_with_cntoolkit_edge_installed=$OPTARG
        ;;
    \?)
        help_info && exit 0
        ;;
    esac
done

# Refresh global variables
refresh_global_variables

## 0.check
if [ ! -d "$PATH_WORK" ];then
    mkdir -p $PATH_WORK
else
    echo "Directory($PATH_WORK): Exists!"
fi
cd "${PATH_WORK}"

## copy the dependent packages into the directory of $PATH_WORK
##copy your neuware package into the directory
if [ $FLAG_with_neuware_installed -eq 1 ];then
    if [ -f "${NeuwarePackageName}" ];then
        echo "File(${NeuwarePackageName}): Exists!"
    else
        echo -e "${red}File(${NeuwarePackageName}): Not exist!${none}"
        echo -e "${yellow}1.Please download ${NeuwarePackageName} from FTP(ftp://download.cambricon.com:8821/***)!${none}"
        echo -e "${yellow}  For further information, please contact us.${none}"
        echo -e "${yellow}2.Copy the dependent packages(${NeuwarePackageName}) into the directory!${none}"
        echo -e "${yellow}  eg: cp -v /data/ftp/product/MLU270/$VERSION/Ubuntu16.04/CNToolkit/${NeuwarePackageName} ./${PATH_WORK}${none}"
        #Manual copy
        #cp -v /data/ftp/product/MLU270/v1.7.0/Ubuntu16.04/CNToolkit/cntoolkit_1.7.3-2.ubuntu16.04_amd64.deb ./mlu220-cross-compile
        exit -1
    fi
    FLAG_with_neuware_installed2dockerfile="yes"
else
    FLAG_with_neuware_installed2dockerfile="no"
fi

### FILENAME_MLU220_GCC_LINARO
if [ $FLAG_with_gcc_linaro_installed -eq 1 ];then
    if [ -f "${FILENAME_MLU220_GCC_LINARO}" ];then
        echo "File(${FILENAME_MLU220_GCC_LINARO}): Exists!"
    else
        echo -e "${red}File(${FILENAME_MLU220_GCC_LINARO}): Not exist!${none}"
        echo -e "${yellow}1.Please download ${FILENAME_MLU220_GCC_LINARO} from FTP(ftp://download.cambricon.com:8821/***)!${none}"
        echo -e "${yellow}  For further information, please contact us.${none}"
        echo -e "${yellow}2.Copy the dependent packages(${FILENAME_MLU220_GCC_LINARO}) into the directory!${none}"
        echo -e "${yellow}  eg: cp -v /data/ftp/product/MLU220/cross-compile-toolchain/aarch64/${FILENAME_MLU220_GCC_LINARO} ./${PATH_WORK}${none}"
        #Manual copy
        #cp -v /data/ftp/mlu220/cross-compile-toolchain/aarch64/gcc-linaro-6.2.1-2016.11-x86_64_aarch64-linux-gnu.tgz ./mlu220-cross-compile
        exit -1
    fi
    FLAG_with_gcc_linaro_installed2dockerfile="yes"
else
    FLAG_with_gcc_linaro_installed2dockerfile="no"
fi

### FILENAME_MLU220_GCC_ARM
if [ $FLAG_with_gcc_arm_installed -eq 1 ];then
    if [ -f "${FILENAME_MLU220_GCC_ARM}" ];then
        echo "File(${FILENAME_MLU220_GCC_ARM}): Exists!"
    else
        echo -e "${red}File(${FILENAME_MLU220_GCC_ARM}): Not exist!${none}"
        echo -e "${yellow}1.Please download ${FILENAME_MLU220_GCC_ARM} from FTP(ftp://download.cambricon.com:8821/***)!${none}"
        echo -e "${yellow}  For further information, please contact us.${none}"
        echo -e "${yellow}2.Copy the dependent packages(${FILENAME_MLU220_GCC_ARM}) into the directory!${none}"
        echo -e "${yellow}  eg: cp -v /data/ftp/product/MLU220/cross-compile-toolchain/m0/${FILENAME_MLU220_GCC_ARM} ./${PATH_WORK}${none}"
        #Manual copy
        #cp -v /data/ftp/product/MLU220/cross-compile-toolchain/m0/gcc-arm-none-eabi-8-2018-q4-major.tar.gz ./mlu220-cross-compile
        exit -1
    fi
    FLAG_with_gcc_arm_installed2dockerfile="yes"
else
    FLAG_with_gcc_arm_installed2dockerfile="no"
fi

### FILENAME_MLU220_CNToolkit
if [ $FLAG_with_cntoolkit_edge_installed -eq 1 ];then
    if [ -f "${FILENAME_MLU220_CNToolkit}" ];then
        echo "File(${FILENAME_MLU220_CNToolkit}): Exists!"
    else
        echo -e "${red}File(${FILENAME_MLU220_CNToolkit}): Not exist!${none}"
        echo -e "${yellow}1.Please download ${FILENAME_MLU220_CNToolkit} from FTP(ftp://download.cambricon.com:8821/***)!${none}"
        echo -e "${yellow}  For further information, please contact us.${none}"
        echo -e "${yellow}2.Copy the dependent packages(${FILENAME_MLU220_CNToolkit}) into the directory!${none}"
        echo -e "${yellow}  eg: cp -v /data/ftp/product/MLU220/$VER/mlu220edge/${FILENAME_MLU220_CNToolkit} ./${PATH_WORK}${none}"
        #Manual copy
        #cp -v /data/ftp/product/MLU220/1.7.0/mlu220edge/cntoolkit-edge_1.4.110-1_arm64.tar.gz ./mlu220-cross-compile
        exit -1
    fi
    FLAG_with_cntoolkit_edge_installed2dockerfile="yes"
else
    FLAG_with_cntoolkit_edge_installed2dockerfile="no"
fi

#1.build image
echo "====================== build image ======================"
sudo docker build -f ./$FILENAME_DOCKERFILE \
    --build-arg neuware_package=${NeuwarePackageName} \
    --build-arg mlu_platform=${MLU_Platform} \
    --build-arg mlu220_cntoolkit_edge=${FILENAME_MLU220_CNToolkit} \
    --build-arg mlu220_gcc_linaro=${FILENAME_MLU220_GCC_LINARO} \
    --build-arg mlu220_gcc_arm=${FILENAME_MLU220_GCC_ARM} \
    --build-arg with_neuware_installed=${FLAG_with_neuware_installed2dockerfile} \
    --build-arg with_gcc_linaro_installed=${FLAG_with_gcc_linaro_installed2dockerfile} \
    --build-arg with_gcc_arm_installed=${FLAG_with_gcc_arm_installed2dockerfile} \
    --build-arg with_cntoolkit_edge_installed=${FLAG_with_cntoolkit_edge_installed2dockerfile} \
    -t $NAME_IMAGE .

#2.save image
echo "====================== save image ======================"
sudo docker save -o $FILENAME_IMAGE $NAME_IMAGE
sync && sync
sudo chmod 664 $FILENAME_IMAGE
mv $FILENAME_IMAGE ../${DIR_DOCKER}/
cd ../
ls -la ./${DIR_DOCKER}/$FILENAME_IMAGE

#!/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:     build-ffmpeg-mlu220edge.sh
# UpdateDate:   2021/11/01
# Description:  Build packages for ffmpeg-mlu220edge.
# Example:      ./build-ffmpeg-mlu220edge.sh
# Depends:      FFMpeg 4.1.6(http://ffmpeg.org/releases/ffmpeg-4.1.6.tar.gz)
# Notes:
#               1.gcc-linaro&cntoolkit-edge has been deployed to the container.
#                 gcc-linaro(/opt/cambricon/gcc-linaro-6.2.1-2016.11-x86_64_aarch64-linux-gnu)
#               2.These environment variables has been set in the container
#                 BIN_DIR_GCC_Linaro=/opt/cambricon/gcc-linaro-6.2.1-2016.11-x86_64_aarch64-linux-gnu/bin
#                 BIN_DIR_GCC_ARM=/opt/cambricon/gcc-arm-none-eabi-8-2018-q4-major/bin
#                 PATH=$BIN_DIR_GCC_Linaro:$BIN_DIR_GCC_ARM:$PATH
#                 NEUWARE_HOME=/opt/cambricon/neuware/pc
# -------------------------------------------------------------------------------
#################### function ####################
# Help
help_info() {
    echo "
Build packages for ffmpeg-mlu220edge.
Usage:
    $0 <command> [arguments]
The commands are:
    -h      Help info.
Examples:
    $0 -h
    $0
Use '$0 -h' for more information about a command.
    "
}

# Refresh global variables
refresh_global_variables() {
    echo "==============="
}

# wget_file_form_http $filename $addrdownload
wget_file_form_http() {
    if [ -f "${1}" ];then
        echo -e "${green}====================================${none}"
        echo -e "${green}(${1}): Exists!${none}"
        ls -la ${1}
    else
        # wget
        echo -e "${green}Download File(${1}) ...... ${none}"
        wget -O ${1} -c ${2}
        if [ -f "${1}" ];then
            echo -e "${green}====================================${none}"
            echo -e "${green}Download File(${1}): Completed!${none}"
            ls -la ${1}
        else
            echo -e "${red}Download(${1}) failed, please download manually!${none}"
            echo -e "${yellow}eg:wget -O ${1} -c ${2} ${none}"
            exit -1
        fi
    fi
}

# Build ffmpeg for mlu220edge
# Usage: build_ffmpeg_edge $DirFullNameWork $PackageDirNameFFMpeg
# Example: build_ffmpeg_edge "${PWD}/ffmpeg_mlu220edge" "ffmpeg-4.1.6" "./toolchain-edge.cmake"
build_ffmpeg_edge() {
    echo -e "${green}# Build ffmpeg for mlu220edge.....${none}"
    pushd ${1}/${2}
    ./configure --prefix=${1}/ffmpeg_mlu220edge \
    --cross-prefix=$BIN_DIR_GCC_Linaro/aarch64-linux-gnu- \
    --enable-cross-compile --arch=arm64 --target-os=linux \
    --enable-shared --disable-static \
    --enable-gpl --enable-nonfree --disable-debug \
    --disable-doc --enable-gpl  --enable-pic
    make clean
    make -j4 install
    popd
    echo -e "${green}  Completed!${none}"
}

# Package ffmpeg for mlu220edge
# Usage: $DirFullNameForInstall $DirNameWork $PackageNameMLU220Edge
# Example: package_ffmpeg_mlu220edge "${PWD}/ffmpeg_mlu220edge/ffmpeg_mlu220edge" "ffmpeg_mlu220edge" "ffmpeg_mlu220edge.tar.gz"
package_ffmpeg_mlu220edge() {
    echo -e "${green}# Package ffmpeg for mlu220edge.....${none}"

    # 生成环境变量配置文件
    TimePackage=$(date +%Y%m%d%H%M%S) # eg:20210131230402.403666251
    echo '#!/bin/bash' > ${1}/env.sh
    echo "#TimePackage:${TimePackage}" >> ${1}/env.sh
    echo 'export LD_LIBRARY_PATH="$PWD/lib:$LD_LIBRARY_PATH"' >> ${1}/env.sh
    # 打包部署文件
    pushd ${1}/../
    tar -zcvf ${3} ./$2
    mv ${3} ../
    popd

    echo -e "${green}  Completed!${none}"
}

#################### main ####################
DirNameWork="ffmpeg_mlu220edge"
PackageNameMLU220Edge="${DirNameWork}.tar.gz"
DirFullNameWork="${PWD}/${DirNameWork}"
DirFullNameForInstall="${PWD}/${DirNameWork}/${DirNameWork}"
#FFMpeg
PackageDirNameFFMpeg="ffmpeg-4.1.6"
PackageNameFFMpeg="$PackageDirNameFFMpeg.tar.gz"
#AddrDownloadFFMpeg="http://ffmpeg.org/releases/ffmpeg-4.1.6.tar.gz"
AddrDownloadFFMpeg="http://video.cambricon.com/models/edge/${PackageNameFFMpeg}"

#Font color
none="\033[0m"
green="\033[0;32m"
red="\033[0;31m"
yellow="\033[1;33m"

#if [[ $# -eq 0 ]];then
#    help_info && exit 0
#fi

# Get parameters
while getopts "h:m:v:n:l:a:" opt; do
    case $opt in
    h) help_info  &&  exit 0
        ;;
    \?)
        help_info && exit 0
        ;;
    esac
done

# Refresh global variables
refresh_global_variables

# Check $DirNameWork
if [ ! -d "$DirNameWork" ];then
    mkdir -p $DirNameWork
else
    echo "Directory($DirNameWork): Exists!"
fi
pushd "${DirNameWork}"
####################
# 1.Download FFMpeg: wget -O ${PackageNameFFMpeg} -c ${AddrDownloadFFMpeg}
wget_file_form_http ${PackageNameFFMpeg} ${AddrDownloadFFMpeg}

####################
# 2.Extracting Depends
if [ ! -d "${PackageDirNameFFMpeg}" ];then tar -zxvf ${PackageNameFFMpeg};fi

####################
# 3.Build ffmpeg for mlu220edge
build_ffmpeg_edge $DirFullNameWork $PackageDirNameFFMpeg

####################
# 4.Package ffmpeg for mlu220edge
# 打包ffmpeg_mlu220edge相关部署文件
package_ffmpeg_mlu220edge $DirFullNameForInstall $DirNameWork $PackageNameMLU220Edge
popd
echo -e "${green}========================================"
ls -la ${PWD}/$PackageNameMLU220Edge
echo -e "========================================${none}"
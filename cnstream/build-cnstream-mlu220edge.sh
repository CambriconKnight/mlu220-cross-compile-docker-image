#!/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:     build-cnstream-mlu220edge.sh
# UpdateDate:   2021/01/31
# Description:  Build packages for cnstream-mlu220edge.
#               The scripts automate these processes:
#               1.Download Depends(CNStream\Gflags\Glogs\FFMpeg\OpenCV)
#               2.Extracting Depends(CNStream\Gflags\Glogs\FFMpeg\OpenCV)
#               3.Build Depends for cnstream-mlu220edge(CNStream\Gflags\Glogs\FFMpeg\OpenCV)
#               4.Build cnstream for mlu220edge
#               5.Package cnstream for mlu220edge
# Example:      ./build-cnstream-mlu220edge.sh
# Depends:
#               1.CNStream(https://github.com/Cambricon/cnstream.git)
#               2.Gflags 2.2.2(https://github.com/gflags/gflags/archive/v2.2.2.tar.gz)
#               3.Glogs 0.4.0(https://github.com/google/glog/archive/v0.4.0.tar.gz)
#               4.FFMpeg 4.1.6(http://ffmpeg.org/releases/ffmpeg-4.1.6.tar.gz)
#               5.OpenCV 3.4.6(https://github.com/opencv/opencv/archive/3.4.6.tar.gz)
#               6.gcc-linaro(ftp://download.cambricon.com:8821/**/gcc-linaro-6.2.1-2016.11-x86_64_aarch64-linux-gnu.tgz)
#               7.cntoolkit-edge-1.4.110(ftp://download.cambricon.com:8821/**/cntoolkit-edge_1.4.110-1_arm64.tar.gz)
# Notes:
#               1.gcc-linaro&cntoolkit-edge has been deployed to the container.
#                 gcc-linaro(/opt/cambricon/gcc-linaro-6.2.1-2016.11-x86_64_aarch64-linux-gnu)
#                 cntoolkit-edge-1.4.110(/opt/cambricon/neuware/pc/lib64)
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
Build packages for cnstream-mlu220edge.
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

# Build gflags for mlu220edge
# Usage: build_gflags_edge $DirFullNameWork $PackageDirNameGflags $FullNameCMake
# Example: build_gflags_edge "/opt/cambricon/cnstream_mlu220edge" "gflags-2.2.2" "/opt/cambricon/toolchain-edge.cmake"
build_gflags_edge() {
    echo -e "${green}# Build gflags for mlu220edge.....${none}"
    # 静态编译 gflags 源码脚本
    # $gflags_source gflags源码位置
    mkdir -p ${1}/${2}/build
    pushd ${1}/${2}/build
    #install_path 定义安装路径
    # CMAKE_TOOLCHAIN_FILE 指定上面定义的toolchain文件的位置
    # BUILD_SHARED_LIBS=off 编译动态库
    # BUILD_STATIC_LIBS=on 不编译静态库
    # BUILD_gflags_LIB 编译多线程库
    # INSTALL_STATIC_LIBS=on 不安装静态库
    # INSTALL_SHARED_LIBS=off 安装动态库
    # REGISTER_INSTALL_PREFIX=off 不写注册表
    cmake .. -DCMAKE_TOOLCHAIN_FILE=${3} \
        -DCMAKE_INSTALL_PREFIX=${1}/cnstream \
        -DBUILD_SHARED_LIBS=on \
        -DBUILD_STATIC_LIBS=off \
        -DBUILD_gflags_LIB=on \
        -DINSTALL_STATIC_LIBS=off \
        -DINSTALL_SHARED_LIBS=on \
        -DREGISTER_INSTALL_PREFIX=off
    make clean
    make -j4 install
    popd
    echo -e "${green}  Completed!${none}"
}

# Build glog for mlu220edge
# Usage: build_glog_edge $DirFullNameWork $PackageDirNameGlogs $FullNameCMake
# Example: build_glog_edge "/opt/cambricon/cnstream_mlu220edge" "glog-0.4.0" "/opt/cambricon/toolchain-edge.cmake"
build_glog_edge() {
    echo -e "${green}# Build glog for mlu220edge.....${none}"
    mkdir -p ${1}/${2}/build
    pushd ${1}/${2}/build
    cmake .. -DCMAKE_TOOLCHAIN_FILE=${3} \
        -DCMAKE_INSTALL_PREFIX=${1}/cnstream  -DBUILD_SHARED_LIBS=on
    make clean
    make -j4 install
    popd
    echo -e "${green}  Completed!${none}"
}

# Build ffmpeg for mlu220edge
# Usage: build_ffmpeg_edge $DirFullNameWork $PackageDirNameFFMpeg $FullNameCMake
# Example: build_ffmpeg_edge "/opt/cambricon/cnstream_mlu220edge" "ffmpeg-4.1.6" "/opt/cambricon/toolchain-edge.cmake"
build_ffmpeg_edge() {
    echo -e "${green}# Build ffmpeg for mlu220edge.....${none}"
    pushd ${1}/${2}
    ./configure --prefix=${1}/cnstream \
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

# Build opencv for mlu220edge
# Usage: build_opencv_edge $DirFullNameWork $PackageDirNameOpenCV $FullNameCMake
# Example: build_opencv_edge "/opt/cambricon/cnstream_mlu220edge" "opencv-3.4.6" "/opt/cambricon/toolchain-edge.cmake"
build_opencv_edge() {
    echo -e "${green}# Build opencv for mlu220edge.....${none}"
    mkdir -p ${1}/${2}/build
    pushd ${1}/${2}/build
    cmake .. -DCMAKE_TOOLCHAIN_FILE=${3} \
            -DCMAKE_INSTALL_PREFIX=${1}/cnstream  \
            -DWITH_CUDA=OFF -DWITH_OPENCL=OFF \
            -DBUILD_DOCS=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_TESTS=OFF \
            -DBUILD_WITH_DEBUG_INFO=OFF -DBUILD_opencv_apps=off -DWITH_V4L=OFF -DWITH_GTK=OFF \
            -DCMAKE_VERBOSE=on -DWITH_LIBV4L=OFF -DWITH_1394=OFF -DWITH_TIFF=OFF -DWITH_OPENEXR=OFF \
            -DBUILD_OPENEXR=OFF -DBUILD_opencv_ocl=off -DWITH_GSTREAMER=OFF -DWITH_FFMPEG=OFF \
            -DWITH_EIGEN=OFF -DWITH_GIGEAPI=OFF -DWITH_JASPER=OFF -DWITH_CUFFT=OFF \
            -DBUILD_opencv_contrib=off -DBUILD_opencv_ml=OFF -DBUILD_opencv_objdetect=OFF \
            -DBUILD_opencv_nonfree=off -DBUILD_opencv_gpu=OFF

    make clean
    make -j4 install
    popd
    echo -e "${green}  Completed!${none}"
}

# Build cnstream for mlu220edge
# Usage: build_cnstream_edge $DirFullNameWork $DirNameCNStream $FullNameCMake
# Example: build_cnstream_edge "/opt/cambricon/cnstream_mlu220edge" "cnstream" "/opt/cambricon/toolchain-edge.cmake"
build_cnstream_edge() {
    echo -e "${green}# Build cnstream for mlu220edge.....${none}"
    mkdir -p ${1}/${2}/build
    pushd ${1}/${2}/build
    cmake .. -DCMAKE_TOOLCHAIN_FILE=${3} -DMLU=MLU220_SOC -Dbuild_display=OFF
    make -j4
    popd
    echo -e "${green}  Completed!${none}"
}

# Package cnstream for mlu220edge
# Usage: package_cnstream_mlu220edge $DirFullNameCNStream $DirFullNameForInstall
# Example: package_cnstream_mlu220edge "/opt/cambricon/cnstream_mlu220edge/cnstream" "/opt/cambricon/cnstream_mlu220edge/cnstream_mlu220edge"
package_cnstream_mlu220edge() {
    echo -e "${green}# Package cnstream for mlu220edge.....${none}"

    mkdir -p ${2}/lib
    #1.拷贝 neuware4edge 动态库到打包目录
    cp -rvf $NEUWARE_HOME/lib64/* ${2}/lib/
    #2.拷贝 cnstream4edge 动态库和第三方库到打包目录
    cp -rvf ${1}/lib/* ${2}/lib/
    #3.拷贝 easydk4edge 动态库和第三方库到打包目录
    cp -rvf ${1}/build/easydk/lib* ${2}/lib/
    cp -rvf ${1}/build/easydk/infer_server/lib* ${2}/lib/
    #4.拷贝可执行文件以及需要的脚本，模型和数据源等等到打包目录
    cp -rvf ${1}/data ${2}/
    cp -rvf ${1}/samples ${2}/
    #5.清理无用文件/目录,如：针对270的测试实例以及源码等文件
    rm -rvf ${2}/samples/example
    rm -rvf ${2}/samples/cmake
    rm -vf ${2}/samples/CMakeLists.txt
    rm -vf ${2}/samples/demo/*.cpp
    rm -vf ${2}/samples/demo/CMakeLists.txt
    rm -vf ${2}/samples/demo/detection_config.json
    rm -vf ${2}/samples/demo/run.sh
    rm -rvf ${2}/samples/demo/classification/mlu270
    rm -rvf ${2}/samples/demo/detection/mlu270
    rm -rvf ${2}/samples/demo/multi_pipelines
    rm -rvf ${2}/samples/demo/postprocess
    rm -rvf ${2}/samples/demo/secondary
    rm -rvf ${2}/samples/demo/multi_process
    rm -rvf ${2}/samples/demo/preprocess
    rm -rvf ${2}/samples/demo/track/mlu270
    rm -rvf ${2}/samples/demo/encode
    rm -rvf ${2}/samples/demo/multi_sources
    rm -rvf ${2}/samples/demo/rtsp
    rm -rvf ${2}/samples/demo/obj_filter
    #6.生成环境变量配置文件
    TimePackage=$(date +%Y%m%d%H%M%S) # eg:20210131230402.403666251
    echo '#!/bin/bash' > ${2}/env.sh
    echo "#TimePackage:${TimePackage}" >> ${2}/env.sh
    echo 'export LD_LIBRARY_PATH="$PWD/lib:$LD_LIBRARY_PATH"' >> ${2}/env.sh
    # 打包部署文件
    pushd ${2}/../
    tar -zcvf $PackageNameCNStreamMLU220Edge ./$DirNameWork
    mv $PackageNameCNStreamMLU220Edge ../
    popd

    echo -e "${green}  Completed!${none}"
}

#################### main ####################
DirNameWork="cnstream_mlu220edge"
PackageNameCNStreamMLU220Edge="${DirNameWork}.tar.gz"
DirFullNameWork="${PWD}/${DirNameWork}"
DirFullNameForInstall="${PWD}/${DirNameWork}/${DirNameWork}"
FullNameCMake="${PWD}/toolchain-edge.cmake"
DirNameCNStream="cnstream"
DirFullNameCNStream="$DirFullNameWork/$DirNameCNStream"
AddrGitCNStream="https://github.com/Cambricon/cnstream.git"
#AddrGitCNStream="https://gitee.com/SolutionSDK/CNStream.git"
#AddrDownloadCNStream="https://github.com/Cambricon/cnstream.git"
#Gflags
PackageDirNameGflags="gflags-2.2.2"
PackageNameGflags="$PackageDirNameGflags.tar.gz"
AddrDownloadGflags="https://github.com/gflags/gflags/archive/v2.2.2.tar.gz"
#Glogs
PackageDirNameGlogs="glog-0.4.0"
PackageNameGlogs="$PackageDirNameGlogs.tar.gz"
AddrDownloadGlogs="https://github.com/google/glog/archive/v0.4.0.tar.gz"
#FFMpeg
PackageDirNameFFMpeg="ffmpeg-4.1.6"
PackageNameFFMpeg="$PackageDirNameFFMpeg.tar.gz"
AddrDownloadFFMpeg="http://ffmpeg.org/releases/ffmpeg-4.1.6.tar.gz"
#OpenCV
PackageDirNameOpenCV="opencv-3.4.6"
PackageNameOpenCV="$PackageDirNameOpenCV.tar.gz"
AddrDownloadOpenCV="https://github.com/opencv/opencv/archive/3.4.6.tar.gz"

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
# 1.Download Depends
# Download CNStream
if [ ! -d "${DirNameCNStream}" ];then
    git clone ${AddrGitCNStream}
    pushd cnstream
    git submodule update --init
    # del .git
    find . -name ".git" | xargs rm -Rf
    popd
else
    echo "Directory(${DirNameCNStream}): Exists!"
fi

# Download Gflags: wget -O ${PackageNameGflags} -c ${AddrDownloadGflags}
wget_file_form_http ${PackageNameGflags} ${AddrDownloadGflags}
# Download Glogs: wget -O ${PackageNameGlogs} -c ${AddrDownloadGlogs}
wget_file_form_http ${PackageNameGlogs} ${AddrDownloadGlogs}
# Download FFMpeg: wget -O ${PackageNameFFMpeg} -c ${AddrDownloadFFMpeg}
wget_file_form_http ${PackageNameFFMpeg} ${AddrDownloadFFMpeg}
# Download OpenCV: wget -O ${PackageNameOpenCV} -c ${AddrDownloadOpenCV}
wget_file_form_http ${PackageNameOpenCV} ${AddrDownloadOpenCV}
# Download Gcc-linaro(gcc-linaro-6.2.1-2016.11-x86_64_aarch64-linux-gnu.tgz)
#Gcc-linaro has been deployed to the container(/opt/cambricon/gcc-linaro-6.2.1-2016.11-x86_64_aarch64-linux-gnu)

####################
# 2.Extracting Depends
if [ ! -d "${PackageDirNameGflags}" ];then tar -zxvf ${PackageNameGflags};fi
if [ ! -d "${PackageDirNameGlogs}" ];then tar -zxvf ${PackageNameGlogs};fi
if [ ! -d "${PackageDirNameFFMpeg}" ];then tar -zxvf ${PackageNameFFMpeg};fi
if [ ! -d "${PackageDirNameOpenCV}" ];then tar -zxvf ${PackageNameOpenCV};fi

####################
# 3.Build Depends for cnstream-mlu220edge
# 编译第三方库，编译结果路径为cnstream
build_gflags_edge $DirFullNameWork $PackageDirNameGflags $FullNameCMake
build_glog_edge $DirFullNameWork $PackageDirNameGlogs $FullNameCMake
build_ffmpeg_edge $DirFullNameWork $PackageDirNameFFMpeg $FullNameCMake
build_opencv_edge $DirFullNameWork $PackageDirNameOpenCV $FullNameCMake
# 编译成功，可以在cnstream下看到 bin|include|lib|share 等文件夹
ls -la $DirFullNameWork/$DirNameCNStream | grep -E "bin|include|lib|share"

####################
# 4.Build cnstream for mlu220edge
build_cnstream_edge $DirFullNameWork $DirNameCNStream $FullNameCMake

####################
# 5.Package cnstream for mlu220edge
# 打包cnstream_mlu220edge相关部署文件
package_cnstream_mlu220edge $DirFullNameCNStream $DirFullNameForInstall
popd
echo -e "${green}========================================"
ls -la ${PWD}/$PackageNameCNStreamMLU220Edge
echo -e "========================================${none}"
#!/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:     build-restful-mlu220edge.sh
# UpdateDate:   2021/11/8
# Description:  Build packages for restful-mlu220edge.
#               The scripts automate these processes:
#               1.Download restfulserved
#               2.Build restfulserved for mlu220edge
#               3.Package restfulserved for mlu220edge
# Example:      ./build-restful-mlu220edge.sh
# Depends:      restfulserved(https://gitee.com/cambriconknight/restfulserved)
# Notes:
#               1.gcc-linaro&cntoolkit-edge has been deployed to the container.
#                 gcc-linaro(/opt/work/gcc-linaro-6.2.1-2016.11-x86_64_aarch64-linux-gnu)
#               2.These environment variables has been set in the container
#                 BIN_DIR_WORK=/opt/work
#                 BIN_DIR_GCC_Linaro=/opt/work/gcc-linaro-6.2.1-2016.11-x86_64_aarch64-linux-gnu/bin
#                 BIN_DIR_GCC_ARM=/opt/work/gcc-arm-none-eabi-8-2018-q4-major/bin
#                 PATH=$BIN_DIR_GCC_Linaro:$BIN_DIR_GCC_ARM:$PATH
#                 NEUWARE_HOME=/opt/work/neuware/pc
# -------------------------------------------------------------------------------
#################### function ####################
# Build restful for mlu220edge
# Usage: build_restful_edge $DirFullNameWork $DirNameRESTFUL $FullNameCMake
# Example:
# $DirFullNameWork "/home/share/3rdparty/restful/restful_mlu220edge"
# $DirNameRESTFUL "restfulserved"
# $FullNameCMake "/home/share/3rdparty/restful/restful_mlu220edge/restfulserved/cmake/ToolChainEdge.cmake"
build_restful_edge() {
    echo -e "${green}# Build restful for mlu220edge.....${none}"
    mkdir -p ${1}/${2}/build
    pushd ${1}/${2}/build
    cmake .. -DCMAKE_TOOLCHAIN_FILE=${3} \
            -DCMAKE_INSTALL_PREFIX=./install

    make -j4 && make install
    popd
    echo -e "${green}  Completed!${none}"
}

# Package restful for mlu220edge
# Usage: package_restful_mlu220edge $DirFullNameRESTFUL $DirFullNameForInstall
# Example:
# $DirFullNameRESTFUL "/home/share/3rdparty/restful/restful_mlu220edge/restfulserved" \
# $DirFullNameForInstall "/home/share/3rdparty/restful/restful_mlu220edge/restful_mlu220edge"
package_restful_mlu220edge() {
    echo -e "${green}# Package restful for mlu220edge.....${none}"
    # 生成环境变量配置文件
    mkdir -p $2
    TimePackage=$(date +%Y%m%d%H%M%S) # eg:20211131230402.403666251
    echo '#!/bin/bash' > ${2}/env.sh
    echo "#TimePackage:${TimePackage}" >> ${2}/env.sh
    echo 'export LD_LIBRARY_PATH="$PWD/lib:$LD_LIBRARY_PATH"' >> ${2}/env.sh
    #1.拷贝 make install后的文件到打包目录
    cp -rvf $1/build/install/* $2
    #2.打包部署文件
    pushd ${DirFullNameWork}
    tar -zcvf ${PackageNameRESTFULMLU220Edge} ./${DirNameWork}
    mv ${PackageNameRESTFULMLU220Edge} ../
    popd

    echo -e "${green}  Completed!${none}"
}

#################### main ####################
DirNameWork="restful_mlu220edge"
PackageNameRESTFULMLU220Edge="${DirNameWork}.tar.gz"
DirFullNameWork="${PWD}/${DirNameWork}"
DirFullNameForInstall="${PWD}/${DirNameWork}/${DirNameWork}"
DirNameRESTFUL="restfulserved"
DirFullNameRESTFUL="$DirFullNameWork/$DirNameRESTFUL"
FullNameCMake="${DirFullNameRESTFUL}/cmake/ToolChainEdge.cmake"

AddrGitRESTFUL="https://github.com/CambriconKnight/restfulserved"
#AddrGitRESTFUL="https://gitee.com/cambriconknight/restfulserved"

#Font color
none="\033[0m"
green="\033[0;32m"
red="\033[0;31m"
yellow="\033[1;33m"

# Check $DirNameWork
if [ ! -d "$DirNameWork" ];then
    mkdir -p $DirNameWork
else
    echo "Directory($DirNameWork): Exists!"
fi
pushd "${DirNameWork}"

####################
# 1.Download Depends
# Download RESTFUL
if [ ! -d "${DirNameRESTFUL}" ];then
    git clone ${AddrGitRESTFUL}
else
    echo "Directory(${DirNameRESTFUL}): Exists!"
fi

####################
# 2.Build restfulserved for mlu220edge
build_restful_edge $DirFullNameWork $DirNameRESTFUL $FullNameCMake
# 编译成功，可以在restful下看到 bin|include|lib|share 等文件夹
ls -la $DirFullNameRESTFUL/build/install | grep -E "bin|include|lib"

####################
# 3.Package restful for mlu220edge
# 打包restful_mlu220edge相关部署文件
package_restful_mlu220edge $DirFullNameRESTFUL $DirFullNameForInstall
popd
echo -e "${green}========================================"
ls -la ${PWD}/$PackageNameRESTFULMLU220Edge
echo -e "========================================${none}"
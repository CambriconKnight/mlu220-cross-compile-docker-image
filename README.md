# mlu220-cross-compile Docker Images #

Build docker images for mlu220-cross-compile.
Installed software:
- curl
- git
- wget
- vim
- cmake
- make
- opencv(x86)
- glog(x86)
- ssh
- tree
- minicom
- tftpd
- nfs
- net-tools
- cndev
- cndrv
- cnrt
- cncodec
- gcc-linaro
- gcc-arm-none-eabi
- cntoolkit-edge

# Directory tree

```bash
.
├── build-mlu220-cross-compile-image.sh
├── clean.sh
├── Dockerfile.16.04
├── load-image-mlu220-cross-compile.sh
├── README.md
└── run-container-mlu220-cross-compile.sh
```

# Clone
```bash
git clone https://github.com/CambriconKnight/mlu220-cross-compile-docker-image.git
```

# Build
```bash
#编译完成后，会在本地生成一个docker镜像。
#编译Docker镜像：安装 gcc-linaro + cntoolkit-edge
./build-mlu220-cross-compile-image.sh -l 1 -c 1
#编译Docker镜像：安装 Neuware + gcc-linaro + gcc-arm
#./build-mlu220-cross-compile-image.sh -n 1 -l 1 -a 1
#编译Docker镜像：安装 Neuware + gcc-linaro
#./build-mlu220-cross-compile-image.sh -n 1 -l 1
#编译Docker镜像：安装 Neuware + gcc-arm
#./build-mlu220-cross-compile-image.sh -n 1 -a 1
```
编译后会在当前目录下生存一个镜像文件。$VERSION版本以实际为准
```bash
......
====================== save image ======================
-rw------- 1 root root 2887489536 1月  26 11:23 ubuntu16.04_mlu220-cross-compile-$VERSION.tar.gz
```

# Clean
```bash
#清理本目录下已生成的临时目录、已生存的Docker镜像文件、已加载的Docker容器、已加载的Docker镜像
./clean.sh
```

# Load
```bash
#加载Docker镜像
./load-image-mlu220-cross-compile.sh
```

# Run
```bash
#启动Docker容器
./run-container-mlu220-cross-compile.sh
```

# Test
```bash
#进入默认目录
cd /opt/cambricon
#source
echo $PATH
source /etc/profile
echo $PATH
#执⾏以下命令，确认aarch64-linux-gnu-gcc版本信息：
aarch64-linux-gnu-gcc -v
#执⾏以下命令，确认arm-none-eabi-gcc版本信息：
arm-none-eabi-gcc -v
```

# 源码包编译
## 完整编译
```bash
#source
echo $PATH
source /etc/profile
echo $PATH
#进入默认目录
cd /opt/cambricon
mkdir opensrc
#拷贝源码包（非必要）。拷贝在driver 包的release/neuware/opensrc ⽬录下有opensrc.tar.gz 压缩⽂件
#cp /home/ftp/mlu220/IVA-1.6.106/mlu220edge/release/neuware/opensrc/opensrc.tar.gz ./
#(直接)解压源码包。源码包以实际共享目录为准，解压后，可以得到开源的源码。
tar zxf /home/ftp/mlu220/IVA-1.6.106/mlu220edge/release/neuware/opensrc/opensrc.tar.gz -C /opt/cambricon/opensrc
#编译完整源码包
cd /opt/cambricon/opensrc/mlu220_build/build/
make plat=edge
```
如果遇到如下错误:
```bash
......
./ramdisk_recovery.img
./tools/generate_bsp_pkg.sh: 35: ./tools/generate_bsp_pkg.sh: pushd: not found
md5sum: ./bsp.tar.gz: No such file or directory
./tools/generate_bsp_pkg.sh: 37: ./tools/generate_bsp_pkg.sh: popd: not found
./tools/generate_bsp_pkg.sh: 39: ./tools/generate_bsp_pkg.sh: popd: not found
Makefile:197: recipe for target 'linux-sys' failed
make: *** [linux-sys] Error 127
```

可以增加[#!/bin/bash]内容到脚本首行/opt/cambricon/opensrc/mlu220_build/build/tools/generate_bsp_pkg.sh
```bash
#手动编辑增加[#!/bin/bash]内容到脚本首行
#vi /opt/cambricon/opensrc/mlu220_build/build/tools/generate_bsp_pkg.sh
#命令方式增加[#!/bin/bash]内容到脚本首行
sed -i '1i\#!/bin/bash' /opt/cambricon/opensrc/mlu220_build/build/tools/generate_bsp_pkg.sh
```

修改脚本后，再次编译源码包即可。
```bash
#编译完整源码包
cd /opt/cambricon/opensrc/mlu220_build/build/
make plat=edge
#查看编译后的文件
/opt/cambricon/opensrc/mlu220_build/build/out/
```

编译完成后在/opt/cambricon/opensrc/mlu220_build/build/out/ ⽬录下⽣成如下⽂件:
```bash
out
|-- bsp
|-- bsp.tar.gz
|-- bsp_md5.txt
|-- cambricon
|-- cambricon.tar.gz
|-- cambricon_md5.txt
`-- upgrade.sh
```

# CNStream-MLU220Edge交叉编译
```bash
#source
echo $PATH
source /etc/profile
echo $PATH
#进入默认目录
cd /opt/cambricon
#拷贝CNStream-MLU220Edge交叉编译脚本
cp /home/cam/tools/build-cnstream-mlu220edge.sh ./

#下载cnstream.git
git clone https://github.com/Cambricon/cnstream.git
cd cnstream && git submodule update --init
# del .git
find . -name ".git" | xargs rm -Rf

```
```bash
#下载cnstream.git
git clone https://github.com/Cambricon/cnstream.git
cd cnstream && git submodule update --init
# del .git
find . -name ".git" | xargs rm -Rf
#开发调试：Build For MLU270
#mkdir build && cd build && cmake .. -DMLU=MLU270 && make
#220平台：Build For MLU220
mkdir build && cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE=../cmake/cross-compile.cmake -Dbuild_display=OFF -Dbuild_tests=OFF -Dbuild_track=OFF -DWITH_TRACKER=OFF -DENABLE_KCF=OFF -DMLU=MLU220_SOC
make
```

遇到的错误如下，措施：修改文件/opt/cambricon/cnstream/cmake/cross-compile.cmake中交叉编译器为实际路径:[/opt/make_tool/aarch64/] --> [/opt/cambricon/]
```bash
CMake Error at CMakeLists.txt:19 (project):
  The CMAKE_CXX_COMPILER:

    /opt/make_tool/aarch64/gcc-linaro-6.2.1-2016.11-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-g++

  is not a full path to an existing compiler tool.
```

遇到的错误如下，措施：添加参数-Dbuild_display=OFF
```bash
CMake Error at CMakeLists.txt:231 (find_package):
  By not providing "FindSDL2.cmake" in CMAKE_MODULE_PATH this project has
  asked CMake to find a package configuration file provided by "SDL2", but
  CMake did not find one.

  Could not find a package configuration file provided by "SDL2" with any of
  the following names:

    SDL2Config.cmake
    sdl2-config.cmake
```

遇到的错误如下，措施：
```bash
/usr/local/neuware/lib64/libcnrt.so: error adding symbols: File in wrong format
collect2: error: ld returned 1 exit status
easydk/CMakeFiles/easydk.dir/build.make:543: recipe for target 'easydk/libeasydk.so.2.4.0' failed
make[2]: *** [easydk/libeasydk.so.2.4.0] Error 1
CMakeFiles/Makefile2:224: recipe for target 'easydk/CMakeFiles/easydk.dir/all' failed
make[1]: *** [easydk/CMakeFiles/easydk.dir/all] Error 2
Makefile:138: recipe for target 'all' failed
make: *** [all] Error 2
```

## Build
```bash

mkdir build && cd build && cmake .. -DMLU=MLU220 && make
```
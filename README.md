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
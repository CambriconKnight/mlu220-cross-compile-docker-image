# mlu220-cross-compile Docker Images #

Build docker images for mlu220-cross-compile.

# Directory tree #

```bash
.
├── build-mlu220-cross-compile-image.sh
├── Dockerfile.16.04
├── load-image-mlu220-cross-compile.sh
└── run-container-mlu220-cross-compile.sh
```

# Clone #
```bash
git clone https://github.com/CambriconKnight/mlu220-cross-compile-docker-image.git
```

# Build #
```bash
#编译完成后，会在本地生成一个docker镜像。
#编译Docker镜像：安装 Neuware + gcc-linaro + gcc-arm
./build-mlu220-cross-compile-image.sh -n 1 -l 1 -a 1
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

# Load #
```bash
#加载Docker镜像
./load-image-mlu220-cross-compile.sh
```

# Run #
```bash
#启动Docker容器
./run-container-mlu220-cross-compile.sh
```

# Test #
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

# 源码包编译 #
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
# 1. mlu220-cross-compile Docker Images

Build docker images for mlu220-cross-compile.

此工具包集成了如下功能:

基于Dockerfile自动编译Docker镜像 >> 启动Docker容器 >> 一键交叉编译CNStream-MLU220Edge >> 生成CNStream-MLU220Edge部署包 >> 部署到MLU220SOM开发板卡 >> 验证CNStream-MLU220Edge实例

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

These environment variables has been set in the container:

- BIN_DIR_GCC_Linaro=/opt/cambricon/gcc-linaro-6.2.1-2016.11-x86_64_aarch64-linux-gnu/bin
- BIN_DIR_GCC_ARM=/opt/cambricon/gcc-arm-none-eabi-8-2018-q4-major/bin
- PATH=$BIN_DIR_GCC_Linaro:$BIN_DIR_GCC_ARM:$PATH
- NEUWARE_HOME=/opt/cambricon/neuware/pc

# 2. Directory tree

```bash
.
├── build-mlu220-cross-compile-image.sh
├── clean.sh
├── Dockerfile.16.04
├── load-image-mlu220-cross-compile.sh
├── README.md
└── run-container-mlu220-cross-compile.sh
```

# 3. Clone
```bash
git clone https://github.com/CambriconKnight/mlu220-cross-compile-docker-image.git
```

# 4. Build
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

# 5. Load
```bash
#加载Docker镜像
./load-image-mlu220-cross-compile.sh
```

# 6. Run
```bash
#启动Docker容器
./run-container-mlu220-cross-compile.sh
```

# 7. Test
```bash
#执⾏以下命令，确认aarch64-linux-gnu-gcc版本信息：
aarch64-linux-gnu-gcc -v
#执⾏以下命令，确认arm-none-eabi-gcc版本信息：
arm-none-eabi-gcc -v
```

# 8. 源码包编译与验证
## 8.1. 完整编译
```bash
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
- 常见问题-1：

问题描述：如果遇到如下错误。
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

解决措施：可以增加[#!/bin/bash]内容到脚本首行/opt/cambricon/opensrc/mlu220_build/build/tools/generate_bsp_pkg.sh
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

## 8.2. 编译结果
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

# 9. CNStream-MLU220Edge交叉编译与验证
MLU220交叉编译Docker镜像编译生成后，接下来可基于此镜像进行MLU220Edge实例程序的交叉编译与验证：

启动容器 >> 交叉编译 >> MLU220SOM验证

以下基于寒武纪实时数据流分析开源框架[CNStream](https://github.com/Cambricon/CNStream)进行交叉编译与验证.

## 9.1. 启动容器
```bash
#启动Docker容器
./run-container-mlu220-cross-compile.sh
```

## 9.2. 交叉编译
以下是基于CNStream进行交叉编译，详细交叉编译过程参考[CNStream-MLU220Edge交叉编译脚本](./cnstream/build-cnstream-mlu220edge.sh)。
```bash
#进入cnstream目录:在容器中映射目录下，进行编译，方便文件共享。
cd /home/cam/cnstream
#启动一键编译CNStream-MLU220Edge脚本
#编译完成后，会在本目录下生成一个部署包，文件默认名称是cnstream_mlu220edge.tar.gz
./build-cnstream-mlu220edge.sh
#CNStream-MLU220Edge生成后，可以直接拷贝部署到MLU220SOM上进行验证。(以实际IP为准替换)
scp cnstream_mlu220edge.tar.gz root@192.168.1.110:/cambricon/
#CNStream-MLU220Edge生成后，也可以拷贝到NFS服务器挂载目录，采用挂载上位机NFS目录的方式，进⾏交互开发⼯作。
cp cnstream_mlu220edge.tar.gz /data/nfs/
```

## 9.3. MLU220SOM验证
MLU270主机开发环境搭建完毕后，接下来需要搭建MLU220SOM验证环境：

SOM板连接主机 >> 连接电源 >> 连接串口 >> 连接网口 >> 挂载NFS目录 >> 验证实例


### 9.3.1. SOM板连接主机
详见[《Cambricon_SOM_SDK_User_Guide_CN_v1.0.0-2.pdf》](ftp://download.cambricon.com:8821/download/document/MLU220SOM_IVA_1.6.106/Cambricon_SOM_SDK_User_Guide_CN_v1.0.0-2.pdf)。章节3.1.3 SOM板连接主机。

### 9.3.2. 连接电源
将MLU220SOM底板的外部电源接好(12V DC电源输入)。

### 9.3.3. 连接串口
使用USB转TTL串口线连接MLU220SOM底板上的CPU_UART_0接口。⽤串⼝转USB 线连接到主机。⽤minicom 等⼯具打开串⼝时，波特率请选择115200，关闭流控。

USB转TTL串口线序连接说明(以下仅举例说明,以实际使用的线缆为准):

| 信号线定义   | 信号线颜色  | MLU220SOM底板接口     | 备注                                         |
| ---------- | ---------- | ------------------- | ------------------------------------------- |
| `GND`      | 黑线       | 接底板上【GND】针脚    | 可接底板接口：CPU_UART_0/CPU_UART_1/MCU_UART_5 |
| `TXD`      | 绿线       | 接底板上【RXD】针脚    | 可接底板接口：CPU_UART_0/CPU_UART_1/MCU_UART_5 |
| `RXD`      | 白线       | 接底板上【TXD】针脚    | 可接底板接口：CPU_UART_0/CPU_UART_1/MCU_UART_5 |
| `VCC`      | 红线       | 不需连接              | 可接底板接口：CPU_UART_0/CPU_UART_1/MCU_UART_5 |

### 9.3.4. 连接网口
⽤⽹线将千兆以太⽹ETH1 和主机相连。

### 9.3.5. 挂载NFS目录
在开发阶段，推荐使⽤NFS ⽂件系统作为开发环境⽂件系统，使⽤NFS ⽂件系统减少了重新制作和烧写根⽂件系统的⼯作。挂载NFS ⽂件系统参考如下命令：


```bash
## 在220SOM上建立nfs挂载目录,用于挂载上位机目录
mkdir -p /cambricon/nfs
## 在220SOM上挂载上位机nfs目录
mount -t nfs -o nolock 10.100.8.225:/data/nfs /cambricon/nfs
```
挂载完成，即可以访问NFS 服务器上/data/nfs ⽬录下的⽂件，进⾏交互开发⼯作。

### 9.3.6. 验证实例
以下采用挂载上位机NFS目录的方式，进⾏交互开发⼯作。
```bash
#SSH登陆MLU220Edge
ssh root@192.168.1.110
#进入 MLU220Edge 板卡上的NFS目录。
cd /cambricon/nfs
ls -la cnstream_mlu220edge.tar.gz
#MLU220Edge板卡上解压cnstream_mlu220edge.tar.gz(上位机器上解压更快)
tar zxvf cnstream_mlu220edge.tar.gz
#进入应用实例子目录
cd ./cnstream_mlu220edge
#设置环境变量(第一次登陆板卡需要设置环境变量)
. env.sh
#测试YOLOv3-MLU220Edge
cd /cambricon/nfs/cnstream_mlu220edge/samples/demo/detection/mlu220
./run_yolov3_mlu220.sh
```
- 常见问题-1：

问题描述：如果遇到如下错误，则可能是MLU220Edge 板卡无法访问[模型存放网址](video.cambricon.com)，导致下载模型失败。
```bash
wget: bad address 'video.cambricon.com'
wget: bad address 'video.cambricon.com'
......
```

解决措施：可在上位机或其他主机上，手动下载已经转好的模型及标签文件，下载完成后拷贝到指定目录，再次启动测试YOLOv3-MLU220Edge。
```bash
#进入任意目录
cd /data/tmp
#在上位机或其他主机上，手动下载已经转好的模型及标签文件
wget -O yolov3_4c4b_argb_220_v1.5.0.cambricon http://video.cambricon.com/models/MLU220/Primary_Detector/YOLOv3/yolov3_4c4b_argb_220_v1.5.0.cambricon
wget -c http://video.cambricon.com/models/MLU270/yolov3/label_map_coco.txt
#下载完成后拷贝到指定目录(以NFS目录为例，目录可能已经变成root权限了，可以使用sudo进行拷贝)
sudo cp -vf yolov3_4c4b_argb_220_v1.5.0.cambricon label_map_coco.txt /data/nfs/cnstream_mlu220edge/data/models/MLU220/Primary_Detector/YOLOv3
ls -la /data/nfs/cnstream_mlu220edge/data/models/MLU220/Primary_Detector/YOLOv3
#登陆MLU220Edge，再次启动测试YOLOv3-MLU220Edge
ssh root@192.168.1.110
cd /cambricon/nfs/cnstream_mlu220edge
. ./env.sh
cd /cambricon/nfs/cnstream_mlu220edge/samples/demo/detection/mlu220
./run_yolov3_mlu220.sh
```

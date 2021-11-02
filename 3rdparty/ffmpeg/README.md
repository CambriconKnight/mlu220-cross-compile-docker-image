# 1. FFMpeg-MLU220Edge交叉编译与验证
MLU220交叉编译Docker镜像编译生成后，接下来可基于此镜像进行MLU220Edge实例程序的交叉编译与验证：

启动容器 >> 交叉编译 >> MLU220SOM验证

以下基于寒武纪开源的视频编解码库[FFmpeg](https://github.com/FFmpeg/FFmpeg)进行交叉编译与验证.

**依赖的软件:**

| 名称                   | 版本/文件/地址                                          | 备注                                 |
| :-------------------- | :-------------------------------                      | :---------------------------------- |
| FFMpeg                | [ffmpeg-4.1.6"](http://ffmpeg.org/releases/ffmpeg-4.1.6.tar.gz)           |  |
| GCC_LINARO_MLU220EDGE | gcc-linaro-6.2.1-2016.11-x86_64_aarch64-linux-gnu.tgz                     | ARM64 交叉编译器, 可前往[寒武纪开发者社区](https://developer.cambricon.com) 下载, 或在官方提供的FTP账户指定路径下载 |


## 1.1. 启动容器
```bash
#启动Docker容器
./run-container-mlu220-cross-compile.sh
```

## 1.2. 交叉编译
以下是基于 FFmpeg 进行交叉编译，详细交叉编译过程参考[FFmpeg_MLU220Edge 交叉编译脚本](./build-ffmpeg-mlu220edge.sh)。
```bash
#进入工作目录:在容器中映射目录下，进行编译，方便文件共享。
cd /home/share/3rdparty/ffmpeg
#启动 FFmpeg_MLU220Edge 一键化交叉编译脚本
#编译完成后，会在本目录下生成一个部署包，文件默认名称是 ffmpeg_mlu220edge.tar.gz
./build-ffmpeg-mlu220edge.sh
# FFmpeg_MLU220Edge 生成后，可以直接拷贝部署到 MLU220SOM 上进行验证。(以实际IP为准替换)
scp ffmpeg_mlu220edge.tar.gz root@192.168.1.110:/cambricon/
# FFmpeg-MLU220Edge 生成后，也可以拷贝到NFS服务器挂载目录，采用挂载上位机NFS目录的方式，进⾏交互开发⼯作。
cp ffmpeg_mlu220edge.tar.gz /data/nfs/
```

## 1.3. MLU220SOM验证
MLU270主机开发环境搭建完毕后，接下来需要搭建MLU220SOM验证环境：

SOM板连接主机 >> 连接电源 >> 连接串口 >> 连接网口 >> 挂载NFS目录 >> 验证实例


### 1.3.1. SOM板连接主机
详见[《Cambricon_SOM_SDK_User_Guide_CN_v1.0.0-2.pdf》](ftp://download.cambricon.com:8821/download/document/MLU220SOM_1.7.602/Cambricon_SOM_SDK_User_Guide_CN_v1.0.0-2.pdf)。章节3.1.3 SOM板连接主机。

### 1.3.2. 连接电源
将MLU220SOM底板的外部电源接好(12V DC电源输入)。

### 1.3.3. 连接串口
使用USB转TTL串口线连接MLU220SOM底板上的CPU_UART_0接口。⽤串⼝转USB 线连接到主机。⽤minicom 等⼯具打开串⼝时，波特率请选择115200，关闭流控。

USB转TTL串口线序连接说明(以下仅举例说明,以实际使用的线缆为准):

| 线序定义    | USB转TTL线缆        | MLU220SOM底板接口       | 备注                                        |
| ---------- | ------------------ | --------------------- | ------------------------------------------- |
| `GND`      | 黑线               | 接底板上【GND】针脚      | 可接底板接口：CPU_UART_0/CPU_UART_1/MCU_UART_5 |
| `TXD`      | 绿线               | 接底板上【RXD】针脚      | 可接底板接口：CPU_UART_0/CPU_UART_1/MCU_UART_5 |
| `RXD`      | 白线               | 接底板上【TXD】针脚      | 可接底板接口：CPU_UART_0/CPU_UART_1/MCU_UART_5 |
| `VCC`      | 红线               | 不需连接               | 可接底板接口：CPU_UART_0/CPU_UART_1/MCU_UART_5 |

### 1.3.4. 连接网口
⽤⽹线将千兆以太⽹ETH1 和主机相连。

### 1.3.5. 挂载NFS目录
在开发阶段，推荐使⽤NFS ⽂件系统作为开发环境⽂件系统，使⽤NFS ⽂件系统减少了重新制作和烧
写根⽂件系统的⼯作。挂载NFS ⽂件系统参考如下命令：

```bash
## 在220SOM上建立nfs挂载目录,用于挂载上位机目录
mkdir -p /cambricon/nfs
## 在220SOM上挂载上位机nfs目录
mount -t nfs -o nolock 10.100.8.225:/data/nfs /cambricon/nfs
```
挂载完成，即可以访问NFS 服务器上/data/nfs ⽬录下的⽂件，进⾏交互开发⼯作。

### 1.3.6. 验证实例
以下采用挂载上位机NFS目录的方式，进⾏交互开发⼯作。
```bash
#SSH登陆MLU220Edge
ssh root@192.168.1.110
#进入 MLU220Edge 板卡上的NFS目录。
cd /cambricon/nfs
ls -la ffmpeg_mlu220edge.tar.gz
#MLU220Edge板卡上解压 ffmpeg_mlu220edge.tar.gz(上位机器上解压更快)
tar zxvf ffmpeg_mlu220edge.tar.gz
#进入应用实例子目录
cd ./ffmpeg_mlu220edge
#设置环境变量(第一次登陆板卡需要设置环境变量)
. ./env.sh
#测试:查看ffmpeg版本信息
cd /cambricon/nfs/ffmpeg_mlu220edge/bin
./ffmpeg -version
```
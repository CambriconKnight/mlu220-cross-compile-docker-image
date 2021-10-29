# 1. FFmpeg-MLU_MLU220Edge 交叉编译与验证
MLU220交叉编译Docker镜像编译生成后，接下来可基于此镜像进行MLU220Edge实例程序的交叉编译与验证：

启动容器 >> 交叉编译 >> MLU220SOM验证

以下基于寒武纪开源的视频编解码库[FFmpeg-MLU](https://github.com/Cambricon/ffmpeg-mlu)进行交叉编译与验证.

**依赖的软件:**

| 名称                   | 版本/文件/地址                                          | 备注                                 |
| :-------------------- | :-------------------------------                      | :---------------------------------- |
| CNStream              | [GitHub](https://github.com/Cambricon/cnstream.git);[Gitee](https://gitee.com/SolutionSDK/CNStream.git) |  |
| GCC_LINARO_MLU220EDGE | gcc-linaro-6.5.0-2018.12-x86_64_aarch64-linux-gnu.tar.xz                     | ARM64 交叉编译器, 可前往[
Linaro 社区](https://releases.linaro.org/components/toolchain/binaries/6.5-2018.12/aarch64-linux-gnu/) 下载 |
| CNToolkit_MLU220EDGE  | cntoolkit-edge_1.7.5-1_arm64.tar.gz                                       | Neuware SDK For MLU220, 可前往[寒武纪开发者社区](https://developer.cambricon.com) 下载, 或在官方提供的FTP账户指定路径下载 |
| CNCV_MLU220EDGE       | cncv-edge_0.4.602-1_arm64.tar.gz                                       | CNCV For MLU220, 可前往[寒武纪开发者社区](https://developer.cambricon.com) 下载, 或在官方提供的FTP账户指定路径下载 |



## 1.1. 启动容器
```bash
#启动Docker容器
./run-container-mlu220-cross-compile.sh
```

## 1.2. 交叉编译
以下是基于 FFmpeg-MLU 进行交叉编译，详细交叉编译过程参考[FFmpeg-MLU_MLU220Edge 交叉编译脚本](./build-ffmpeg-mlu-mlu220edge.sh)。
```bash
#进入工作目录:在容器中映射目录下，进行编译，方便文件共享。
cd /home/cam/ffmpeg-mlu
#启动 FFmpeg-MLU_MLU220Edge 一键化交叉编译脚本
#编译完成后，会在本目录下生成一个部署包，文件默认名称是 ffmpeg-mlu_mlu220edge.tar.gz
./build-ffmpeg-mlu-mlu220edge.sh
# FFmpeg-MLU_MLU220Edge 生成后，可以直接拷贝部署到 MLU220SOM 上进行验证。(以实际IP为准替换)
scp ffmpeg-mlu_mlu220edge.tar.gz root@192.168.1.110:/cambricon/
# FFmpeg-MLU-MLU220Edge 生成后，也可以拷贝到NFS服务器挂载目录，采用挂载上位机NFS目录的方式，进⾏交互开发⼯作。
cp ffmpeg-mlu_mlu220edge.tar.gz /data/nfs/
```

## 1.3. MLU220SOM验证


<p align="center">
    <a href="https://gitee.com/cambriconknight/mlu220-cross-compile-docker-image/tree/master/tools/watchdog">
        <img alt="mlu220-som" src="../../res/mlu220-som.jpg" height="140" />
        <h1 align="center">MLU220-SOM看门狗功能如何开启?</h1>
    </a>
</p>

# 1. 概述

默认没有开启看门狗， 如要开启需要修改BSP源码包dts中的wdt status，重新编译升级MLU220-SOM。详细操作如下：

# 2. 准备环境

**软件包:**

| 名称                   | 版本/文件                                              | 备注                                 |
| :-------------------- | :-------------------------------                      | :---------------------------------- |
| Linux OS              | Ubuntu16.04/Ubuntu18.04/CentOS7                       | 宿主机操作系统                         |
| MLU220-SOM交叉编译工具集 | mlu220-cross-compile-docker-image                    | MLU220-SOM交叉编译工具集               |
| Driver_MLU220         | cambricon-mlu220edge-driver-4.9.7-arm64.tar.gz        | MLU220驱动源码包                      |
| CNToolkit             | cntoolkit-edge_1.7.5-1_arm64.tar.gz                   | CNToolkit 包                      |

**下载地址:**

Driver: ftp://username@download.cambricon.com:8821/download/mlu220edge-driver-4.9.7-arm64/cambricon-mlu220edge-driver-4.9.7-arm64.tar.gz

CNToolkit： ftp://username@download.cambricon.com:8821/product/GJD/MLU220/1.7.602/mlu220edge/cntoolkit-edge_1.7.5-1_arm64.tar.gz

*注: 以上链接中的 [username] 需要替换为官方提供的专属FTP账户并使用对应密码下载。*

# 3. 修改源码

解压MLU220驱动源码包 cambricon-mlu220edge-driver-4.9.7-arm64.tar.gz, 得到如下目录结构:

修改BSP源代码文件: release/neuware/opensrc/opensrc/linux/arch/arm64/boot/dts/cambricon/cambr-c20e-common.dtsi

修改后:

```bash
wdt: wdt@8000001000 {
    compatible = "cambricon,cn_wdt";
    reg = <0x80 0x00001000 0x0 0x1000>,   /*ap wdt reg base*/
        <0x80 0x00000000 0x0 0x400>; /*top sysctl wdt pause*/
    topsctl-offset-mask = <0x8> , <0x10>;
    interrupts = <GIC_SPI 102 IRQ_TYPE_LEVEL_HIGH>;
    timeout-sec = <16>; /*2^(-10)*2^i i={0-15}*/
    clocks = <&sys_62p5m>;
    status = "ok";
};
```

修改前:

```bash
wdt: wdt@8000001000 {
    compatible = "cambricon,cn_wdt";
    reg = <0x80 0x00001000 0x0 0x1000>,   /*ap wdt reg base*/
        <0x80 0x00000000 0x0 0x400>; /*top sysctl wdt pause*/
    topsctl-offset-mask = <0x8> , <0x10>;
    interrupts = <GIC_SPI 102 IRQ_TYPE_LEVEL_HIGH>;
    timeout-sec = <16>; /*2^(-10)*2^i i={0-15}*/
    clocks = <&sys_62p5m>;
    status = "disabled";
};
```

# 4. 编译源码

编译BSP源码参考：https://gitee.com/cambriconknight/mlu220-cross-compile-docker-image#81-完整编译

# 5. 升级板卡

整理以下升级内容，拷贝到MLU220SOM板卡任意目录，执行upgrade.sh脚本进行升级。详细参考见: 【寒武纪SOM+SDK使用及开发指南_v1.7.0.pdf】

**升级内容**

```bash
.
├── bsp_md5.txt
├── bsp.tar.gz
├── cambricon_md5.txt
├── cambricon.tar.gz
├── neuware_md5.txt
├── neuware.tar.gz
└── upgrade.sh

0 directories, 7 files
```
*注1: bsp.tar.gz, bsp_md5.txt 是由MLU220驱动源码包解压并编译后生成[release/neuware/opensrc/opensrc/mlu220_build/build/out/bsp.tar.gz]。*

*注2: cambricon.tar.gz, cambricon_md5.txt 是由MLU220驱动源码包解压并编译后生成[release/neuware/opensrc/opensrc/mlu220_build/build/out/cambricon.tar.gz]。*

*注3: neuware.tar.gz, neuware_md5.txt 是由CNToolkit 包直接解压后得到[neuware/board/image/neuware.tar.gz]。*

**升级命令**

```bash
chmod +x upgrade.sh
./upgrade.sh
```

执行升级脚本, 升级大概需要几分钟, 升级过程会自动完成以下工作:

- 1. 将 bsp.tar.gz、cambricon.tar.gz、neuware.tar.gz、bsp_md5.txt、cambricon_md5.txt、neuware_md5.txt 存入 eMMC 的 boot 分区,检查 tar 包对应的 md5 值是否正确。如果没有发现任何可升级的文件,则退出升级;
- 2. 解压 bsp.tar.gz,将 Image_recovery、ramdisk_recovery.img、cambr‐c20e_recovery.dtb 和 fs.sys 更新至 boot 分区;如果没有 bsp.tar.gz 则跳过此步骤;
- 3. 更新 Nor Flash 的 bootloader;如果没有 bsp.tar.gz 则跳过此步骤;
- 4. 重启 reboot;
- 5. 加载 Image_recovery、ramdisk_recovery.img、cambr‐c20e_recovery.dtb 进入升级模式并启动 kernel;
- 6. 将 eMMC 的 boot 分 区 中 的 bsp.tar.gz 解 压 更 新 eMMC 的 boot 分 区 中 的 Image、ramdisk.img、cambr‐c20e.dtb 和 ubootenv.bin;
- 7. eMMC 的 boot 分区中的 cambricon.tar.gz 存在,则格式化 cambricon 分区,并将 cam‐bricon.tar.gz 解压至 cambricon 分区,并检查文件的 md5 值;如果没有 cambricon.tar.gz则跳过此步骤;
- 8. eMMC 的 boot 分区中的 neuware.tar.gz 存在,则格式化 neuware 分区,并将 cambri‐con.tar.gz 解压至 neuware 分区,并检查文件的 md5 值;如果没有 neuware.tar.gz 则跳过此步骤;
- 9. 完成升级,reboot 重启系统;
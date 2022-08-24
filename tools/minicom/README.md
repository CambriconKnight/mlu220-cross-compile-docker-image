<p align="center">
    <a href="https://gitee.com/cambriconknight/mlu220-cross-compile-docker-image/tree/master/tools/minicom">
        <img alt="minicom" src="../../res/minicom.png" height="140" />
        <h1 align="center">Minicom串口通信工具</h1>
    </a>
</p>

# 1. 概述
Minicom 是一个串口通信工具，就像 Windows 下的超级终端。可用来与串口设备通信，如调试交换机和 Modem 等。而寒武纪 MLU220-SOM 模组出厂自带的精简版嵌入式Linux系统并没有 Minicom 工具，为此本文主要介绍基于 Minicom 及依赖库的源码下载，交叉编译，部署，配置以及测试。

# 2. 源码下载
Minicom 源码包下载地址: https://salsa.debian.org/minicom-team/minicom/-/archive/2.8/minicom-2.8.tar
Ncurses 源码包下载地址: https://ftp.gnu.org/gnu/ncurses/ncurses-5.7.tar.gz

>![](../../res/note.gif) **备注信息：**
>- 1. 以上 Minicom 和 Ncurses 源码也可以关注微信公众号 AIKnight , 发送文字消息, 包含关键字(不区分大小写): **Minicom**, 公众号会自动回复Minicom源码及依赖库的下载地址。
>- 2. 请把下载后的源码包放置到当前 minicom 目录下, 方便后续脚本提示进行后续操作。

**公众号**
>![](../../res/aiknight_wechat_344.jpg)

# 3. 交叉编译
## 3.1. Ncurses 交叉编译
```bash
tar -xvf ncurses-5.7.tar.gz
cd ncurses-5.7
mkdir ncurses_install
./configure CC=aarch64-linux-gnu-gcc CXX=aarch64-linux-gnu-g++ --host=arm-linux --prefix=/home/share/tools/minicom/ncurses-5.7/ncurses_install
make
make install
```

## 3.2. Minicom 交叉编译
```bash
tar -xvf minicom-2.8.tar
cd minicom-2.8
##在交叉编译Ubuntu上位机环境下安装automake工具
# apt-get update
# apt-get install automake
# aclocal --version
##在交叉编译Ubuntu上位机环境下安装gettext工具
##AM_GNU_GETTEXT或AM_ICONV未定义或未找到需下载/安装此项
# apt-get install gettext
##安装或修改autogen.sh对应版本
# AUTOMAKEVER=1.15
./autogen.sh
mkdir minicom_install
./configure CC=aarch64-linux-gnu-gcc CXX=aarch64-linux-gnu-g++ \
    --host=arm-linux \
    --prefix="/home/share/tools/minicom/minicom-2.8/minicom_install" \
    --enable-cfg-dir="/etc" \
    CPPFLAGS="-I/home/share/tools/minicom/ncurses-5.7/ncurses_install/include" \
    LDFLAGS="-L/home/share/tools/minicom/ncurses-5.7/ncurses_install/lib"
make
make install
```

# 4. 部署

如拷贝到MLU220SOM上运行报类似错误:错No termcap entry for xterm/vt100/vt2000等, 可将终端信息从其他系统拷贝或设置为已有的, 如下操作:
```bash
export TERMINFO=/usr/share/terminfo
export TERM=vt100
```

# 5. 测试

参见互联网 minicom 使用手册.
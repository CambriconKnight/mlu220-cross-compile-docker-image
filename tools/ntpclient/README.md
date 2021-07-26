# 1. 概述
基于寒武纪 MLU220-SOM 边缘端人工智能模组可以开发出很多场景应用的嵌入式AI设备。但可能有些嵌入式设备中设计之初为了节省成本或者体积原因都没有配备掉电保存电池，每次上电之后就需要人为手动的更新系统时间，而且系统时间也不准确。有些场景应用需要得到实时且较准确的时间，以和服务器或设备之间进行时间同步。但是又不能通过人工设置时间的方式来同步时间，那就需要有个服务/程序自动从网络上获取时间，这就需要用到NTP。
NTP是网络时间协议(Network Time Protocol)的简称，它是用来同步网络中各个计算机设备的时间的协议。

# 2. NTPClient
为了支持精简版嵌入式Linux系统NTP校时，本文推荐的是第三方代码ntpclient保持时间同步：
```bash
ntpclient is an NTP (RFC-1305) client for unix-alike computers. Its functionality is a small subset of xntpd, but IMHO performs better (or at least has the potential to function better) within that limited scope. Since it is much smaller than xntpd, it is also more relevant for embedded computers.
ntpclient is Copyright (C) 1997-2015 Larry Doolittle, and may be freely copied and modified according to the terms of the GNU General Public License, version 2.
```

## 2.1 NTPClient下载地址
ntpclient的下载地址是：https://github.com/CambriconKnight/ntpclient

## 2.2 NTPClient交叉编译
下载好后，解压，进入解压后的目录进行交叉编译。
交叉编译环境搭建参考：https://github.com/CambriconKnight/mlu220-cross-compile-docker-image
1. 修改Makefile
```bash
    CC = aarch64-linux-gnu-gcc
```
2. 交叉编译
```bash
make
```

## 2.3 拷贝到MLU220-SOM目标板
拷贝编译得到的ntpclient文件至目标板/cambricon/目录下，并加可执行权限
```bash
chmod +x ntpclient
```

## 2.4. 查看网络授时服务器网址
测试校时前，我们需要一个网络授时服务器网址：
```bash
http://www.ntp.org.cn/
```
这个是授时中心网页，在这个上面可以找到需要的授时中心网址。以下选择上海交通大学网络中心NTP服务器地址（202.120.2.101），实测可用。

## 2.5 执行NTPClient
在MLU220-SOM目标板上运行程序NTPClient，实现NTP校时。
```bash
./ntpclient -s -d -c 1 -i 5 -h 202.120.2.101
```
设备会返回如下:
```bash
[root@cambricon /cambricon]# date
Thu Jan  1 00:47:47 UTC 1970
[root@cambricon /cambricon]# ./ntpclient -s -d -c 1 -i 5 -h 202.120.2.101
Configuration:
  -c probe_count 1
  -d (debug)     1
  -g goodness    0
  -h hostname    202.120.2.101
  -i interval    5
  -l live        0
  -p local_port  0
  -q min_delay   800.000000
  -s set_clock   1
  -x cross_check 1
Listening...
Sending ...
packet of length 48 received
Source: INET Port 123 host 202.120.2.101
LI=0  VN=3  Mode=4  Stratum=3  Poll=4  Precision=-23
Delay=41900.6  Dispersion=65506.0  Refid=172.161.197.151
Reference 3836256094.914933
(sent)    2208991692.113604
Originate 2208991692.113604
Receive   3836257329.603929
Transmit  3836257329.603977
Our recv  2208991692.143214
Total elapsed:  29686.00
Server stall:      46.34
Slop:           29639.66
Skew:          1627265637475952.50
Frequency:             0
 day   second     elapsed    stall     skew  dispersion  freq
set time to 1627268529.603977
25567 02892.143   29686.0     46.3  1627265637475952.5  65506.0         0
[root@cambricon /cambricon]# date
Mon Jul 26 03:02:12 UTC 2021
[root@cambricon /cambricon]#
```
其中那些参数可以阅读解压后的目录下的README文件，里面有详细的说明，需要提示的是-g不能使用，可能是嵌入式设备不支持。

使用【date】来查看一下系统时间，如果时区不是中国的东八区，可设置环境变量。
```bash
export TZ=CST-8
```
设置后就可以显示中国时间了。
```bash
[root@cambricon /cambricon]# date
Mon Jul 26 03:02:12 UTC 2021
[root@cambricon /cambricon]# export TZ=CST-8
[root@cambricon /cambricon]# date
Mon Jul 26 11:12:09 CST 2021
```

## 2.6 实现上电自动校时
最后需要将前面命令加入MLU220-SOM目标板启动脚本，从而实现上电自动同步网络时间。

1.在开机脚本（我的是/etc/init.d/rcS)中修改下面几句话（ntpclient所在目录我的是/cambricon/ntpclient，以实际为准）：
```bash
#date -s "1970-01-01 00:00:00"     （注释掉这一行）
/cambricon/ntpclient -s -d -c 1 -i 5 -h 202.120.2.101 >/dev/null &   （加入这一行，需加在获取网络命令行之后，确保先有网）
```
2.然后是添加系统环境变量，让开机后自动使用东八区(若之前已修改过系统硬件时钟配置文件，已改为东八区，则无需此步操作)
目标板文件系统/etc/profile中添加
```bash
export TZ=CST-8
```
然后就可以当目标板上电自动同步时间了。

**注：以上修改涉及BSP部分修改的，需要根据自身系统灵活实现。**

# 3. 附录
## 3.1 MLU220-SOM简述
寒武纪 MLU220-SOM 边缘端人工智能模组，专为边缘端AI推理设计。采用寒武纪MLUv02架构，高集成，在信用卡大小的模组上可实现 16TOPS（INT8） AI 性能，可提供 INT16，INT8，INT4 的全面精度支持，满足多样化的神经网络的计算力要求。MLU220-SOM 可以满足在 -40℃ ~ 105℃ 宽温环境下各种严苛的户外部署要求，功耗仅为 15W，支持视觉、语音自然语言处理等多样化的AI应用，实现各种业务的边缘端单模组解决方案。MLU220-SOM 已广泛应用于智慧交通、智慧能源、智慧轨道交通等AI落地应用中。
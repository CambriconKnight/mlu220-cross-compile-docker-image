# 1. 概述
基于寒武纪 MLU220-SOM 边缘端人工智能模组可以开发出很多场景应用的嵌入式AI设备。为了提供数据库的支持，有可能会在嵌入式设备中增加Redis数据库的支持。Remote Dictionary Server(Redis) 远程字典服务器是完全开源免费的，用C语言编写的，遵守BSD开源协议，是一个高性能的(key/value)分布式内存数据库，基于内存运行,并支持持久化的NoSQL数据库，它也通常被称为数据结构服务器。

# 2. Redis
为了支持精简版嵌入式Linux系统Redis，以下介紹的是移植步骤：

## 2.1 Redis下载地址
redis-4.0.9的下载地址是：https://github.com/redis/redis/tree/4.0.9

## 2.2 Redis交叉编译
git clone https://github.com/redis/redis.git
<<<<<<< HEAD

=======
>>>>>>> d69128a6c5e132cedb415688d5b43119100cd5a6
下载好后，进入目录进行交叉编译。
交叉编译环境搭建参考：https://github.com/CambriconKnight/mlu220-cross-compile-docker-image
1. 交叉编译
```bash
make MALLOC=libc CC=aarch64-linux-gnu-gcc CXX=aarch64-linux-gnu-g++ AR=aarch64-linux-gnu-ar RANLIB=aarch64-linux-gnu-ranlib NM=aarch64-linux-gnu-nm
```
会出现如下结果，表示已经编译完成
```
    ......
    LINK redis-server
    INSTALL redis-sentinel
    CC redis-cli.o
    CC redisassert.o
    CC cli_common.o
    LINK redis-cli
    CC redis-benchmark.o
    LINK redis-benchmark
    INSTALL redis-check-rdb
    INSTALL redis-check-aof

```

## 2.3 拷贝到MLU220-SOM目标板
拷贝编译得到的redis文件夹至目标板/cambricon/目录下，并加可执行权限
```bash
chmod +x redis
```

## 2.4. 在MLU220-SOM开发板上启动：
进入redis目录
```
启动服务器

执行命令：src/redis-server

启动客户端

执行命令：src/redis-cli
<<<<<<< HEAD
注：redis-server通过redis文件夹下redis.conf 文件进行配置，保证redis-server顺利运行。具体的命令redis文件夹下运行：src/redis-server ./redis.conf。
=======
>>>>>>> d69128a6c5e132cedb415688d5b43119100cd5a6
```

# 3. 附录
## 3.1 MLU220-SOM简述
寒武纪 MLU220-SOM 边缘端人工智能模组，专为边缘端AI推理设计。采用寒武纪MLUv02架构，高集成，在信用卡大小的模组上可实现 16TOPS（INT8） AI 性能，可提供 INT16，INT8，INT4 的全面精度支持，满足多样化的神经网络的
计算力要求。MLU220-SOM 可以满足在 -40℃ ~ 105℃ 宽温环境下各种严苛的户外部署要求，功耗仅为 15W，支持视觉、语音自然语言处理等多样化的AI应用，实现各种业务的边缘端单模组解决方案。MLU220-SOM 已广泛应用于智慧交>通、智慧能源、智慧轨道交通等AI落地应用中。

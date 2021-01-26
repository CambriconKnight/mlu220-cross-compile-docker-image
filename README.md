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

#/bin/bash
set -e

echo "================================================="
#查看所有容器
docker ps -a

echo "================================================="
#stop停止所有容器
docker stop $(docker ps -a -q)
#remove删除所有容器
docker  rm $(docker ps -a -q)

echo "================================================="
#查看所有容器
docker ps -a

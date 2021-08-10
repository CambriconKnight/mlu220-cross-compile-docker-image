#/bin/bash
set -e

# 1.cnstream_mlu220edge
if [ -d "cnstream_mlu220edge" ];then rm -rvf cnstream_mlu220edge;fi
# 2.cnstream_mlu220edge.tar.gz
if [ -f "cnstream_mlu220edge.tar.gz" ];then rm -vf cnstream_mlu220edge.tar.gz;fi

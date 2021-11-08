#/bin/bash
set -e

# 1.restful_mlu220edge
if [ -d "restful_mlu220edge" ];then rm -rvf restful_mlu220edge;fi
# 2.restful_mlu220edge.tar.gz
if [ -f "restful_mlu220edge.tar.gz" ];then rm -vf restful_mlu220edge.tar.gz;fi

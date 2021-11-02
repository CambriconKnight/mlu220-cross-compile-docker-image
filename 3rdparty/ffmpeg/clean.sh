#/bin/bash
set -e

# 1.ffmpeg_mlu220edge
if [ -d "ffmpeg_mlu220edge" ];then rm -rvf ffmpeg_mlu220edge;fi
# 2.ffmpeg_mlu220edge.tar.gz
if [ -f "ffmpeg_mlu220edge.tar.gz" ];then rm -vf ffmpeg_mlu220edge.tar.gz;fi

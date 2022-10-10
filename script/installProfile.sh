#!/bin/zsh

# 参数1：描述文件名称

set -euo pipefail

startDate=$(date +%s)
echo -e "\033[33m 描述文件安装脚本执行开始：$(date "+%Y-%m-%d %H:%M:%S") \033[0m"

# 脚本根目录
shPath=$(cd "$(dirname "$0")";pwd)
echo "脚本根目录：$shPath"
# 进入当前文件所在路径
cd "$(dirname "$0")"

# ------------传入的参数-----------------------------------------
# 描述文件名称，文件要放在../certificate目录下
profileFileName=$1
# ----------------------------------------------------------------

# 描述文件路径
profileFilePath="../certificate/${profileFileName}"
echo "描述文件路径：$profileFilePath"

if [ -f  ${profileFilePath} ]; then
  echo -e "\033[32m 描述文件存在 \033[0m"
else
  echo -e "\033[31m 描述文件不存在 \033[0m"
  exit 1
fi

# 描述文件安装位置
provisioningProfilesPath=~/Library/MobileDevice/Provisioning\ Profiles

if [ ! -d  ${provisioningProfilesPath} ]; then
	mkdir -p ${provisioningProfilesPath}
fi

cp ${profileFilePath} "${provisioningProfilesPath}/${profileFileName}"

if [[ $? = 0 ]]; then
  echo -e "\033[32m 描述文件安装成功 \033[0m"
else
  echo -e "\033[31m 描述文件安装失败 \033[0m"
  exit 1
fi

# 执行完毕
endDate=$(date +%s)
echo -e "\033[33m 描述文件安装脚本执行完毕：$(date "+%Y-%m-%d %H:%M:%S") \033[0m"
echo -e "\033[33m 描述文件安装耗时：$[endDate - startDate]s \033[0m"

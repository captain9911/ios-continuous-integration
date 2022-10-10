#!/bin/bash

#这里要用bash解析，zsh环境jq会出问题。

# 参数1：工程名称 
# 参数2：蒲公英ApiKey

set -euo pipefail

startDate=$(date +%s)
echo -e "\033[33m 脚本执行开始：$(date "+%Y-%m-%d %H:%M:%S") \033[0m"

# 脚本根目录
shPath=$(cd "$(dirname "$0")";pwd)
echo "脚本根目录：$shPath"
# 进入当前文件所在路径
cd "$(dirname "$0")"

# ------------传入的参数-----------------------------------------
# 项目名称
projectName=$1
# 蒲公英apikey，https://www.pgyer.com/account/api
pgyerApiKey=$2
# ----------------------------------------------------------------

targetIpa="../temp/ipa/${projectName}.ipa"

if [ -f  ${targetIpa} ]; then
  echo -e "\033[32m ipa包存在 \033[0m"
else
  echo -e "\033[31m ipa包不存在 \033[0m"
  exit 1
fi

result=$( \
	curl "https://www.pgyer.com/apiv2/app/upload" \
		-F '_api_key='$pgyerApiKey'' \
		-F 'file=@'$targetIpa'' \
)
resultCode=$(echo $result | jq '.code')
if [[ $resultCode = 0 ]]; then
	echo -e "\033[32m 上传成功 \033[0m"
else
	echo -e "\033[31m 上传失败 \033[0m"
	echo $result
	exit 1
fi

# 执行完毕
endDate=$(date +%s)
echo -e "\033[33m 脚本执行完毕：$(date "+%Y-%m-%d %H:%M:%S") \033[0m"
echo -e "\033[33m 耗时：$[endDate - startDate]s \033[0m"

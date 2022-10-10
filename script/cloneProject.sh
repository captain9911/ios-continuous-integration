#!/bin/zsh

# 参数1：工程名称 
# 参数2：工程git地址(https://用户名:密码@仓库地址)

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
# 仓库地址
repoPath=$2
# ----------------------------------------------------------------

# 拉取到本地的位置
localPath="../repository"

echo 本地仓库路径：$localPath
if [ -d ${localPath} ]; then
	echo 本地已存在仓库，删除。
  	rm -rf $localPath
fi

# 拉取代码
git clone ${repoPath} ${localPath}
if [[ $? = 0 ]]; then
  echo -e "\033[32m 拉取代码成功 \033[0m"
else
  echo -e "\033[31m 拉取代码失败 \033[0m"
  exit 1
fi

# 工程根目录
projectPath="${localPath}/${projectName}"
# 进入工程
cd $projectPath
pod install
if [[ $? = 0 ]]; then
  echo -e "\033[32m pod install 成功 \033[0m"
else
  echo -e "\033[31m pod install 失败 \033[0m"
  exit 1
fi

# 执行完毕
endDate=$(date +%s)
echo -e "\033[33m 脚本执行完毕：$(date "+%Y-%m-%d %H:%M:%S") \033[0m"
echo -e "\033[33m 耗时：$[endDate - startDate]s \033[0m"

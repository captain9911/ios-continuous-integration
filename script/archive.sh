#!/bin/zsh

# 参数1：描述文件名称
# 参数2：工程名称
# 参数3：仓库本地路径（GitHub不需要这个参数，传""）

set -euo pipefail

startDate=$(date +%s)
echo -e "\033[33m 打包脚本执行开始：$(date "+%Y-%m-%d %H:%M:%S") \033[0m"

# 脚本根目录
shPath=$(cd "$(dirname "$0")";pwd)
echo "脚本根目录：$shPath"
# 进入当前文件所在路径
cd "$(dirname "$0")"

# ------------传入的参数-----------------------------------------
# 描述文件名称
profileFileName=$1
# 项目名称
projectName=$2
# 仓库路径
repoPath=$3
# ----------------------------------------------------------------

# 项目根目录。（项目根目录为：仓库路径/项目名称）
projectPath=""

if [ "${USER}" = "runner" ]; then
  echo -e "\033[32m 这里是GitHub环境 \033[0m"
  projectPath="../repository/${projectName}"
else
  echo -e "\033[32m 这里非GitHub环境 \033[0m"
  projectPath="${repoPath}/${projectName}"
fi
projectPath="$(cd ${projectPath}; pwd)"

echo "项目根目录：$projectPath"
echo "项目名称：$projectName"

if [ ! -d  ${projectPath} ]; then
  echo -e "\033[31m 项目不存在 \033[0m"
  exit 1
fi

# 创建缓存文件夹
tempPath="../temp"
if [ -d  ${tempPath} ]; then
  # 缓存目录存在
  rm -rf ${tempPath}/*
else
  # 缓存目录不存在
  mkdir -p ${tempPath}
fi
tempPath="$(cd $tempPath; pwd)"

# 描述文件路径
profilesPath="$(cd ../certificate; pwd)/${profileFileName}"
echo "描述文件路径：$profilesPath"

# 打包输出路径
packageOutputPath="${tempPath}/${projectName} $(date "+%Y-%m-%d %H-%M-%S")"
echo "打包输出路径：$packageOutputPath"
mkdir -p $packageOutputPath
# 构建输出路径
archivePath="${packageOutputPath}/${projectName}.xcarchive"
echo "构建路径：$archivePath"
# IPA包输出路径
ipaPath="${tempPath}/ipa"
echo "IPA路径：$ipaPath"

# 描述文件转plist
profilesPlistPath="${tempPath}/profilesPlist.plist"
echo "描述文件转plist：$profilesPlistPath"

security cms -D -i "${profilesPath}" > "${profilesPlistPath}"
if [[ $? = 0 ]]; then
	echo -e "\033[32m 描述文件转plist成功 \033[0m"
else
	echo -e "\033[31m 描述文件转plist失败 \033[0m"
	exit 1
fi

# 读取描述文件中的信息
# 描述文件的命名，不是文件名
profilesName=$(/usr/libexec/PlistBuddy -c 'Print Name' ${profilesPlistPath})
echo "描述文件名称：$profilesName"
# 描述文件的UUID
profilesUUID=$(/usr/libexec/PlistBuddy -c 'Print UUID' ${profilesPlistPath})
echo "描述文件UUID：$profilesUUID"
# 组织，公司英文名称
profilesTeamName=$(/usr/libexec/PlistBuddy -c 'Print TeamName' ${profilesPlistPath})
echo "团队名称：$profilesTeamName"
# 用户ID，组织单位
profilesTeamId=$(/usr/libexec/PlistBuddy -c 'Print TeamIdentifier:0' ${profilesPlistPath})
echo "团队ID：$profilesTeamId"
# 描述文件中的AppId，结构为"团队ID.BundleID"
profilesAppId=$(/usr/libexec/PlistBuddy -c 'Print Entitlements:application-identifier' ${profilesPlistPath})
# bundleId为描述文件中的AppId去除前面的团队Id
productBundleId=${profilesAppId#*.}
echo "ProductBundleID：$productBundleId"
# 描述文件类型
apsEnvironment=$(/usr/libexec/PlistBuddy -c 'Print Entitlements:aps-environment' ${profilesPlistPath})
if [[ "${apsEnvironment}" = "production" ]]; then
  codeSignId="iPhone Distribution: ${profilesTeamName}"
else
  codeSignId="iPhone Development: ${profilesTeamName}"
fi
echo "代码签名Id：$codeSignId"

# IPA导出配置
exportPlistFilePath="${tempPath}/ExportOptions.plist"
echo "IPA导出配置：$exportPlistFilePath"

# 这里操作的必须是一个绝对路径
defaults write ${exportPlistFilePath} "teamID" "${profilesTeamId}"
defaults write ${exportPlistFilePath} "method" "development"
defaults write ${exportPlistFilePath} "provisioningProfiles" "<dict>
          <key>${productBundleId}</key>
          <string>${profilesName}</string>
        </dict>"

if [ -f  ${exportPlistFilePath} ]; then
  echo -e "\033[32m 配置文件创建成功 \033[0m"
else
  echo -e "\033[31m 配置文件创建失败 \033[0m"
  exit 1
fi

# 开始构建
# 构建模式：Release或Debug
configuration=Debug

# 清除缓存
xcodebuild clean \
  -project "${projectPath}"/"${projectName}".xcodeproj \
  -configuration "${configuration}" \
  -alltargets | xcpretty
if [[ $? = 0 ]]; then
  echo -e "\033[32m 清理成功 \033[0m"
else
  echo -e "\033[31m 清理失败 \033[0m"
  exit 1
fi

# 构建
xcodebuild archive \
  -workspace "${projectPath}"/"${projectName}".xcworkspace \
  -scheme "${projectName}"\
  -sdk iphoneos \
  -configuration "$configuration" \
  -archivePath "${archivePath}" | xcpretty

if [ -d  ${archivePath} ]; then
  echo -e "\033[32m 构建成功 \033[0m"
else
  echo -e "\033[31m 构建失败 \033[0m"
  exit 1
fi

# 导出IPA
xcodebuild export \
  -archivePath "${archivePath}" \
  -exportOptionsPlist "${exportPlistFilePath}" \
  -exportPath "${ipaPath}" \
  -exportArchive | xcpretty

ipaFilePath="$ipaPath"/${projectName}.ipa
if [ -f  ${ipaFilePath} ]; then
  echo -e "\033[32m 导出IPA成功 \033[0m"
else
  echo -e "\033[31m 导出IPA失败 \033[0m"
  exit 1
fi

# 执行完毕
endDate=$(date +%s)
echo -e "\033[33m 打包脚本执行完毕：$(date "+%Y-%m-%d %H:%M:%S") \033[0m"
echo -e "\033[33m 打包耗时：$[endDate - startDate]s \033[0m"

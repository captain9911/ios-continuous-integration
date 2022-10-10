#!/bin/zsh

set -euo pipefail

# ------------这里需要修改-----------------------------------------
# mac 密码
macPassword=macpwd
# 开发证书
devCertificate=dev.p12
# 证书密码
devCerPassword=cerpwd
# 描述文件
devProfile=dev.mobileprovision
# 工程名称
projectName=IOSProjectDemo
# 仓库本地路径
projectPath=/Users/Mr/Desktop/demo/
# 蒲公英ApiKey
pgyerApiKey=key
# ----------------------------------------------------------------

echo -e "\033[32m macOS 版本号 \033[0m"
sw_vers
echo -e "\033[32m Xcode 版本号 \033[0m"
xcodebuild -version
echo -e "\033[32m CocoaPods 版本号 \033[0m"
pod --version
# mac要是已经安装了xcpretty，就把这两行注释掉
echo -e "\033[32m 安装xcpretty \033[0m"
echo ${macPassword} | sudo -S gem install xcpretty

# 进入当前文件所在路径
cd "$(dirname "$0")"

./script/installCertificate.sh ${devCertificate} ${devCerPassword} ${macPassword}
./script/installProfile.sh ${devProfile}
./script/archive.sh ${projectName} ${projectPath}
./script/publish.sh ${projectName} ${pgyerApiKey}

#!/bin/zsh

# 参数1：开发证书名称 
# 参数2：证书密码 
# 参数3：mac钥匙串登录密码（GitHub为""）

set -euo pipefail

startDate=$(date +%s)
echo -e "\033[33m 证书安装脚本执行开始：$(date "+%Y-%m-%d %H:%M:%S") \033[0m"

# 脚本根目录
shPath=$(cd "$(dirname "$0")";pwd)
echo "脚本根目录：$shPath"
# 进入当前文件所在路径
cd "$(dirname "$0")"

# ------------传入的参数-----------------------------------------
# 证书名称，文件要放在../certificate目录下
certificateName=$1
# 证书密码
certificatePwd=$2
# mac钥匙串”登录“密码，默认与mac密码相同，github上不需要密码。
keychainLoginPwd=$3
# ----------------------------------------------------------------

# 证书路径
certificateFilePath="../certificate/${certificateName}"
echo "证书文件路径：$certificateFilePath"

if [ -f  ${certificateFilePath} ]; then
  echo -e "\033[32m 证书文件存在 \033[0m"
else
  echo -e "\033[31m 证书文件不存在 \033[0m"
  exit 1
fi

# ------------本地打包用这个方式安装证书--------------------------------
# 解锁钥匙串
unlockKeychain() {
  # 获取钥匙串”登录“密码
  if [[ ! ${keychainLoginPwd} ]]; then
    read -sp "输入钥匙串登录密码：" keychainLoginPwd
  else
    echo "已存在钥匙串密码"
  fi
  # 解锁钥匙串，当钥匙串“登录”为解锁状态时，不会去验证密码，直接通过。
  security unlock-keychain -p "${keychainLoginPwd}" ~/Library/Keychains/login.keychain
  if [[ $? = 0 ]]; then
    echo -e "\033[32m 解锁钥匙串成功 \033[0m"
  else
    echo -e "\033[31m 解锁钥匙串失败 \033[0m"
    keychainLoginPwd=""
    unlockKeychain
    exit 1
  fi
}

# 安装证书
importCertificate() {
  # 获取证书密码
  if [[ ! ${certificatePwd} ]]; then
    read -sp "输入证书密码：" certificatePwd
  else
    echo "已存在证书密码"
  fi
  # 证书安装
  security import ${certificateFilePath} -k ~/Library/Keychains/login.keychain -P "${certificatePwd}" -T /usr/bin/codesign
  if [[ $? = 0 ]]; then
    echo -e "\033[32m 证书安装成功 \033[0m"
  else
    echo -e "\033[31m 证书安装失败 \033[0m"
    certificatePwd=""
    importCertificate
    exit 1
  fi
}
# ----------------------------------------------------------------

# ------------Github Action 打包用这个方式安装证书-------------------
githubInstallCertificate() {
  security create-keychain -p "" build.keychain
  security import ${certificateFilePath} -t agg -k ~/Library/Keychains/build.keychain -P "${certificatePwd}" -A
  security list-keychains -s ~/Library/Keychains/build.keychain
  security default-keychain -s ~/Library/Keychains/build.keychain
  security unlock-keychain -p "" ~/Library/Keychains/build.keychain
  security set-key-partition-list -S apple-tool:,apple: -s -k "" ~/Library/Keychains/build.keychain
}
# ----------------------------------------------------------------

if [ "${USER}" = "runner" ]; then
  echo -e "\033[32m 这里是GitHub环境 \033[0m"
  githubInstallCertificate
else
  echo -e "\033[32m 这里非GitHub环境 \033[0m"
  unlockKeychain
  importCertificate
fi

# 执行完毕
endDate=$(date +%s)
echo -e "\033[33m 证书安装脚本执行完毕：$(date "+%Y-%m-%d %H:%M:%S") \033[0m"
echo -e "\033[33m 证书安装耗时：$[endDate - startDate]s \033[0m"

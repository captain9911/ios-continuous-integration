# iOS持续集成
适用于项目源码存放在任意Git平台的场景。双击脚本文件，可自动在GitHub的虚拟机上实现拉取源码、编译、打包、发布内测版本至蒲公英等操作。不会占用本地Mac机器资源。发布成功后，蒲公英绑定的邮箱会收到邮件提醒。
> 如果项目源码位于GitHub，可将这个工程的内容直接拷贝到源码仓库下，可实现push源码后，自动打包发布。

## 需要准备的资源
* 开发证书、证书密码
* 描述文件
* 源码git仓库地址、用户名、密码
* 蒲公英ApiKey
* GitHub Token
* GitHub 用户名、仓库名称

## 使用方法
### 私有化部署
下载该仓库，将所有内容上传至自己的GitHub私有仓库内（包括隐藏的.github文件夹）。
### 开发证书及描述文件
开发证书及描述文件必须放置在仓库的`/certificate`下，文件命名可随意。
### 对源码仓库有些要求
工程文件夹存放在源码git仓库的根目录下。
### 参数配置
修改`/.github/workflows/release-ipa.yml`文件，根据文件中的注释，传入对应的参数。
### 源码git仓库地址
源码git仓库url的组成：`https://用户名:密码@仓库地址`
### 蒲公英ApiKey的获取
获取蒲公英的[ApiKey](https://www.pgyer.com/account/api)
### GitHub Token 的获取
获取GitHub [Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token#creating-a-token)

### 手动触发打包
* 修改文件`execute-action.command`的内容。

```
#!/bin/bash

# ------------这里需要修改-----------------------------------------
# GitHub Token
token=xxx
# GitHub 用户名
userName=xxx
# GitHub 仓库名称
repoName=xxx
# ----------------------------------------------------------------

curl \
  -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token ${token}" \
  https://api.github.com/repos/${userName}/${repoName}/actions/workflows/release-ipa.yml/dispatches \
  -d '{"ref":"main","inputs":{}}'


```

### 触发脚本的使用
双击`execute-action.command`文件。

<hr>

## 对于ssh协议的git仓库，以及svn仓库 
有时间再折腾，先用下面这个方法应付下：
### 打包本地的仓库
* 所有流程均在本地进行，与GitHub无关。
* 修改文件`release-local.command`的内容。
* 双击`release-local.command`文件。
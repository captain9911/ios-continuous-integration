#!/bin/bash

# ------------这里需要修改-----------------------------------------
# GitHub Token
token=githubtoken
# GitHub 用户名
userName=captain9911
# GitHub 仓库名称
repoName=ios-continuous-integration
# ----------------------------------------------------------------

curl \
  -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token ${token}" \
  https://api.github.com/repos/${userName}/${repoName}/actions/workflows/release-ipa.yml/dispatches \
  -d '{"ref":"main","inputs":{}}'



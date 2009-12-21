#!/bin/bash
##########################################################
# auther guangzhao(guangzhao@taobao.com)
# put in /var/tpm/create/packagename.sh
# 描述：这个shell脚本主要是
#  tpm install/update packagename dev/tst/prd组合应用
##########################################################

# 该函数内的

# dev环境下执行的shell命令
function dev()
{
  # shell命令,编写您在开发环境装完包后执行的命令
  echo "dev"
}

# tst环境下执行的shell命令
function tst()
{
  # shell命令,编写您在测试环境装完包后执行的命令
  echo "tst"
}

# dev环境下执行的shell命令
function prd()
{
  # shell命令,编写您在生产环境装完包后执行的命令
  echo "prd"
}

# 执行命令部分
$1





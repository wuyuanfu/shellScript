#!/bin/bash
## Edit by wuyuanfu
## Date 20130416
## Usage ./risktools.sh
## Please check the parameter $oprpath is right
clear
oprpath="/home/risk/oprdispatcher"
tradingday=`date +%Y%m%d`
function killriskfront3()
{
  pidinfo=`ps -ef|grep riskfront |grep -v grep`
  pidlist=`ps -ef|grep riskfront |grep -v grep |awk '{print $2,$3}'`
  if [ "${pidlist}" == '' ];then
    echo -e "\033[1;31m\nriskfront 3 pid not found!\033[0m\n"
    exit 1
  fi
  echo -e "${pidinfo}"
  echo -n "Are you sure(Y/N)?  "
  read opt
  if [ "${opt}" == "Y" ] || [ "${opt}" == "y" ];then
    kill -9 ${pidlist}
    if [ $? -eq 0 ]; then
      echo -e "\033[1;42mriskfront 3 is killed\n\033[0m"
    fi
  fi
}
function showriskfront()
{
  pidinfo=`ps -ef|grep riskfront |grep -v grep` 
  if [ "${pidinfo}" != '' ];then
    echo -e "\n${pidinfo}\n\n"
  else
    echo -e "\033[1;41m\nriskfront  not found!\033[0m\n"
  fi
}
function importuserevent()
{
  if [ -d ${oprpath} ];then 
    cd ${oprpath}
  else
    echo -e "\n\033[1;41m${oprpath} is not found!!\033[0m\n\n"&& exit 3
  fi 
  echo -e "Today is trading day is \033[32m${tradingday}\033[0m\n"
  echo -ne "Enter Y|y  to import the brokeruserevent into database [Y/N]: "
  read chs
  if [ "${chs}" == "Y" ] || [ "${chs}" == "y" ];then
    ./oprdispatcher.sh ${tradingday} && echo -e "\033[32mBrokeruserevent import completed\033[0m\n"
  else
    echo -e "\033[32mYou cancel the import operation\033[0m\n" && exit 2
  fi
}
function menu()
{
  echo -e "\033[1;33m1. Show riskfront processes\033[0m"
  echo -e "\033[1;33m2. Kill the riskfront 3 process \033[0m"
  echo -e "\033[1;33m3. Import the brokeruserevent into database \033[0m"
  echo -e "\033[1;33m0. Do nothing && Exit\033[0m"
  echo -ne "\033[1;33mPlease enter your choose: \033[0m "
}
if [ $* > 0 ];then
  echo "Usage:\.\/$basename"
  exit 3
fi 
menu
read slt
while :
do
  case ${slt} in
  1) showriskfront
     menu
     read slt
  ;;
  2) killriskfront3
     menu
     read slt
  ;;
  3) importuserevent
     menu
     read slt
  ;;
  0) exit 0
  ;;
  *) clear
     echo -e "\033[1;41mEnter the WRONG number.\033[0m"
     menu
     read slt
  esac
done

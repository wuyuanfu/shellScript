#!/bin/bash
##Create by wuyuanfu
##Date 2013-09-16
##Version 20131012-1
##ChangLog
#### 20131012-1  更改流水备份目录存放在组件的安装目录的FLOWBACKUP目录

PWD=`cat ~/shell/sh.cfg|grep passwd|cut -d= -f2`
BAKPATH="$1"
ndays=7
DATE=`date +%Y%m%d`
BACKUPPATH=FLOWBACKUP
flowpath="FLOWBACKUP/flow"
logpath="FLOWBACKUP/log"
rm ~/shell/BACKUPLISTTMP
cat ~/shell/list|grep -Ev '^#' |grep -Ev '^$' >~/shell/BACKUPLISTTMP
exec 3<~/shell/BACKUPLISTTMP
function makebackuppath(){
  while read line <&3
	do
		name=`echo $line|awk '{print $1}'`
		num=`echo $line|awk '{print $2}'`
		list="${name}${num}"
		if [ "${num}" != "csv" ];then
			ssh ${list} "mkdir -pv ~/${list}/${BACKUPPATH}"
			echo -e "Backup directory of ${list} ,~/${list}/${BACKUPPATH} has been created!\n"
		else
			ssh ${name} "mkdir -pv ~/${name}/${BACKUPPATH}"
			echo -e "Backup directory of ${name} ,~/${name}/${BACKUPPATH} has been created!\n"		
		fi
	done
}
if [ "$1" == "makebackuppath" ];then
	makebackuppath
	exit
fi
if [ $PWD != "" ]
then
	printf "Please input passwd:\n"
	stty -echo
	read inpwd
	stty echo
	if [ "$inpwd" = "$PWD" ]
	then
########调用ecall.sh清理流水
		ecall.sh clean
		while read line <&3
		do
			name=`echo $line|awk '{print $1}'`
			num=`echo $line|awk '{print $2}'`
			list="${name}${num}"
			if [ "${num}" != "csv" ];then
				echo "Restore the flow and log files of  ${list} ,Please waitting..."
#################恢复flow流水文件
				ssh ${list} "cp -vpf ~/${list}/${BACKUPPATH}/${BAKPATH}/flow/* ~/${list}/flow"
#################恢复log日志文件				
				ssh ${list} "cp -vpf ~/${list}/${BACKUPPATH}/${BAKPATH}/log/* ~/${list}/log"
				echo -e "Restore ${list}'s flow and log completed"
			else
				echo "Restore the flow and log files of  ${name} ,Please waitting..."
#################恢复flow流水文件
				ssh ${list} "cp -vpf ~/${list}/${BACKUPPATH}/${BAKPATH}/flow/* ~/${list}/flow"
#################恢复log日志文件				
				ssh ${list} "cp -vpf ~/${list}/${BACKUPPATH}/${BAKPATH}/log/* ~/${list}/log"
				echo -e "Restore ${name}\'s flow and log completed"
			fi
			echo -e "\n"
		done >>~/asptools/log/flowRestore_${DATE}
		rm -f .backuped_${DATE}
		exec 3>&- 
	else
			echo "Invalid password!!!"
		exit
	fi
fi

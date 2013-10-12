#!/bin/bash
##Create by wuyuanfu
##Date 2013-09-16
##Version 20131012-1
##ChangLog
#### 20131012-1  更改流水备份目录存放在组件的安装目录的FLOWBACKUP目录
BAKPATH=`date +%Y%m%d-%H%M%S`
PWD=`cat ~/shell/sh.cfg|grep passwd|cut -d= -f2`
ndays=`date -d "-7 day" +%Y%m%d`
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
			ssh ${list} "mkdir -pv ~/${list}/${flowpath} ~/${list}/${logpath}"
			echo -e "Backup directory of ${list} ,[flow/backup and log/backup] has been created!\n"
		else
			ssh ${name} "mkdir -pv ~/${name}/${flowpath} ~/${name}/${logpath}"
			echo -e "Backup directory of ${name} ,[flow/backup and log/backup] has been created!\n"		
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
				echo "Restore the flow and log files of  ${lsit} ,Please waitting..."
#################恢复flow流水文件
				ssh ${list} "cp -vf ~/${list}/${flowpath}/* ~/${list}/flow"
#################恢复log日志文件				
				ssh ${list} "cp -vf ~/${list}/${logpath}/* ~/${list}/log"
				echo -e "Restore ${list}'s flow and log completed"
			else
				echo "Restore the flow and log filesof  ${name} ,Please waitting..."
#################恢复flow流水文件
				ssh ${name} "cp -vf ~/${name}/${flowpath}/* ~/${name}/flow"
#################恢复log日志文件				
				ssh ${name} "cp -vf ~/${name}/${logpath}/* ~/${name}/log"
				echo -e "Restore ${name}'s flow and log completed"
			fi
			echo -e "\n"
		done
		rm -f .backuped
		exec 3>&- 
	else
			echo "Invalid password!!!"
		exit
	fi
fi

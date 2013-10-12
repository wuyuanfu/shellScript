#!/bin/bash
##Create by wuyuanfu 
##Date 2013-10-12
##Version 20131012-1
## 请把脚本放在config机的asptools目录，添加执行权限。
## 第一次备份之前请先执行flowBackup.sh makebackuppath创建流水备份目录
##ChangeLog
## 20131012-1  更改流水备份目录存放在组件的安装目录的FLOWBACKUP目录,
###			   同时增加备份完成确认标志，避免重复备份时，测试流水覆盖正式流水。
BAKPATH=`date +%Y%m%d-%H%M%S`
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
			echo -e "Backup directory of ${list} ,${flowpath} and ${logpath} has been created!\n"
		else
			ssh ${name} "mkdir -pv ~/${name}/${flowpath} ~/${name}/${logpath}"
			echo -e "Backup directory of ${name} ,${flowpath} and ${logpath} has been created!\n"		
		fi
	done
}
if [ "$1" == "makebackuppath" ];then
	makebackuppath
	exit
fi
if [ -e .backuped ];then
	echo -e "You have backuped the flow and log files..."
	echo -en 'Enter Y the backup again[y/n]:  '
	read -n1 choose
	if [ "${choose}" == "Y" ] || [ "${choose}" == "y" ];then
		while read line <&3
		do
			name=`echo $line|awk '{print $1}'`
			num=`echo $line|awk '{print $2}'`
			list="${name}${num}"
			if [ "${num}" != "csv" ];then
				echo "Backup the flow and log files of ${list}, Please waitting..."
##################删除历史备份文件
				ssh ${list} "rm -f ~/${list}/${flowpath}/* ~/${list}/${logpath}/*"  
##################备份flow目录
				ssh ${list} "cp -vf ~/${list}/flow/* ~/${list}/${flowpath}/"
##################备份log目录
				ssh ${list} "cp -vf ~/${list}/log/* ~/${list}/${logpath}/"
				echo -e "Backup ${list}'s flow and log completed"
			else
				echo "Backup the flow and log files of ${name}, Please waitting..."
###################删除历史备份文件
				ssh ${name} "rm -f ~/${name}/${flowpath}/* ~/${name}/${logpath}/*"  
###################备份flow目录
				ssh ${name} "cp -vf ~/${name}/flow/* ~/${name}/${flowpath}/"
###################备份log目录
				ssh ${name} "cp -vf ~/${name}/log/* ~/${name}/${logpath}/"
				echo -e "Backup ${name}'s flow and log completed"		
			fi
			echo -e "\n"
		done
	else
		exit
	fi
else
	while read line <&3
	do
		name=`echo $line|awk '{print $1}'`
		num=`echo $line|awk '{print $2}'`
		list="${name}${num}"
		if [ "${num}" != "csv" ];then
			echo "Backup the flow and log files of ${list}, Please waitting..."
###############删除历史备份文件
			ssh ${list} "rm -f ~/${list}/${flowpath}/* ~/${list}/${logpath}/*"  
###############备份flow目录
			ssh ${list} "cp -vf ~/${list}/flow/* ~/${list}/${flowpath}/"
###############备份log目录
			ssh ${list} "cp -vf ~/${list}/log/* ~/${list}/${logpath}/"
			echo -e "Backup ${list}'s flow and log completed"
		else
			echo "Backup the flow and log files of ${name}, Please waitting..."
###############删除历史备份文件
			ssh ${name} "rm -f ~/${name}/${flowpath}/* ~/${name}/${logpath}/*"  
###############备份flow目录
			ssh ${name} "cp -vf ~/${name}/flow/* ~/${name}/${flowpath}/"
###############备份log目录
			ssh ${name} "cp -vf ~/${name}/log/* ~/${name}/${logpath}/"
			echo -e "Backup ${name}'s flow and log completed"		
		fi
		echo -e "\n"
	done
fi
touch .backuped
exec 3>&- 

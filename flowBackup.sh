#!/bin/bash
##Create by wuyuanfu 
##Date 2013-10-12
##Version 20131012-1
## 请把脚本放在config机的asptools目录，添加执行权限。
## 第一次备份之前请先执行flowBackup.sh makebackuppath创建流水备份目录
##ChangeLog
## 20131012-1  更改流水备份目录存放在组件的安装目录的FLOWBACKUP目录,
###			   同时增加备份完成确认标志，避免重复备份时，测试流水覆盖正式流水。
###20190426-1  新增大商所bin目录dat文件备份
###20201207-1  修改流水MD5校验方式

BAKPATH=`date +%Y%m%d-%H%M%S`
ndays=7
DATE=`date +%Y%m%d`
BACKUPPATH=FLOWBACKUP
BASEPATH=`getcfg.sh BasePath`
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
			ssh ${list} "mkdir -pv ${BASEPATH%*/}/${list}/${BACKUPPATH}"
			echo -e "Backup directory of ${list} ,${BASEPATH%*/}/${list}/${BACKUPPATH} has been created!\n"
		else
			ssh ${name} "mkdir -pv ${BASEPATH%*/}/${name}/${BACKUPPATH}"
			echo -e "Backup directory of ${name} ,${BASEPATH%*/}/${name}/${BACKUPPATH} has been created!\n"		
		fi
	done
  echo "function makebackuppath:$BAKPATH" >>${BASEPATH%*/}/asptools/log/flowBackup.log
}
function fileCheck(){
	for file in $(ssh $1 "ls ${BASEPATH%*/}/$1/$2/$3/$4/")
	do
		md5A=$(ssh $1 "md5sum ${BASEPATH%*/}/$1/$2/$3/$4/$file" |awk '{print $1}')
		md5B=$(ssh $1 "md5sum ${BASEPATH%*/}/$1/$4/$file" |awk '{print $1}')
		if [ "$md5A" != "$md5B" ]
		then
			echo ---ERROR: MD5SUM of ${BASEPATH%*/}/$1/$4/$file is diff.
			exit 110
		fi
	done
}
if [ "$1" == "makebackuppath" ];then
	makebackuppath
	exit
fi
if [ -e .backuped_${DATE} ];then
	echo -e "You have backuped the flow and log files..."
	echo -en 'Enter Y the backup again[y/n]:  '
	read -n1 choose
	echo
	if [ "${choose}" == "Y" ] || [ "${choose}" == "y" ];then
		while read line <&3
		do
			name=`echo $line|awk '{print $1}'`
			num=`echo $line|awk '{print $2}'`
			list="${name}${num}"
			if [ "${num}" != "csv" ];then
				echo "Backup the flow and log files of ${list}, Please waitting..."
##################删除历史备份文件
############### ssh ${list} "rm -rf ${BASEPATH%*/}/${list}/${flowpath}/* ${BASEPATH%*/}/${list}/${logpath}/*"  
				ssh ${list} "find ${BASEPATH%*/}/${list}/${BACKUPPATH}/* -mtime +${ndays} -type d |xargs rm -rf" 
##################备份flow目录
				ssh ${list} "mkdir -pv ${BASEPATH%*/}/${list}/${BACKUPPATH}/${BAKPATH}/flow"
				ssh ${list} "cp -vp ${BASEPATH%*/}/${list}/flow/* ${BASEPATH%*/}/${list}/${BACKUPPATH}/${BAKPATH}/flow/"	
				fileCheck ${list} ${BACKUPPATH} ${BAKPATH} flow				
##################备份log目录
				ssh ${list} "mkdir -pv ${BASEPATH%*/}/${list}/${BACKUPPATH}/${BAKPATH}/log"
				ssh ${list} "cp -vp ${BASEPATH%*/}/${list}/log/* ${BASEPATH%*/}/${list}/${BACKUPPATH}/${BAKPATH}/log"
				fileCheck ${list} ${BACKUPPATH} ${BAKPATH} log
				echo -e "Backup ${list}\'s flow and log has completed"
			else
				echo "Backup the flow and log files of ${name}, Please waitting..."
##################删除历史备份文件
############### ssh ${name} "rm -rf ${BASEPATH%*/}/${name}/${flowpath}/* ${BASEPATH%*/}/${name}/${logpath}/*"  
				ssh ${name} "find ${BASEPATH%*/}/${name}/${BACKUPPATH}/* -mtime +${ndays} -type d |xargs rm -rf" 
##################备份flow目录
				ssh ${name} "mkdir -pv ${BASEPATH%*/}/${name}/${BACKUPPATH}/${BAKPATH}/flow"
				ssh ${name} "cp -vp ${BASEPATH%*/}/${name}/flow/* ${BASEPATH%*/}/${name}/${BACKUPPATH}/${BAKPATH}/flow/"
				fileCheck ${name} ${BACKUPPATH} ${BAKPATH} flow				
##################备份log目录
				ssh ${name} "mkdir -pv ${BASEPATH%*/}/${name}/${BACKUPPATH}/${BAKPATH}/log"
				ssh ${name} "cp -vp ${BASEPATH%*/}/${name}/log/* ${BASEPATH%*/}/${name}/${BACKUPPATH}/${BAKPATH}/log"
				fileCheck ${name} ${BACKUPPATH} ${BAKPATH} log
				echo -e "Backup ${name}'s flow and log has completed"		
			fi
####增加大商所bin目录流水备份
			if [ "${name}" == "dceoffer" ] || [ "${name}" == "dcemdserver" ];then
				ssh ${list} "mkdir -pv ${BASEPATH%*/}/${list}/${BACKUPPATH}/${BAKPATH}/bin"
				ssh ${list} "cp -vp ${BASEPATH%*/}/${list}/bin/*dat ${BASEPATH%*/}/${list}/${BACKUPPATH}/${BAKPATH}/bin/"	
				fileCheck ${list} ${BACKUPPATH} ${BAKPATH} bin
				echo -e "Backup ${list}\'s bin has completed"
			fi
			echo -e "\n"
		done >>~/asptools/log/flowBackup_${DATE}
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
##################删除历史备份文件
############### ssh ${list} "rm -rf ${BASEPATH%*/}/${list}/${flowpath}/* ${BASEPATH%*/}/${list}/${logpath}/*"  
			ssh ${list} "find ${BASEPATH%*/}/${list}/${BACKUPPATH}/* -mtime +${ndays} -type d |xargs rm -rf" 
##################备份flow目录
			ssh ${list} "mkdir -pv ${BASEPATH%*/}/${list}/${BACKUPPATH}/${BAKPATH}/flow"
			ssh ${list} "cp -vp ${BASEPATH%*/}/${list}/flow/* ${BASEPATH%*/}/${list}/${BACKUPPATH}/${BAKPATH}/flow/"
			fileCheck ${list} ${BACKUPPATH} ${BAKPATH} flow			
##################备份log目录
			ssh ${list} "mkdir -pv ${BASEPATH%*/}/${list}/${BACKUPPATH}/${BAKPATH}/log"
			ssh ${list} "cp -vp ${BASEPATH%*/}/${list}/log/* ${BASEPATH%*/}/${list}/${BACKUPPATH}/${BAKPATH}/log"
			fileCheck ${list} ${BACKUPPATH} ${BAKPATH} log
			echo -e "Backup ${list}\'s flow and log completed"
		else
			echo "Backup the flow and log files of ${name}, Please waitting..."
##################删除历史备份文件
############### ssh ${name} "rm -rf ${BASEPATH%*/}/${name}/${flowpath}/* ${BASEPATH%*/}/${name}/${logpath}/*"  
			ssh ${name} "find ${BASEPATH%*/}/${name}/${BACKUPPATH}/* -mtime +${ndays} -type d |xargs rm -rf" 
##################备份flow目录
			ssh ${name} "mkdir -pv ${BASEPATH%*/}/${name}/${BACKUPPATH}/${BAKPATH}/flow"
			ssh ${name} "cp -vp ${BASEPATH%*/}/${name}/flow/* ${BASEPATH%*/}/${name}/${BACKUPPATH}/${BAKPATH}/flow/"
			fileCheck ${name} ${BACKUPPATH} ${BAKPATH} flow			
##################备份log目录
			ssh ${name} "mkdir -pv ${BASEPATH%*/}/${name}/${BACKUPPATH}/${BAKPATH}/log"
			ssh ${name} "cp -vp ${BASEPATH%*/}/${name}/log/* ${BASEPATH%*/}/${name}/${BACKUPPATH}/${BAKPATH}/log"
			fileCheck ${name} ${BACKUPPATH} ${BAKPATH} log
			echo -e "Backup ${name}'s flow and log completed"		
		fi
####增加大商所bin目录流水备份
		if [ "${name}" == "dceoffer" ] || [ "${name}" == "dcemdserver" ];then
			ssh ${list} "mkdir -pv ${BASEPATH%*/}/${list}/${BACKUPPATH}/${BAKPATH}/bin"
			ssh ${list} "cp -vp ${BASEPATH%*/}/${list}/bin/*dat ${BASEPATH%*/}/${list}/${BACKUPPATH}/${BAKPATH}/bin/"	
			fileCheck ${list} ${BACKUPPATH} ${BAKPATH} bin
			echo -e "Backup ${list}\'s bin has completed"
		fi		
		echo -e "\n"
	done >>~/asptools/log/flowBackup_${DATE}
fi
touch .backuped_${DATE}
echo "flowBackup at :${BAKPATH}">>~/asptools/log/flowBackup.log
exec 3>&- 

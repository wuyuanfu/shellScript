#!/bin/bash
##Create by wuyuanfu
##Date 2013-09-16
##Version 20131012-1
##ChangLog
#### 20131012-1  更改流水备份目录存放在组件的安装目录的FLOWBACKUP目录
#### 20190426-1  新增dce报盘bin目录的流水恢复
#### 20201207-1  修改MD5校验方式

PWD=`cat ~/shell/sh.cfg|grep passwd|cut -d= -f2`
if [ "x$1" == "x" ];then
	echo -----Usage: flowRestore.sh TRADINGDAY
	exit
fi
BAKPATH="$1"
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
}
if [ "$1" == "makebackuppath" ];then
	makebackuppath
	exit
fi
function fileCheck(){
	for file in $(ssh $1 "ls  ${BASEPATH%*/}/$1/$2/$3/$4/")
	do
		md5A=$(ssh $1 "md5sum ${BASEPATH%*/}/$1/$2/$3/$4/$file |awk '{print $1}'")
		md5B=$(ssh $1 "md5sum ${BASEPATH%*/}/$1/$4/$file |awk '{print $1}'")
		if [ "$md5A" != "$md5B" ]
		then
			echo ---ERROR: MD5SUM of ${BASEPATH%*/}/$1/$4/$file is diff.
			exit 110
		fi
	done
}
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
				ssh ${list} "cp -vpf ${BASEPATH%*/}/${list}/${BACKUPPATH}/${BAKPATH}/flow/* ${BASEPATH%*/}/${list}/flow"
				fileCheck ${list} ${BACKUPPATH} ${BAKPATH} flow
#################恢复log日志文件				
				ssh ${list} "cp -vpf ${BASEPATH%*/}/${list}/${BACKUPPATH}/${BAKPATH}/log/* ${BASEPATH%*/}/${list}/log"
				fileCheck ${list} ${BACKUPPATH} ${BAKPATH} log				
				echo -e "Restore ${list}'s flow and log completed"
			else
				echo "Restore the flow and log files of  ${name} ,Please waitting..."
#################恢复flow流水文件
				ssh ${name} "cp -vpf ${BASEPATH%*/}/${name}/${BACKUPPATH}/${BAKPATH}/flow/* ${BASEPATH%*/}/${name}/flow"
				fileCheck ${name} ${BACKUPPATH} ${BAKPATH} flow				
#################恢复log日志文件				
				ssh ${name} "cp -vpf ${BASEPATH%*/}/${name}/${BACKUPPATH}/${BAKPATH}/log/* ${BASEPATH%*/}/${name}/log"
				fileCheck ${name} ${BACKUPPATH} ${BAKPATH} log				
				echo -e "Restore ${name}\'s flow and log completed"				
			fi
####增加大商所bin目录流水恢复
			if [ "${name}" == "dceoffer" ] || [ "${name}" == "dcemdserver" ];then
				ssh ${list} "cp -vpf ${BASEPATH%*/}/${list}/${BACKUPPATH}/${BAKPATH}/bin/* ${BASEPATH%*/}/${list}/bin/ "	
				fileCheck ${list} ${BACKUPPATH} ${BAKPATH} bin
				echo -e "Restore ${list}\'s bin has completed"
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

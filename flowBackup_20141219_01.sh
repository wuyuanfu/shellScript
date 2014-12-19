#!/bin/bash
##Create by wuyuanfu 
##Date 2013-10-12
##Version 20131012-1
## ��ѽű�����config����asptoolsĿ¼�����ִ��Ȩ�ޡ�
## ��һ�α���֮ǰ����ִ��flowBackup.sh makebackuppath������ˮ����Ŀ¼
##ChangeLog
## 20131012-1  ������ˮ����Ŀ¼���������İ�װĿ¼��FLOWBACKUPĿ¼,
###			   ͬʱ���ӱ������ȷ�ϱ�־�������ظ�����ʱ��������ˮ������ʽ��ˮ��
BAKPATH=`date +%Y%m%d-%H%M%S`
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
##################ɾ����ʷ�����ļ�
############### ssh ${list} "rm -rf ~/${list}/${flowpath}/* ~/${list}/${logpath}/*"  
				ssh ${list} "find ~/${list}/${BACKUPPATH}/* -mtime +${ndays} -type d |xargs rm -rf" 
##################����flowĿ¼
				ssh ${list} "mkdir -pv ~/${list}/${BACKUPPATH}/${BAKPATH}/flow"
				ssh ${list} "cp -vp ~/${list}/flow/* ~/${list}/${BACKUPPATH}/${BAKPATH}/flow/"				
##################����logĿ¼
				ssh ${list} "mkdir -pv ~/${list}/${BACKUPPATH}/${BAKPATH}/log"
				ssh ${list} "cp -vp ~/${list}/log/* ~/${list}/${BACKUPPATH}/${BAKPATH}/log"
				echo -e "Backup ${list}\'s flow and log completed"
			else
				echo "Backup the flow and log files of ${name}, Please waitting..."
##################ɾ����ʷ�����ļ�
############### ssh ${name} "rm -rf ~/${name}/${flowpath}/* ~/${name}/${logpath}/*"  
				ssh ${name} "find ~/${name}/${BACKUPPATH}/* -mtime +${ndays} -type d |xargs rm -rf" 
##################����flowĿ¼
				ssh ${name} "mkdir -pv ~/${name}/${BACKUPPATH}/${BAKPATH}/flow"
				ssh ${name} "cp -vp ~/${name}/flow/* ~/${name}/${BACKUPPATH}/${BAKPATH}/flow/"				
##################����logĿ¼
				ssh ${name} "mkdir -pv ~/${name}/${BACKUPPATH}/${BAKPATH}/log"
				ssh ${name} "cp -vp ~/${name}/log/* ~/${name}/${BACKUPPATH}/${BAKPATH}/log"
				echo -e "Backup ${name}'s flow and log completed"		
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
##################ɾ����ʷ�����ļ�
############### ssh ${list} "rm -rf ~/${list}/${flowpath}/* ~/${list}/${logpath}/*"  
			ssh ${list} "find ~/${list}/${BACKUPPATH}/* -mtime +${ndays} -type d |xargs rm -rf" 
##################����flowĿ¼
			ssh ${list} "mkdir -pv ~/${list}/${BACKUPPATH}/${BAKPATH}/flow"
			ssh ${list} "cp -vp ~/${list}/flow/* ~/${list}/${BACKUPPATH}/${BAKPATH}/flow/"				
##################����logĿ¼
			ssh ${list} "mkdir -pv ~/${list}/${BACKUPPATH}/${BAKPATH}/log"
			ssh ${list} "cp -vp ~/${list}/log/* ~/${list}/${BACKUPPATH}/${BAKPATH}/log"
			echo -e "Backup ${list}\'s flow and log completed"
		else
			echo "Backup the flow and log files of ${name}, Please waitting..."
##################ɾ����ʷ�����ļ�
############### ssh ${name} "rm -rf ~/${name}/${flowpath}/* ~/${name}/${logpath}/*"  
			ssh ${name} "find ~/${name}/${BACKUPPATH}/* -mtime +${ndays} -type d |xargs rm -rf" 
##################����flowĿ¼
			ssh ${name} "mkdir -pv ~/${name}/${BACKUPPATH}/${BAKPATH}/flow"
			ssh ${name} "cp -vp ~/${name}/flow/* ~/${name}/${BACKUPPATH}/${BAKPATH}/flow/"				
##################����logĿ¼
			ssh ${name} "mkdir -pv ~/${name}/${BACKUPPATH}/${BAKPATH}/log"
			ssh ${name} "cp -vp ~/${name}/log/* ~/${name}/${BACKUPPATH}/${BAKPATH}/log"
			echo -e "Backup ${name}'s flow and log completed"		
		fi
		echo -e "\n"
	done >>~/asptools/log/flowBackup_${DATE}
fi
touch .backuped_${DATE}
exec 3>&- 

#!/bin/bash
##Create by wuyuanfu 
##Date 2013-09-16
## 请把脚本放在config机的asptools目录，添加执行权限。
## 第一次备份之前请先执行flowBackup.sh makebackuppath创建流水备份目录
BAKPATH=`date +%Y%m%d-%H%M%S`
ndays=`date -d "-7 day" +%Y%m%d`
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
			ssh ${list} "mkdir -pv ~/${list}/flow/backup/ ~/${list}/log/backup/"
			echo -e "Backup directory of ${list} ,[flow/backup and log/backup] has been created!\n"
		else
			ssh ${name} "mkdir -pv ~/${name}/flow/backup/ ~/${list}/log/backup/"
			echo -e "Backup directory of ${name} ,[flow/backup and log/backup] has been created!\n"		
		fi
	done
}
if [ "$1" == "makebackuppath" ];then
	makebackuppath
	return
fi
while read line <&3
do
	name=`echo $line|awk '{print $1}'`
	num=`echo $line|awk '{print $2}'`
	list="${name}${num}"
	if [ "${num}" != "csv" ];then
#		echo "Create the backup directory [ ~/${list}/backup/${BAKPATH} ] on ${list}" 
#		ssh ${list} "mkdir -p ~/${list}/backup/$BAKPATH "
		echo "Backup the flow and log files of ${list}, Please waitting..."
		ssh ${list} "cd  ~/${list}/flow/backup && rm -f ./* && cp -vf ../* ./"
		ssh ${list} "cd  ~/${list}/log/backup && rm -f ./* && cp -vf ../* ./"
		echo -e "Backup ${list}'s flow and log completed"
#		ssh ${list} "ls -lh ~/${list}/flow/backup ~/${list}/log/backup"
#		echo "Deleting the backuped files ${ndays} ago..."
#		ssh ${list} "find ~/${list}/backup/* -mtime +{$ndays} |xargs rm -rf -"
	else
		echo "Backup the flow and log files of ${name}, Please waitting..."
		ssh ${name} "cd  ~/${name}/flow/backup && rm -f ./* && cp -vf ../* ./"
		ssh ${name} "cd  ~/${name}/log/backup && rm -f ./* && cp -vf ../* ./"
		echo -e "Backup ${name}'s flow and log completed"		
	fi
	echo -e "\n"
done
exec 3>&- 

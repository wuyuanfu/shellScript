#!/bin/bash
##Create by wuyuanfu
##Date 2013-07-04
BAKPATH=`date +%Y%m%d-%H%M%S`
PWD=`cat ~/shell/sh.cfg|grep passwd|cut -d= -f2`
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
			echo -e "Backup directory [flow/backup and log/backup] has been created!\n"
		fi
	done
}
if [ "$1" == "makebackuppath" ];then
	makebackuppath
	return
fi
if [ $PWD != "" ]
then
	printf "Please input passwd:\n"
	stty -echo
	read inpwd
	stty echo
	if [ "$inpwd" = "$PWD" ]
	then
		while read line <&3
		do
			name=`echo $line|awk '{print $1}'`
			num=`echo $line|awk '{print $2}'`
			list="${name}${num}"
###   		调用ecall.sh清理流水
			ecall.sh clean
			if [ "${num}" != "csv" ];then
	#				echo "Create the backup directory [ $(pwd) ] on ${list}" 
	#				ssh ${list} "mkdir -p ~/${list}/backup/$BAKPATH "
				echo "Restore the flow and log files of [ ${lsit} ],Please waitting..."
				ssh ${list} "cd  ~/${list}/flow/ && cp -vf ./backup/* ./"
				ssh ${list} "cd  ~/${list}/log/ && cp -vf ./backup/* ./"
				echo -e "Restore ${list}'s flow and log completed"
	#				ssh ${list} "ls -lh ~/${list}/flow/backup ~/${list}/log/backup"
	#				echo "Deleting the backuped files ${ndays} ago..."
	#				ssh ${list} "find ~/${list}/backup/* -mtime +{$ndays} |xargs rm -rf -"
			else
				echo "Restore the flow and log filesof [ ${name} ],Please waitting..."
				ssh ${name} "cd  ~/${name}/flow/ && cp -vf ./backup/* ./"
				ssh ${name} "cd  ~/${name}/log/ && cp -vf ./backup/* ./"
				echo -e "Restore ${name}'s flow and log completed"
			fi
			echo -e "\n"
		done
		exec 3>&- 
	else
			echo "Invalid password!!!"
		exit
	fi
fi

#!/bin/bash
debug=0
filename=mysql-$(date +%Y%m%d).dmp
username=esunnytap9
password=Esunny123456
MYSQL=$(which mysqldump)
backuplist="/home/esunny/data:TapDataBase"
backupdir=`echo ${backuplist} |awk -F: '{print $1}'`
dbname=`echo ${backuplist} |awk -F: '{print $2}'`
${MYSQL} -u ${username} -p${password} --database ${dbname} > ${backupdir}/${filename}||exit 5
if [ "$?" == "0" ];then
	echo $(date) -- Backup is complete and file is located in ${backupdir}>>${backupdir}/dbbackup.log 2>&1;
fi

#!/bin/bash
debug=0
filename=mysql-$(date +%Y%m%d).dmp
username=esunnytap9
password=Esunny123456
MYSQL=$(which mysqldump)
###配置数据库备份目录与数据库名，多个数据库以空格隔开
backuplist="/home/esunny/data:TapDataBase"
for i in ${backuplist}
do
	backupdir=`echo ${i} |awk -F: '{print $1}'`
	dbname=`echo ${i} |awk -F: '{print $2}'`
	${MYSQL} -u ${username} -p${password} --database ${dbname} > ${backupdir}/${filename}||exit 5
	if [ "$?" == "0" ];then
		echo $(date) -- Backup is complete and file is located in ${backupdir}>>${backupdir}/dbbackup.log 2>&1;
	fi
done

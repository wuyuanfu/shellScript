#!/bin/bash
##
##Specify the filename needed to be backup
##
debug=0
DATALISTS="/opt/web1:sqlweb1 /opt/web2:sqlweb2"
BKDIR="/opt/backup"
DATE=$(date +%Y%m%d-%H%M%S)
R=$(date +%u)
WEEK=$(date +%W)
APBIN=/usr/local/httpd/bin/apachectl
######
### Define the parameter of database
######
username=sqladmin
password=sqlpasswd
#DBLISTS="sqlweb1 sqlweb2"

MYSQL=/usr/local/mysql/bin

if [ ! -d $BKDIR/$WEEK ];then
   mkdir -p $BKDIR/$WEEK && cd $BKDIR/$WEEK
   test $debug -gt 0 && echo -e "mkdir $BKDIR/$WEEK success"
else
   cd $BKDIR/$WEEK
fi
sync 

function execbkwz()
{
    for i in $DATALISTS
    do
      WEBDIR=`echo $i |awk -F: '{print $1}'`
      WEBNAME=`echo $i $WEBDIR |awk -F\/ '{print $NF}'`
      DBNAME=`echo $i |awk -F: '{print $2}'`
      DBBAKNAME=${DBNAME}-${DATE}.tar.gz
      FILENAME=${WEBNAME}-${DATE}-${R}.tar.gz
      OLDSNAR=${WEBNAME}-$((${R}-1))
      NEWSNAR=${WEBNAME}-${R}
      test $debug -gt 0 && echo -e "The WENAME is \033[32m$WEBNAME\n\033[0m The DBNAME is \033[32m$DBNAME\n\033[0m The OLD SNAR is \033[32m$OLDSNAR\n\033[0mThe NEWSNAR
 is \033[32m$NEWSNAR\n\033[0m"
      if [ -d $BKDIR/$WEEK/$WEBNAME ];then
        cd $BKDIR/$WEEK/$WEBNAME || echo -e "\033[31m$WENAME\033[0m is no exist" 
        test $debug -gt 0 && echo -e "Now pwd is \033[32m$PWD\033[0m"
      else
        mkdir -p $BKDIR/$WEEK/$WEBNAME && cd $BKDIR/$WEEK/$WEBNAME
        test $debug -gt 0 && echo -e "Now pwd is \033[32m$PWD\033[0m"
      fi
      ##########  Back up the web's content
      if [ -e $OLDSNAR ];then
          cp $OLDSNAR $NEWSNAR
        test $debug -gt 0 && echo -e "The NEWSNAR is \033[32m$NEWSNAR\033[0m"
      fi
      tar czvpf $BKDIR/$WEEK/$WEBNAME/$FILENAME -g $BKDIR/$WEEK/$WEBNAME/$NEWSNAR $WEBDIR  ||exit 5
      if [ $? -eq 0 ];then
        test $debug -gt 0 && echo -e "\033[32m$WEBNAME \033[0m backup is complete"
      fi
      ##########  Backup the relate DATABASE
      $MYSQL/mysqldump -u $username -p$password --database ${DBNAME} > ${DBNAME}.dump ||exit 5
      if [ "$?" == "0" ];then
          tar czvpf ${BKDIR}/${WEEK}/${WEBNAME}/${DBBAKNAME} ${DBNAME}.dump && rm -rf ${DBNAME}.dump
          test $debug -gt 0 && echo -e "\033[32m$DBNAME\033[0m backup is complete and dump file is deleted"
      fi
    done
}
case $R in
1 )
    execbkwz && rm -rf $BKDIR/$((${WEEK}-2))
    test $debug -gt 0 && echo -e "\033[32m$BKDIR/$((${WEEK}-1))\033[0m deleted"
;;
[2-7] ) execbkwz
;;
esac

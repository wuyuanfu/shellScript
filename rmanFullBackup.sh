#!/bin/bash
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:.
export NLS_LANG=American_america.ZHS16GBK
export PATH=$PATH:$ORACLE_HOME/bin:.
export ORACLE_SID=ZTQHCTPDB
logfile=/u02/rman/rmanFullBackup_$(date +%Y%m%d).log
rman target / msglog=${logfile} <<EOF
run {
show all;
crosscheck archivelog all;
crosscheck backup;
allocate channel c1 device type disk maxpiecesize 10g format "/u02/rman/dbdata_full_%d_%T_%U";
allocate channel c2 device type disk maxpiecesize 10g format "/u02/rman/dbdata_full_%d_%T_%U";
configure controlfile autobackup on;
configure controlfile autobackup format for device type disk to "/u02/rman/controlfile_%F";
configure device type disk backup type to compressed backupset;
configure retention policy to recovery window of 7 days;
sql 'alter system archive log current';
backup incremental level 0 database tag 'dbdataFull' plus archivelog delete input;
report obsolete;
delete obsolete;
release channel c1;
release channel c2;
}
list backup;
exit;
EOF

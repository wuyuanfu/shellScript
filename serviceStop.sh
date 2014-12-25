#!/bin/bash
logfile="tee -a serviceStop.log"
echo "Stop the service may not need" >${logfile}
for i in `cat servicelist`
do
	chkconfig --list $i 2>&1| ${logfile}
	echo -n "Are you sure Stop this Servece[y/n]: "
	read -s ch
	echo
	if [ $ch == 'Y' ] || [ $ch == 'y' ]
	then
	   chkconfig --level 2345 $i off 2>&1|${logfile}
	else
	   echo "You cancel the STOP action!"
	fi
	echo -e "_________________________________________\n"
done
	

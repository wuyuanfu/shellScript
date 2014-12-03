#!/bin/bash
#
# Copyright 2004 Red Hat Inc., Durham, North Carolina. All Rights Reserved.
#

#
# configuration section:
#	these variables are filled in by the make target in Makefile
#

OS="Linux"
RELEASE="1.0"
PATCHLEVEL=" "
RELSTATUS="relase"
MACHTYPE="x86_64 x86"
DEBUG=0

# Check if LOGDIR is set, default to ~/backup
: ${LOGDIR:=~/backup/log}

# Check if LOGDIR is exist,otherwise create it.
if [ ! -e ${LOGDIR} ] 
then
	(umask 077 && mkdir -p ${LOGDIR}) || {
		echo "$0: could not create log directory" >&2
		exit 1
	}
fi
CMD=${0##*/}
LOGFILE=${LOGDIR}/${CMD}-$(date +%Y%m%d).log

function log () {
#	d=`date`
	echo "=================================================="
	echo "=====$(date): $1"
	echo "==================================================" >> $LOGFILE
	echo "=====$(date): $1" >> $LOGFILE
	if test x"$2" != x""; then
		shift
	fi
	$* |tee -a $LOGFILE 2>&1
	
	echo
}

function banner () {
#	d=`date`
	echo "=================================================="
	echo "===== $(date): $* ====="
	echo "==================================================" >> $LOGFILE
	echo "===== $(date): $* =====" >> $LOGFILE
	echo
}

function note () {
	echo "=====$(date): (NOTE: $*)"
	echo -ne "\n Press any key to continue..."
	echo "=====$(date): (NOTE: $*)" >> $LOGFILE
	echo -ne "\n Press any key to continue..." >> $LOGFILE
	read -s -n1
	echo
}

function notei () {
	note $*
	clear
}

banner "Start of process: ${CMD}  "
banner "logfile: ($LOGFILE)"
#log 'Switch User to femas' su - femas
((${DEBUG})) || note Ready to Stop the System
cd ~/bin/
log 'stopall' ./stopall
log 'showall' ./showall
((${DEBUG})) || note Ready to Backup the log files
log 'mcall backlog' cd ~/bin/ && ./mcall backlog
((${DEBUG})) || note Please Make sure the log files have been backed up 
log 'Check checktxt.fmsys01.feimas' cat /home/femas/backup/checktxt/checktxt.fmsys01.feimas
((${DEBUG})) || note Please make sure the checktxt file is correct
((${DEBUG})) || note Now Clearing the log files
log 'mcall clearlog' cd ~/bin/ && ./mcall clearlog
banner "End of process: ${CMD}   "
banner "logfile: ($LOGFILE)"

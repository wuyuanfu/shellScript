#!/bin/bash
#######################  README | ʹ��˵�� ################################
## ���ļ�����CTPϵͳ��ð�̲���,��ӭ��Ҳ��Ժ�ʹ�á����齫�ļ�����config��������asptoolsĿ¼��
## �ű���һ��ִ��ʱ���ж�~/asptoolsĿ¼���Ƿ���log�ļ��У����û�л��Զ����������Դ��ð�̵���־��Ϣ��
## ͬʱҲ�����Ƿ����ð���õ�list�ļ�,���û�л��Զ�����,�Զ�������ð����list�ļ���Ϊlist.maoyan,ֻ����
## tmdb/dbmt/tinit���,�����Ҫ���������������,�������޸ġ�
## ʹ��֮ǰ������config��shellĿ¼,׼������list�ļ�:${listmy}��${listsc}
## 1�� ${listmy}��ð���õ�list�ļ�,�Ѿ�ע�͵�tmdb/dbmt/tinit����ر���ǰ��
##		${listsc}�����������õ�list�ļ�,�Ѿ��ſ�tmdb/dbmt/tinit�������ע��
## 2����ʼ����Ҫ�ֹ�����
## 3���ʽ���ʿ�ѡ���ֹ����л��Զ����
## 4�����ѡ���Զ��ʽ����,����֮ǰ��Ҫȷ��connect��Ϣ��ȷ
## 5���Զ��ʽ������Ҫ��װ����sqlplus���ߵ�oracle�ͻ���
## 6���ɴ���������oracle�ͻ���:http://pan.baidu.com/share/link?shareid=2381059582&uk=3876762999
## 7���ٶ����̵�oracle�ͻ�����64λ��instant�ͻ���,�汾��11.2.0.3,�ϴ���config��������toolsĿ¼��ѹ
## 8������ʵ������޸�tnsname.ora���ļ�����
## 9������������ͨ���ʼ�1526361659@qq.com������ϵ
##
#########################################################################
## Edit by: wuyuanfu
## Created: 20130607
## LastEditTime: 20140915 19:35
## Version: 0.7
## Email: 1526361659@qq.com
## Changelog:
## 		20130607		0.1		�ļ�����			
##		20130612		0.2		�����Զ��ʽ����
##		20130613		0.3		�����Զ��ʽ����
##								������ʾ��Ϣ��ʾ����
##		20130614		0.4		���Ӷ�list�ļ����ж�
##								����ð�̽������list�ָ�
##								�������ʽ�С����Ŀ��ƺ�nls_lang
##		20130617		0.5		���������Ϣ,��������֤�����й���
##		20140902		0.6		����Ͷ�����ʽ���ʹ���
##		20140915		0.7		�޸ı��̲��Է���
###
###
###
#########################################################################
DEBUG=-3
TRADINGDAY=`date +%Y%m%d`
clear
echo -ne " �����뵱ǰ�Ľ�������[Ĭ������Ϊ${TRADINGDAY}]: "
read _date
if [ ! -n ${_date} ];then
	TRADINGDAY=${_date}
fi
LOGDEST=~/asptools/log
if [ ! -d ${LOGDEST} ];then
	mkdir -p ${LOGDEST}
fi
LOGFILE=${LOGDEST}/maoyan_`date +%Y%m%d-%H%M%S`.log
LOGED="tee -a ${LOGFILE}"
SHOWSYS=~/shell/showall.sh
STARTSYS=~/shell/startall.sh
STOPSYS=~/shell/11stop.sh
OFFERLIST="shfeoffer shfemdserver cffexoffer ffexmdserver"
### ָ��ð�̺���ʽ��list�ļ���
listmy=~/shell/list.maoyan
listsc=~/shell/list.shengchan
listbp=~/shell/list.offer
### oracle�ͻ�����ر���
connect=system/oracle@asp
export LD_LIBRARY_PATH=/home/trade/tools/instantclient_11_2_maoyan
export TNS_ADMIN=/home/trade/tools/instantclient_11_2_maoyan
export OCI_PATH=/home/trade/tools/instantclient_11_2_maoyan
export ORACLE_HOME=/home/trade/tools/instantclient_11_2_maoyan
export NLS_LANG="SIMPLIFIED CHINESE_CHINA.ZHS16GBK"
SQLPLUS=$ORACLE_HOME/sqlplus
export PATH=$PATH:/home/trade/tools/instantclient_11_2_maoyan
### ������ɫ
### ��ɫ
red="\033[1;31m"
bred="\033[1;41m"
### ��ɫ
green="\033[1;32m"
bgreen="\033[1;42m"
### ��ɫ
yellow="\033[1;33m"
byellow="\033[1;43m"
end="\033[0m"

function _anykey(){
	echo -ne "\n Press any key to continue..."
	read -s -n1
	clear
}
##�鿴ϵͳ״̬
function _systemStatusCheck(){
	echo -e ""
	${SHOWSYS}
	_anykey
}
##����tinit��ˮ��tkernel��dump�ļ�
function _cleanFlowFiles(){
	test $DEBUG -gt 0  && ssh trade@tinit "ls -l ~/tinit/flow ~/tinit/log"
	echo -e "\n${green} �������ɾ��tinit����ˮ�ļ�...${end}"
	read -s -n1
	if [ `ssh trade@tinit "ls -l ~/tinit/flow |wc -l"` == 1 ] && [ `ssh trade@tinit "ls -l ~/tinit/log |wc -l"` == 1 ];then
		echo -e "\n${bgreen} tinit����ˮĿ¼flow��log���ļ���ɾ��...${end}"
	else
		ssh trade@tinit "rm ~/tinit/flow/* ~/tinit/log/*"
		if [ `ssh trade@tinit "ls -l ~/tinit/flow |wc -l"` == 1 ] && [ `ssh trade@tinit "ls -l ~/tinit/log |wc -l"` == 1 ];then
			echo -e "\n${bgreen} tinit����ˮĿ¼flow��log���ļ���ɾ��...${end}"
		fi
	fi
	ssh trade@tinit "ls -l ~/tinit/flow ~/tinit/log"
	echo -e "\n\n${green} �������ɾ��tkernel1��dump�ļ�...${end}"
	read -s -n1
	if [ `ssh trade@tkernel1 "ls -l ~/tkernel1/dump |wc -l"` == 1 ];then
		echo -e "\n${bgreen} dumpĿ¼���ļ���ɾ��...${end}"
	else
		ssh trade@tkernel1 "rm ~/tkernel1/dump/*"
		if [ `ssh trade@tkernel1 "ls -l ~/tkernel1/dump |wc -l"` == 1 ];then
			echo -e "\n${bgreen} dumpĿ¼���ļ���ɾ��...${end}"
		fi
	fi
	_anykey
}
function _setlisttomy(){
	echo -e "\n${green} �������,�޸�list�ļ���ð��ģʽ.....  ${end}"
	read -s -n1
	if [ ! -f ${listmy} ];then
		cp ~/shell/list ${listmy}
		sed -i '/tmdb\|dbmt\|tinit$/ s/^/#/' ${listmy}
		sed -i '/csv$/ s/^#//' ${listmy}
		cp ${listmy} ~/shell/list
	else
		cp ${listmy} ~/shell/list
	fi
	if [ `cat ~/shell/list |grep -E 'tmdb|dbmt|tinit' |grep -E '^#' |wc -l` == 3 ];then
		echo -e "\n\n${green} tmdb/dbmt/tinit�����ע��...${end}\n"
		cat ~/shell/list |grep -E 'tmdb|dbmt|tinit' 
	fi
	_systemStatusCheck
}
function _setlisttosc(){
	echo -e "\n${green} �������,�ָ�list�ļ�������ģʽ.....  ${end}"
	read -s -n1
	if [ ! -f ${listsc} ];then
		echo -e "\n\n${red} ����ļ�������: ${listsc} ${end}\n"
		exit 3
	else
		cp ${listsc} ~/shell/list	
		if [ `cat ~/shell/list |grep -E '^tmdb|^dbmt|^tinit'|wc -l` == 3 ];then
			echo -e "\n\n${bgreen} tmdb/dbmt/tinit���ע���ѷſ�...${end}\n"
			cat ~/shell/list |grep -E '^tmdb|^dbmt|^tinit|csv$'
		fi
		_systemStatusCheck
	fi
}
##����CSV�ļ�
function _expCSV(){
	echo -e "\n\n${green} �������ִ��CSV�ļ�����...${end}"
	read -s -n1
	ssh trade@tinit "cd ~/tinit/unldr && ./exportSync.sh"
	if [ $?==0 ]; then
		nextday=`ssh trade@tinit "tail ~/tinit/perf/t_DepthMarketData.csv"|cut -d, -f1|uniq`
		echo -e "\n${bgreen} CSV�ļ��������...${end}"
	else
		echo -e "\n${bred} CSV�ļ�����ʧ��...${end}"
	fi
	_anykey
}
###�鿴CSV�ļ�����һ��������
function _viewCSV(){
	echo -e "\n${green} ��������鿴t_DepthMarketData.csv�ļ�...${end}"
	read -s -n1
	ssh trade@tinit "tail ~/tinit/perf/t_DepthMarketData.csv"
	_anykey
}
###����ϵͳ
function _startSystem(){
	${STARTSYS}
	echo -e "\n${green} ����������ϵͳ״̬...  ${end}"
	read -s -n1
	_systemStatusCheck
}
###��ʼ��ϵͳ
function _initSystem(){
	echo -ne "\n${green} ���¼ticlient��ʼ��ϵͳ,"
	tradingday=`ssh trade@tinit "tail ~/tinit/perf/t_DepthMarketData.csv"|cut -d, -f1|uniq`
	echo -e " ��ʼ��������:${end}${yellow} ${tradingday}${end}"
	echo -ne "${green} ��ʼ����ɺ�,������Yȷ��[Y/N]: ${end}"
	while read tinit
	do
		if [ "${tinit}" == 'Y' ] || [ "${tinit}" == 'y' ];then
			tinfo=`ssh trade@tinit "cat ~/tinit/log/Syslog.log" |grep -E "TinitOK"`
			echo -e "\n\n ${tinfo}\n"
			echo -e "\n${bgreen} ϵͳ����ɳ�ʼ��...${end}"
			break
		elif [ "${tinit}" == 'N' ] || [ "${tinit}" == 'n' ];then
			echo -ne "\n${green} ��ȷ���Ƿ��Ѿ���ʼ������ʼ����ɺ�����[Y]����ȷ��:  ${end}"
		else
			echo -ne "\n\n${bred} ������Ϣ����,������������[Y/N]:  ${end}"
		fi
	done
	_anykey
}
###�ر�ϵͳ
function _stopSystem(){
	${STOPSYS}
	echo -e "\n${green} ����������ϵͳ״̬...  ${end}"
	read -s -n1
	_systemStatusCheck
}
###���check.txt�ļ�
function _viewCheck(){
	echo -e "\n${green} ��������鿴check.txt�ļ�...${end}"
	read -s -n1
	ssh trade@tkernel1 "cat ~/tkernel1/dump/check.txt"
	_anykey
}

##����Ͷ�����ʽ����
function _InvestorSettlementCheck(){
	echo -ne "\n\n${green} ����Ͷ�����ʽ���ʣ�������Ͷ�����ʽ��ʺ�: ${end}"
	read investor_no

	###ȡ�����ݿ����ض�Ͷ���ߵ�Ȩ��
	sysqy=`${SQLPLUS} -S ${connect}<<EOF
	select to_char(sum(t.remain),'9999999999.99') from historysettlement.t_investorsettlement t where tradingday='${TRADINGDAY}' and t.accountid='${investor_no}';
EOF`
	test $DEBUG -gt 0 && echo ${sysqy}
	sysqy=`echo ${sysqy} |awk -F '-*' '{print $2}' |tr -d ' '`
	test $DEBUG -gt 0 && echo ${sysqy}
	###ȡ�����ݿ��еĿ����ʽ�
	syskyzj=`${SQLPLUS} -s ${connect}<<EOF
	select to_char(sum(t.withdrawquota),'9999999999.99') from historysettlement.t_investorsettlement t where tradingday='${TRADINGDAY}'  and t.accountid='${investor_no}';
EOF`
	syskyzj=`echo ${syskyzj} |awk -F '-*' '{print $2}' |tr -d ' '`
	###ȡ�����ݿ��еı�֤��
	sysbzj=`${SQLPLUS} -s ${connect} <<EOF
	select to_char(sum(t.margin),'9999999999.99') from historysettlement.t_investorsettlement t where tradingday='${TRADINGDAY}' and t.accountid='${investor_no}';
EOF`
	sysbzj=`echo ${sysbzj} |awk -F '-*' '{print $2}' |tr -d ' '`
	###ȡ�����ݿ��е���ֲ�
	sysmai=`${SQLPLUS} -s ${connect} <<EOF
	select sum(t.volume) from historysettlement.t_investorpositiondtl t where t.tradingday='${TRADINGDAY}' and t.direction='0' and t.accountid='${investor_no}';
EOF`
	sysmai=`echo ${sysmai} |awk -F '-*' '{print $2}' |tr -d ' '`
	if [ "X${sysmai}" == "X" ];then
		sysmai=0	###���û����ֲ֣��򽫳ֲ�������Ϊ0
	fi
	###ȡ�����ݿ��е����ֲ�
	sysmai4=`${SQLPLUS} -s ${connect} <<EOF
	select sum(t.volume) from historysettlement.t_investorpositiondtl t where t.tradingday='${TRADINGDAY}' and t.direction='1' and t.accountid='${investor_no}';
EOF`
	sysmai4=`echo ${sysmai4} |awk -F '-*' '{print $2}' |tr -d ' '`
	if [ X${sysmai4} == "X" ]
	then
		sysmai4=0	###���û�����ֲ֣��򽫳ֲ�������Ϊ0
	fi	
	###ȡ��CSV�ļ��е�Ȩ��
	csvqy=`ssh tinit cat ~/tinit/perf/t_TradingAccount.csv|awk -F"," '{if(match($2,'${investor_no}')) print $6}'|cut -d\" -f2 |awk 'BEGIN {sum=0} {sum+=$1 }END {printf("%.2f\n", sum)}'`
	###ȡ��CSV�ļ��еĿ����ʽ�
	csvkyzj=`ssh tinit cat ~/tinit/perf/t_TradingAccount.csv|awk -F"," '{if(match($2,'${investor_no}')) print $5}'|cut -d\" -f2 |awk 'BEGIN {sum=0} {sum+=$1 }END {printf("%.2f\n", sum)}'`
	###ȡ��CSV�ļ��еı�֤��
	csvbzj=`ssh tinit cat ~/tinit/perf/t_TradingAccount.csv|awk -F"," '{if(match($2,'${investor_no}')) print $7}'|cut -d\" -f2 |awk 'BEGIN {sum=0} {sum+=$1 }END {printf("%.2f\n", sum)}'`
	###ȡ��CSV�ļ��е���ֲ�
	csvmai=`ssh tinit cat ~/tinit/perf/t_InvestorPositionDtl.csv | awk -F',' '{if(match($3,'${investor_no}')) print $5,"\t",$8}' |sed 's/"//g' |awk '{if($1==0) sum+=$2}END {print sum}'`
	if [ X${csvmai} == "X" ]
	then
		csvmai=0
	fi
	###ȡ��CSV�ļ��е����ֲ�
	csvmai4=`ssh tinit cat ~/tinit/perf/t_InvestorPositionDtl.csv | awk -F',' '{if(match($3,'${investor_no}')) print $5,"\t",$8}' |sed 's/"//g' |awk '{if($1==1) sum+=$2}END {print sum}'`
	if [ X${csvmai4} == "X" ]
	then
		csvmai4=0
	fi
	
	if [ "${sysqy}" == "${csvqy}" ];then
		echo -e "\n${green} Ͷ����Ȩ��һ��,Ͷ���ߡ�${investor_no}����Ȩ����:  ${end}${yellow}${sysqy}${end}"
	else
		echo -e "\n${red} Ͷ�ʶ�Ȩ�治һ��,���ݿ���Ͷ���ߡ�${investor_no}����Ȩ����:  ${end}${yellow}${sysqy}${end}${red} ,CSV�ļ���Ͷ���ߡ�${investor_no}����Ȩ����: ${end}${yellow}${csvqy}${end}"
	fi
	if [ "${syskyzj}" == "${csvkyzj}" ];then
		echo -e "\n${green} Ͷ���߿����ʽ�һ��,Ͷ���ߡ�${investor_no}���Ŀ����ʽ���:  ${end}${yellow}${syskyzj}${end}"
	else
		echo -e "\n${red} Ͷ���ߵĿ����ʽ�һ��,���ݿ���Ͷ���ߡ�${investor_no}���Ŀ����ʽ���:  ${end}${yellow}${syskyzj}${end}${red} , CSV�ļ���Ͷ���ߡ�${investor_no}���Ŀ����ʽ���: ${end}${yellow}${csvkyzj}${end}"
	fi
	if [ "${sysbzj}" == "${csvbzj}" ];then
		echo -e "\n${green} Ͷ���߱�֤��һ��,Ͷ���ߡ�${investor_no}�����ܱ�֤����:  ${end}${yellow}${sysbzj}${end}"
	else
		echo -e "\n${red} Ͷ���ߵ��ܱ�֤��һ��,���ݿ���Ͷ���ߡ�${investor_no}���ı�֤����:  ${end}${yellow}${syszj}${end}${red} , CSV�ļ���Ͷ���ߡ�${investor_no}���ı�֤����: ${end}${yellow}${csvzj}${end}"
	fi
	if [ "${sysmai}" == "${csvmai}" ];then
		echo -e "\n${green} Ͷ������ֲ�һ��,Ͷ���ߡ�${investor_no}��������ֲ�:  ${end}${yellow}${sysmai}${end}"
	else
		echo -e "\n${red} Ͷ���ߵ���ֲֲ�һ��,���ݿ���Ͷ���ߡ�${investor_no}��������ֲ���:  ${end}${yellow}${sysmai}${end}${red} ,CSV�ļ���Ͷ���ߡ�${investor_no}��������ֲ���: ${end}${yellow}${csvmai}${end}"
	fi
	if [ "${sysmai4}" == "${csvmai4}" ];then
		echo -e "\n${green} Ͷ�������ֲ�һ��,Ͷ���ߡ�${investor_no}���������ֲ�:  ${end}${yellow}${sysmai4}${end}"
	else
		echo -e "\n${red} Ͷ���ߵ����ֲֲ�һ��,���ݿ���Ͷ���ߡ�${investor_no}���������ֲ���:  ${end}${yellow}${sysmai4}${end}${red} ,CSV�ļ���Ͷ���ߡ�${investor_no}���������ֲ���: ${end}${yellow}${csvmai4}${end}"
	fi
	if [ "${sysqy}" == "${csvqy}" ] && [ "${syskyzj}" == "${csvkyzj}" ] && [ "${sysbzj}" == "${csvbzj}" ] && [ "${sysmai}" == "${csvmai}" ] && [ "${sysmai4}" == "${csvmai4}" ]; then
		echo -e "\n${yellow} Ͷ���ߡ�${investor_no}���ʽ�������...${end}"
		echo -en "\n${green} �Ƿ������������Ͷ�����ʽ���ʡ�y/n���� ${end}"
		read nchs
		if [ "${nchs}" == 'Y' ] || [ "${nchs}" == 'y' ];then
			_InvestorSettlementCheck
		fi
	else
		echo -e "\n${bred} �ʽ���ʳ�������,����ϸ���...${end}\n\n"
		exit 5;
	fi
	echo -e "\n\n${red} ��������У��һ���ʽ�������....  ${end}"	
	_anykey
}

###�ʽ����
function _settlementCheck(){
	echo -ne "\n\n${green} �Ƿ�����ֹ�����?Ĭ��Ϊ[Y]: ${end}"
	read chs
	if [ "${chs}" == 'N' ] || [ "${chs}" == 'n' ];then
		echo -e "${byellow} ϵͳ����ֻ�˶�Ͷ������Ȩ�桢�����ʽ𡢱�֤���ֲܳ�  ${end}"
		###ȡ�����ݿ��е�Ȩ��
		sysqy=`${SQLPLUS} -S ${connect}<<EOF
		select to_char(sum(t.remain),'9999999999.99') from historysettlement.t_investorsettlement t where tradingday='${TRADINGDAY}';
EOF`
		test $DEBUG -gt 0 && echo ${sysqy}
		sysqy=`echo ${sysqy} |awk -F '-*' '{print $2}' |tr -d ' '`
		test $DEBUG -gt 0 && echo ${sysqy}
		###ȡ�����ݿ��еĿ����ʽ�
		syskyzj=`${SQLPLUS} -s ${connect}<<EOF
		select to_char(sum(t.withdrawquota),'9999999999.99') from historysettlement.t_investorsettlement t where tradingday='${TRADINGDAY}';
EOF`
		syskyzj=`echo ${syskyzj} |awk -F '-*' '{print $2}' |tr -d ' '`
		###ȡ�����ݿ��еı�֤��
		sysbzj=`${SQLPLUS} -s ${connect} <<EOF
		select to_char(sum(t.margin),'9999999999.99') from historysettlement.t_investorsettlement t where tradingday='${TRADINGDAY}';
EOF`
		sysbzj=`echo ${sysbzj} |awk -F '-*' '{print $2}' |tr -d ' '`
		###ȡ�����ݿ��е���ֲ�
		sysmai=`${SQLPLUS} -s ${connect} <<EOF
	select sum(t.volume) from historysettlement.t_investorpositiondtl t where t.tradingday='${TRADINGDAY}' and t.direction='0';
EOF`
		sysmai=`echo ${sysmai} |awk -F '-*' '{print $2}' |tr -d ' '`
		###ȡ�����ݿ��е����ֲ�
		sysmai4=`${SQLPLUS} -s ${connect} <<EOF
		select sum(t.volume) from historysettlement.t_investorpositiondtl t where t.tradingday='${TRADINGDAY}' and t.direction='1';
EOF`
		sysmai4=`echo ${sysmai4} |awk -F '-*' '{print $2}' |tr -d ' '`
		###ȡ��CSV�ļ��е�Ȩ��
		csvqy=`ssh tinit cat ~/tinit/perf/t_TradingAccount.csv|awk -F"," '{if(NR>1) print $6}'|cut -d\" -f2 |awk 'BEGIN {sum=0} {sum+=$1 }END {printf("%.2f\n", sum)}'`
		###ȡ��CSV�ļ��еĿ����ʽ�
		csvkyzj=`ssh tinit cat ~/tinit/perf/t_TradingAccount.csv|awk -F"," '{if(NR>1) print $5}'|cut -d\" -f2 |awk 'BEGIN {sum=0} {sum+=$1 }END {printf("%.2f\n", sum)}'`
		###ȡ��CSV�ļ��еı�֤��
		csvbzj=`ssh tinit cat ~/tinit/perf/t_TradingAccount.csv|awk -F"," '{if(NR>1) print $7}'|cut -d\" -f2 |awk 'BEGIN {sum=0} {sum+=$1 }END {printf("%.2f\n", sum)}'`
		###ȡ��CSV�ļ��е���ֲ�
		csvmai=`ssh tinit cat ~/tinit/perf/t_InvestorPositionDtl.csv | awk -F',' '{if(NR>1) print $5,"\t",$8}' |sed 's/"//g' |awk '{if($1==0) sum+=$2}END {print sum}'`
		###ȡ��CSV�ļ��е����ֲ�
		csvmai4=`ssh tinit cat ~/tinit/perf/t_InvestorPositionDtl.csv | awk -F',' '{if(NR>1) print $5,"\t",$8}' |sed 's/"//g' |awk '{if($1==1) sum+=$2}END {print sum}'`
		
		if [ "${sysqy}" == "${csvqy}" ];then
			echo -e "\n${green} Ͷ����Ȩ��һ��,��Ȩ����:  ${end}${yellow}${sysqy}${end}"
		else
			echo -e "\n${red} Ͷ�ʶ�Ȩ�治һ��,���ݿ��е�Ȩ����:  ${end}${yellow}${sysqy}${end}${red} ,CSV�ļ��е�Ȩ����: ${end}${yellow}${csvqy}${end}"
		fi
		if [ "${syskyzj}" == "${csvkyzj}" ];then
			echo -e "\n${green} Ͷ���߿����ʽ�һ��,�����ʽ���:  ${end}${yellow}${syskyzj}${end}"
		else
			echo -e "\n${red} Ͷ���ߵĿ����ʽ�һ��,���ݿ��еĿ����ʽ���:  ${end}${yellow}${syskyzj}${end}${red} , CSV�ļ��еĿ����ʽ���: ${end}${yellow}${csvkyzj}${end}"
		fi
		if [ "${sysbzj}" == "${csvbzj}" ];then
			echo -e "\n${green} Ͷ���߱�֤��һ��,�ܱ�֤����:  ${end}${yellow}${sysbzj}${end}"
		else
			echo -e "\n${red} Ͷ���ߵ��ܱ�֤��һ��,���ݿ��еı�֤����:  ${end}${yellow}${syszj}${end}${red} , CSV�ļ��еı�֤����: ${end}${yellow}${csvzj}${end}"
		fi
		if [ "${sysmai}" == "${csvmai}" ];then
			echo -e "\n${green} Ͷ������ֲ�һ��,����ֲ�:  ${end}${yellow}${sysmai}${end}"
		else
			echo -e "\n${red} Ͷ���ߵ���ֲֲ�һ��,���ݿ��е�����ֲ���:  ${end}${yellow}${sysmai}${end}${red} ,CSV�ļ��е�����ֲ���: ${end}${yellow}${csvmai}${end}"
		fi
		if [ "${sysmai4}" == "${csvmai4}" ];then
			echo -e "\n${green} Ͷ�������ֲ�һ��,�����ֲ�:  ${end}${yellow}${sysmai4}${end}"
		else
			echo -e "\n${red} Ͷ���ߵ����ֲֲ�һ��,���ݿ��е������ֲ���:  ${end}${yellow}${sysmai4}${end}${red} ,CSV�ļ��е������ֲ���: ${end}${yellow}${csvmai4}${end}"
		fi
		if [ "${sysqy}" == "${csvqy}" ] && [ "${syskyzj}" == "${csvkyzj}" ] && [ "${sysbzj}" == "${csvbzj}" ] && [ "${sysmai}" == "${csvmai}" ] && [ "${sysmai4}" == "${csvmai4}" ]; then
			echo -ne "\n\n${green} �Ƿ���е���Ͷ�����ʽ����?Ĭ��Ϊ[N]: ${end}"
			read chs
			if [ "${chs}" == 'Y' ] || [ "${chs}" == 'y' ];then
				_InvestorSettlementCheck
			fi
			echo -e "\n${green} �ʽ�������...${end}"
			echo -e "\n\n${red} ��������У��һ���ʽ�������....  ${end}"
		else
			echo -e "\n${bred} �ʽ���ʳ�������,����ϸ���...${end}\n\n"
			exit 5;
		fi
	else
		echo -e "\n\n${bgreen} ���¼ThostUser��FLEXƽ̨,�����ʽ����!!!"
		echo -ne " ������ɺ�������[Y]����ȷ��[Y/N]:  ${end}"	
		while read -n1 setcheck
		do
			if [ "${setcheck}" == 'Y' ] || [ "${setcheck}" == 'y' ];then
				echo -e "\n\n${green} �ʽ�������...${end}"
				break
			elif [ "${setcheck}" == 'N' ] || [ "${setcheck}" == 'n' ];then
				echo -e "\n\n${yellow} ��ȴ��ʽ�����Ƿ����...,����[X]�˳�����."
				echo -ne " ������ɺ�������[Y]����ȷ��[Y/N/X]:  ${end}"
			elif [ "${setcheck}" == 'X' ] || [ "${setcheck}" == 'x' ];then
				echo -e "\n\n${red} ����δȷ��,��ѡ�����˳�...${end}"
				break
			else
				echo -ne "\n\n${bred} ������Ϣ����,������������[Y/N/X]:${end}  "
			fi
		done
	fi
	_anykey
}
function _cleanOfferFlow(){
##	for offer in ${OFFERLIST}
##	do
##		${STARTSYS} ${offer}
##	done
	echo -e "�鿴list�ļ�����"
	_anykey
	if [ ! -f ${listbp} ] 
	then
		echo -e "${red}��${listbp}���ļ�������...${end}"
	else
		cp ${listbp} ~/shell/list
		cat ~/shell/list |grep -Ev '#'
	fi
		
	echo -e "�鿴ϵͳ״̬..."
	_anykey
	${SHOWSYS}
	
	echo -e "����ϵͳ..."
	_anykey
	${STARTSYS}
	
	echo -e "�鿴ϵͳ״̬..."
	_anykey
	${SHOWSYS}	
	
	echo -e "ֹͣϵͳ..."
	_anykey
	${STOPSYS}
	
	echo -e "��������ˮ..."
	_anykey
	ecall.sh clean
	
	echo -e "�鿴ϵͳ״̬..."
	_anykey
	${SHOWSYS}

	echo -e "�鿴���̳�����ˮ..."
	_anykey
	for i in ${OFFERLIST}
	do
		ssh ${i}1 ls -lh ${i}1/flow
		ssh ${i}2 ls -lh ${i}2/flow
	done
	_anykey

	_setlisttosc	
	_anykey
}
function menu(){
	echo -e "\n\n${yellow}"
	echo -e "\t\t1.���ϵͳ״̬\t"
	echo -e "\t\t2.ð��ǰ׼��\t"
    echo -e "\t\t3.��ʼð��\t" 
    echo -e "\t\t4.����ð��\t"
    test $DEBUG -gt 0 && echo -e "\t\t5.�ʽ����\t"
	test $DEBUG -gt 0 && echo -e "\t\t6.Ͷ�����ʽ����\t"
	test $DEBUG -gt 0 && echo -e "\t\t7.������������\t"
    echo -e "\t\t0.�˳�\t" 
	echo -ne "\t\t��ѡ�����: ${end}"
}
if [ $* > 0 ];then
	echo -e "Usage:\.\/$basename"
	exit 3
fi
clear
menu |${LOGED}
while read choose
do
	echo "${choose}"
	case ${choose} in
	1)  _systemStatusCheck
		menu
	;;
	2)	_setlisttomy
		_cleanFlowFiles
		_expCSV
		_viewCSV
		menu
	;;
	3)	_startSystem
		_initSystem
		_viewCheck
		_settlementCheck
		menu
	;;
	4)	_stopSystem
		_cleanFlowFiles
		_cleanOfferFlow
		menu
	;;
	5)	_settlementCheck
		menu
	;;
	6|8) _InvestorSettlementCheck
		menu
	;;
	7) _cleanOfferFlow
		menu
	;;
	0)
		exit 0
	;;
	*)	clear
		echo -e "\n\n${bred}����Ĳ�������,������ѡ��  ${end}"
		menu
	esac
done | ${LOGED}

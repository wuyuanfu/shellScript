#!/bin/bash
#######################  README | 使用说明 ################################
## 该文件用于CTP系统的冒烟测试,欢迎大家测试和使用。建议将文件放在config服务器的asptools目录。
## 脚本第一次执行时会判断~/asptools目录下是否有log文件夹，如果没有会自动创建，用以存放冒烟的日志信息。
## 同时也会检测是否存在冒烟用的list文件,如果没有会自动创建,自动创建的冒烟用list文件名为list.maoyan,只屏蔽
## tmdb/dbmt/tinit组件,如果需要屏蔽其他额外组件,请自行修改。
## 使用之前请先在config的shell目录,准备两个list文件:${listmy}和${listsc}
## 1、 ${listmy}是冒烟用的list文件,已经注释掉tmdb/dbmt/tinit或相关报盘前置
##        ${listsc}是生产环境用的list文件,已经放开tmdb/dbmt/tinit等组件的注释
## 2、初始化需要手工进行
## 3、资金对帐可选择手工进行或自动完成
## 4、如果选择自动资金对帐,运行之前需要确认connect信息正确
## 5、自动资金对帐需要安装带有sqlplus工具的oracle客户端
## 6、可从这里下载oracle客户端:http://pan.baidu.com/share/link?shareid=2381059582&uk=3876762999
## 7、百度网盘的oracle客户端是64位的instant客户端,版本是11.2.0.3,上传至config服务器的tools目录解压
## 8、根据实际情况修改tnsname.ora的文件内容
## 9、程序问题请通过邮件1526361659@qq.com与我联系
##
#########################################################################
## Edit by: wuyuanfu
## Created: 20130607
## LastEditTime: 20130617
## Version: 0.5
## Email: 1526361659@qq.com
## Changelog:
## 		20130607		0.1		文件建立			
##		20130612		0.2		增加自动资金对账
##		20130613		0.3		完善自动资金对帐
##								调整提示信息显示方法
##		20130614		0.4		增加对list文件的判断
##								增加冒烟结束后的list恢复
##								增加了资金小数点的控制和nls_lang
##		20130617		0.5		调整输出信息,并测试验证了所有功能
##
#########################################################################
DEBUG=-3
TRADINGDAY=`date +%Y%m%d`
clear
echo -ne " 请输入当前的交易日期[默认日期为${TRADINGDAY}]: "
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
### 指定冒烟和正式的list文件名
listmy=~/shell/list.maoyan
listsc=~/shell/list.shengchan
### oracle客户端相关变量
connect=system/oracle@asp
export LD_LIBRARY_PATH=/home/trade/tools/instantclient_11_2_maoyan
export TNS_ADMIN=/home/trade/tools/instantclient_11_2_maoyan
export OCI_PATH=/home/trade/tools/instantclient_11_2_maoyan
export ORACLE_HOME=/home/trade/tools/instantclient_11_2_maoyan
export NLS_LANG="SIMPLIFIED CHINESE_CHINA.ZHS16GBK"
SQLPLUS=$ORACLE_HOME/sqlplus
export PATH=$PATH:/home/trade/tools/instantclient_11_2_maoyan
### 定义颜色
### 红色
red="\033[1;31m"
bred="\033[1;41m"
### 绿色
green="\033[1;32m"
bgreen="\033[1;42m"
### 黄色
yellow="\033[1;33m"
byellow="\033[1;43m"
end="\033[0m"

function _anykey(){
	echo -ne "\n Press any key to continue..."
	read -s -n1
	clear
}
##查看系统状态
function _systemStatusCheck(){
	echo -e ""
	${SHOWSYS}
	_anykey
}
##清理tinit流水和tkernel的dump文件
function _cleanFlowFiles(){
	test $DEBUG -gt 0  && ssh trade@tinit "ls -l ~/tinit/flow ~/tinit/log"
	echo -e "\n${green} 按任意键删除tinit的流水文件...${end}"
	read -s -n1
	if [ `ssh trade@tinit "ls -l ~/tinit/flow |wc -l"` == 1 ] && [ `ssh trade@tinit "ls -l ~/tinit/log |wc -l"` == 1 ];then
		echo -e "\n${bgreen} tinit的流水目录flow和log的文件已删除...${end}"
	else
		ssh trade@tinit "rm ~/tinit/flow/* ~/tinit/log/*"
		if [ `ssh trade@tinit "ls -l ~/tinit/flow |wc -l"` == 1 ] && [ `ssh trade@tinit "ls -l ~/tinit/log |wc -l"` == 1 ];then
			echo -e "\n${bgreen} tinit的流水目录flow和log的文件已删除...${end}"
		fi
	fi
	ssh trade@tinit "ls -l ~/tinit/flow ~/tinit/log"
	echo -e "\n\n${green} 按任意键删除tkernel1的dump文件...${end}"
	read -s -n1
	if [ `ssh trade@tkernel1 "ls -l ~/tkernel1/dump |wc -l"` == 1 ];then
		echo -e "\n${bgreen} dump目录的文件已删除...${end}"
	else
		ssh trade@tkernel1 "rm ~/tkernel1/dump/*"
		if [ `ssh trade@tkernel1 "ls -l ~/tkernel1/dump |wc -l"` == 1 ];then
			echo -e "\n${bgreen} dump目录的文件已删除...${end}"
		fi
	fi
	_anykey
}
function _setlisttomy(){
	echo -e "\n${green} 按任意键,修改list文件到冒烟模式.....  ${end}"
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
		echo -e "\n\n${green} tmdb/dbmt/tinit组件已注释...${end}\n"
		cat ~/shell/list |grep -E 'tmdb|dbmt|tinit' 
	fi
	_systemStatusCheck
}
function _setlisttosc(){
	echo -e "\n${green} 按任意键,恢复list文件到生产模式.....  ${end}"
	read -s -n1
	if [ ! -f ${listsc} ];then
		echo -e "\n\n${red} 这个文件不存在: ${listsc} ${end}\n"
		exit 3
	else
		cp ${listsc} ~/shell/list	
		if [ `cat ~/shell/list |grep -E '^tmdb|^dbmt|^tinit'|wc -l` == 3 ];then
			echo -e "\n\n${bgreen} tmdb/dbmt/tinit组件注释已放开...${end}\n"
			cat ~/shell/list |grep -E '^tmdb|^dbmt|^tinit|csv$'
		fi
		_systemStatusCheck
	fi
}
##导出CSV文件
function _expCSV(){
	echo -e "\n\n${green} 按任意键执行CSV文件导出...${end}"
	read -s -n1
	ssh trade@tinit "cd ~/tinit/unldr && ./exportSync.sh"
	if [ $?==0 ]; then
		nextday=`ssh trade@tinit "tail ~/tinit/perf/t_DepthMarketData.csv"|cut -d, -f1|uniq`
		echo -e "\n${bgreen} CSV文件导出完成...${end}"
	else
		echo -e "\n${bred} CSV文件导出失败...${end}"
	fi
	_anykey
}
###查看CSV文件的下一交易日期
function _viewCSV(){
	echo -e "\n${green} 按任意键查看t_DepthMarketData.csv文件...${end}"
	read -s -n1
	ssh trade@tinit "tail ~/tinit/perf/t_DepthMarketData.csv"
	_anykey
}
###启动系统
function _startSystem(){
	${STARTSYS}
	echo -e "\n${green} 按任意键检查系统状态...  ${end}"
	read -s -n1
	_systemStatusCheck
}
###初始化系统
function _initSystem(){
	echo -ne "\n${green} 请登录ticlient初始化系统,"
	tradingday=`ssh trade@tinit "tail ~/tinit/perf/t_DepthMarketData.csv"|cut -d, -f1|uniq`
	echo -e " 初始化日期是:${end}${yellow} ${tradingday}${end}"
	echo -ne "${green} 初始化完成后,请输入Y确认[Y/N]: ${end}"
	while read tinit
	do
		if [ "${tinit}" == 'Y' ] || [ "${tinit}" == 'y' ];then
			tinfo=`ssh trade@tinit "cat ~/tinit/log/Syslog.log" |grep -E "TinitOK"`
			echo -e "\n\n ${tinfo}\n"
			echo -e "\n${bgreen} 系统已完成初始化...${end}"
			break
		elif [ "${tinit}" == 'N' ] || [ "${tinit}" == 'n' ];then
			echo -ne "\n${green} 请确认是否已经初始化，初始化完成后输入[Y]进行确认:  ${end}"
		else
			echo -ne "\n\n${bred} 输入信息有误,请检查输入内容[Y/N]:  ${end}"
		fi
	done
	_anykey
}
###关闭系统
function _stopSystem(){
	${STOPSYS}
	echo -e "\n${green} 按任意键检查系统状态...  ${end}"
	read -s -n1
	_systemStatusCheck
}
###检查check.txt文件
function _viewCheck(){
	echo -e "\n${green} 按任意键查看check.txt文件...${end}"
	read -s -n1
	ssh trade@tkernel1 "cat ~/tkernel1/dump/check.txt"
	_anykey
}
###资金对账
function _settlementCheck(){

	echo -ne "\n\n${green} 是否进行手工对帐?默认为[Y]: ${end}"
	read chs
	if [ "${chs}" == 'N' ] || [ "${chs}" == 'n' ];then
		echo -e "${byellow} 系统对帐只核对投资者总权益、可用资金、保证金及总持仓  ${end}"
		###取得数据库中的权益
		sysqy=`${SQLPLUS} -S ${connect}<<EOF
		select to_char(sum(t.remain),'9999999999.99') from historysettlement.t_investorsettlement t where tradingday='${TRADINGDAY}';
EOF`
		test $DEBUG -gt 0 && echo ${sysqy}
		sysqy=`echo ${sysqy} |awk -F '-*' '{print $2}' |tr -d ' '`
		test $DEBUG -gt 0 && echo ${sysqy}
		###取得数据库中的可用资金
		syskyzj=`${SQLPLUS} -s ${connect}<<EOF
		select to_char(sum(t.withdrawquota),'9999999999.99') from historysettlement.t_investorsettlement t where tradingday='${TRADINGDAY}';
EOF`
		syskyzj=`echo ${syskyzj} |awk -F '-*' '{print $2}' |tr -d ' '`
		###取得数据库中的保证金
		sysbzj=`${SQLPLUS} -s ${connect} <<EOF
		select to_char(sum(t.margin),'9999999999.99') from historysettlement.t_investorsettlement t where tradingday='${TRADINGDAY}';
EOF`
		sysbzj=`echo ${sysbzj} |awk -F '-*' '{print $2}' |tr -d ' '`
		###取得数据库中的买持仓
		sysmai=`${SQLPLUS} -s ${connect} <<EOF
		select sum(t.btotalamt) from historysettlement.t_investorpositiondtl t where t.tradingday='${TRADINGDAY}';
EOF`
		sysmai=`echo ${sysmai} |awk -F '-*' '{print $2}' |tr -d ' '`
		###取得数据库中的卖持仓
		sysmai4=`${SQLPLUS} -s ${connect} <<EOF
		select sum(t.stotalamt) from historysettlement.t_investorpositiondtl t where t.tradingday='${TRADINGDAY}';
EOF`
		sysmai4=`echo ${sysmai4} |awk -F '-*' '{print $2}' |tr -d ' '`
		###取得CSV文件中的权益
		csvqy=`ssh tinit cat ~/tinit/perf/t_TradingAccount.csv|awk -F"," '{if(NR>1) print $6}'|cut -d\" -f2 |awk 'BEGIN {sum=0} {sum+=$1 }END {printf("%.2f\n", sum)}'`
		###取得CSV文件中的可用资金
		csvkyzj=`ssh tinit cat ~/tinit/perf/t_TradingAccount.csv|awk -F"," '{if(NR>1) print $5}'|cut -d\" -f2 |awk 'BEGIN {sum=0} {sum+=$1 }END {printf("%.2f\n", sum)}'`
		###取得CSV文件中的保证金
		csvbzj=`ssh tinit cat ~/tinit/perf/t_TradingAccount.csv|awk -F"," '{if(NR>1) print $7}'|cut -d\" -f2 |awk 'BEGIN {sum=0} {sum+=$1 }END {printf("%.2f\n", sum)}'`
		###取得CSV文件中的买持仓
		csvmai=`ssh tinit cat ~/tinit/perf/t_InvestorPositionDtl.csv | awk -F',' '{if(NR>1) print $5,"\t",$8}' |sed 's/"//g' |awk '{if($1==0) sum+=$2}END {print sum}'`
		###取得CSV文件中的卖持仓
		csvmai4=`ssh tinit cat ~/tinit/perf/t_InvestorPositionDtl.csv | awk -F',' '{if(NR>1) print $5,"\t",$8}' |sed 's/"//g' |awk '{if($1==1) sum+=$2}END {print sum}'`
		
		if [ "${sysqy}" == "${csvqy}" ];then
			echo -e "\n${green} 投资者权益一致,总权益是:  ${end}${yellow}${sysqy}${end}"
		else
			echo -e "\n${red} 投资都权益不一致,数据库中的权益是:  ${end}${yellow}${sysqy}${end}${red} ,CSV文件中的权益是: ${end}${yellow}${csvqy}${end}"
		fi
		if [ "${syskyzj}" == "${csvkyzj}" ];then
			echo -e "\n${green} 投资者可用资金一致,可用资金是:  ${end}${yellow}${syskyzj}${end}"
		else
			echo -e "\n${red} 投资者的可用资金不一致,数据库中的可用资金是:  ${end}${yellow}${syskyzj}${end}${red} , CSV文件中的可用资金是: ${end}${yellow}${csvkyzj}${end}"
		fi
		if [ "${sysbzj}" == "${csvbzj}" ];then
			echo -e "\n${green} 投资者保证金一致,总保证金是:  ${end}${yellow}${sysbzj}${end}"
		else
			echo -e "\n${red} 投资者的总保证金不一致,数据库中的保证金是:  ${end}${yellow}${syszj}${end}${red} , CSV文件中的保证金是: ${end}${yellow}${csvzj}${end}"
		fi
		if [ "${sysmai}" == "${csvmai}" ];then
			echo -e "\n${green} 投资者买持仓一致,总买持仓:  ${end}${yellow}${sysmai}${end}"
		else
			echo -e "\n${red} 投资者的买持仓不一致,数据库中的总买持仓是:  ${end}${yellow}${sysmai}${end}${red} ,CSV文件中的总买持仓是: ${end}${yellow}${csvmai}${end}"
		fi
		if [ "${sysmai4}" == "${csvmai4}" ];then
			echo -e "\n${green} 投资者卖持仓一致,总卖持仓:  ${end}${yellow}${sysmai4}${end}"
		else
			echo -e "\n${red} 投资者的卖持仓不一致,数据库中的总卖持仓是:  ${end}${yellow}${sysmai4}${end}${red} ,CSV文件中的总卖持仓是: ${end}${yellow}${csvmai4}${end}"
		fi
		if [ "${sysqy}" == "${csvqy}" ] && [ "${syskyzj}" == "${csvkyzj}" ] && [ "${sysbzj}" == "${csvbzj}" ] && [ "${sysmai}" == "${csvmai}" ] && [ "${sysmai4}" == "${csvmai4}" ]; then
			echo -e "\n${green} 资金对帐完成...${end}"
			echo -e "\n\n${red} 建议自行校验一下资金对帐情况....  ${end}"
		else
			echo -e "\n${bred} 资金对帐出现问题,请仔细检查...${end}\n\n"
			exit 5;
		fi
	else
		echo -e "\n\n${bgreen} 请登录ThostUser和FLEX平台,进行资金对帐!!!"
		echo -ne " 对帐完成后请输入[Y]进行确认[Y/N]:  ${end}"	
		while read -n1 setcheck
		do
			if [ "${setcheck}" == 'Y' ] || [ "${setcheck}" == 'y' ];then
				echo -e "\n\n${green} 资金对账完成...${end}"
				break
			elif [ "${setcheck}" == 'N' ] || [ "${setcheck}" == 'n' ];then
				echo -e "\n\n${yellow} 请等待资金对帐是否完成...,输入[X]退出程序."
				echo -ne " 对帐完成后请输入[Y]进行确认[Y/N/X]:  ${end}"
			elif [ "${setcheck}" == 'X' ] || [ "${setcheck}" == 'x' ];then
				echo -e "\n\n${red} 对帐未确认,你选择了退出...${end}"
				break
			else
				echo -ne "\n\n${bred} 输入信息有误,请检查输入内容[Y/N/X]:${end}  "
			fi
		done
	fi
	_anykey
}
function menu(){
	echo -e "\n\n${yellow}"
	echo -e "\t\t1.检查系统状态\t"
	echo -e "\t\t2.冒烟前准备\t"
    echo -e "\t\t3.开始冒烟\t" 
    echo -e "\t\t4.结束冒烟\t"
    test $DEBUG -gt 0 && echo -e "\t\t5.资金对帐\t"
    echo -e "\t\t0.退出\t" 
	echo -ne "\t\t请选择操作: ${end}"
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
		_setlisttosc
		menu
	;;
	5)	_settlementCheck
		menu
	;;
	0)
		exit 0
	;;
	*)	clear
		echo -e "\n\n${bred}输入的参数有误,请重新选择！  ${end}"
		menu
	esac
done | ${LOGED}

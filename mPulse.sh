#!/bin/bash

#######################################################################
# This script will capture all the sytem logs and runtime information #
# Can be used in impairment situation to gather info                  #
# WIP                                                                 #
#######################################################################

# /var/logs
# messages,secure,utmp,wtmp,btmp,maillog,cron,dmesg

#mPulse Script

#mUsage - prints provided error along with the usage of te mPulse
#Syntax : mUsage "Error message"
mUsage() {
if [ $# -ne 0 ]
        then
        echo "$@"
fi

echo -e "Usage: $0 -d <Output directory>\
         \n\t Parameter details \n\t\t -d provide input directory to generate output to\
	 \n\t\t -h print help information"

}

#mLogger - Displays the logs on the STDOUT and stores it in the log file.
# Syntax mLogger <-i|-e|-w> "Logs to capture"
# -i => INFO -e => ERROR -w => WARNING
mLogger () {
case $1 in
	-e) FLAG="ERROR : "
		shift
		;;
	-i) FLAG="INFO : "
		shift
		;;
	-w) FLAG="WARNING : "
		shift
		;;
	-d) FLAG="DEBUG : "
		shift
		;;
	*) FLAG=""
		;;  
esac
echo "$FLAG$@"|tee -a $LOG
}

#Initialize - performs standard checks for the script and sets variable as well as create 
#             required directory structure.
Initialize () {

#Checks root access.
if [ $UID -gt 0 ]
	then
	echo "You're not a root user. Only Root should run this script. ERR01"
	exit 1	
fi

#Input parameter validation
if [ $# -eq 0 ]
	then
	mUsage "Input parameters are expected"
	exit 3
fi

while getopts 'd:h' opt
do
	case $opt in
		d)   if [ -d $OPTARG ] 
			then 
				OUTPUT="${OPTARG%/}/mPulse$(date +%Y-%m-%d:%T)" 
		     else
				mUsage "Input directory does not exist"
				exit 4
		     fi
		     ;;

		*|h) mUsage "You need help, here you go "
		     exit 2;;
	esac
done

#Create directory structure
mkdir -p $OUTPUT/System_Runtime $OUTPUT/System_Info $OUTPUT/mPulse_log $OUTPUT/System_Logs
if [ $? -ne 0 ]
	then
	echo Unable to create directory under $OUTPUT
	exit 5
fi

LOG=$OUTPUT/mPulse_log/mPulse.log

}

Initialize $@
 
mLogger -i "Data will be stored under the path $OUTPUT"

System_Runtime() {

#change directory to runtime
cd $OUTPUT/System_Runtime

#netstat
netstat -tulpn > netstat_tulpn.out

#top by mem
top -n 1 -o %MEM > top_mem.out

#top by cpu
top -n 1 -o %CPU > top_cpu.out

#ps auwxx
ps auwxx > ps_auwxx.out

#ps by res top 25
ps auwx --sort -rss|head -26 > ps_auwx_rss.out

#ps by virt top 25
ps auwx --sort -vsz|head -26 > ps_auwx_vsz.out

#lsof
lsof > lsof.out

#free
free -m > free_m.out

#iotop
iotop -boPtqqq -n 5 > iotop_boPtqqq_n5.out

#w
w > w.out

#last
last -n 100 > last_n100.out

#vmstat
vmstat 1 5 -t -n -d > vmstat_tnd.out
vmstat 1 5 -t -n > vmstat_tn.out

#df
df -TP > df_TP.out
df -iP > df_iP.out

#ipcs
ipcs > ipcs.out

#Template for future reference

#Name of the command
#command with parameter > output.out 

}

mLogger -i "mPulse is capturing System Runtime data"
System_Runtime

System_Info () {

cd $OUTPUT/System_Info

#meminfo
cat /proc/meminfo > meminfo.out

#cpuinfo
cat /proc/cpuinfo > cpuinfo.out

#uname
uname -a > uname_a.out

#os release
[ -f /etc/os-release ] && egrep '^NAME=|^VERSION=' /etc/os-release > os-release.out

#hosname
hostname > hostname.out
ifconfig > ifconfig.out

#dmesg
dmesg > dmesg.out

#fdisk
fdisk -l>fdisk_l.out

#Template
#future scope
#lsblk, lsscsi, lspci, lsusb

}

mLogger -i "mPulse is capturing System Information"
System_Info

System_Logs () {

# utmp,wtmp,btmp,

cd $OUTPUT/System_Logs

tail -10000 /var/log/messages > messages_10k.out
tail -10000 /var/log/secure > secure_10k.out
tail -10000 /var/log/maillog > maillog_10k.out
tail -10000 /var/log/cron > cron_10k.out

}

mLogger -i "mPulse is dumping system logs"
System_Logs

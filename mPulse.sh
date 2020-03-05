#!/bin/bash

#######################################################################
# This script will capture all the sytem logs and runtime information #
# Can be used in impairment situation to gather info                  #
# WIP                                                                 #
#######################################################################


# /var/logs
# messages,secure,utmp,wtmp,btmp,maillog,cron,dmesg

#mPulse

#OUTPUT=/tmp/mPulse$(date +%Y-%m-%d:%T)

mUsage() {
if [ $# -ne 0 ]
        then
        echo "$@"
fi

echo -e "Usage: $0 -d <Output directory>\
         \n\t Parameter details \n\t\t -d provide input directory to generate output to\
	 \n\t\t -h print help information"

}


Initialize () {

if [ $UID -gt 0 ]
	then
	echo "You're not a root user. Only Root should run this script. ERR01"
	exit 1	
fi

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
mkdir -p $OUTPUT/System_Runtime $OUTPUT/System_Info $OUTPUT/mPulse_log
if [ $? -ne 0 ]
	then
	echo Unable to create directory under $OUTPUT
	exit 5
fi

LOG=$OUTPUT/mPulse_log/mPulse.log

}

Initialize $@

#mlogger "Data will be stored under the path $OUTPUT"


mLogger () {

echo $@|tee -a $LOG

}



mLogger "Data will be stored under the path $OUTPUT"


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
df -P > df_P.out
df -iP > df_iP.out

#ipcs
ipcs > ipcs.out

#Template for future reference

#Name of the command
#command with parameter > output.out 

}

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

}

System_Info

#!/bin/bash

#######################################################################
# This script will capture all the sytem logs and runtime information #
# Can be used in impairment situation to gather info                  #
# WIP                                                                 #
#######################################################################


# /var/logs
# messages,secure,utmp,wtmp,btmp,maillog,cron,dmesg

#mPulse

OUTPUT=/tmp/mPulse$(date +%Y-%m-%d:%T)

Initialize () {

if [ $UID -gt 0 ]
	then
	echo "You're not a root user. Only Root should run this script. ERR01"
	exit 1	:
fi

}

Initialize

System_Runtime() {

#move directory create par tin initiaize
mkdir -p $OUTPUT/System_Runtime
#check if directory is created or errors

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

#meminfo
cat /proc/meminfo > meminfo.out

#cpuinfo
cat /proc/cpuinfo > cpuinfo.out


#Template for future reference

#Name of the command
#command with parameter > output.out 

}

System_Runtime

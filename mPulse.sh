#!/bin/bash
#######################################################################
# 				mPulse.sh			      #
#                                                                     #
# Descrption: This script captures system logs, runtime information,  #
#	  general system info & JVM diagnostics data.	    	      #		
#	  Intention of this script is to capture as much data as      #
#         possible during the impairment or severe performance        #
#         degradation.                                                #
# Auther: Kaushik Patil						      #
# Email : er.kaushikpatil@gmail.com				      #
# Vesion: 0.0.1 Alpha						      #
# Release Notes/Remarks : Written specifically for centOS and most of # 
#	  the parts are hardcoded and unoptimized.		      #
# Future: More dynamic, additional validation and running multiple    # 
#	  jobs simultaneously to bring down total runtime of the      #
#	  script.						      #	
#	 							      #		
#######################################################################

#mUsage - prints provided error along with the usage of te mPulse
#Syntax : mUsage "Error message"
mUsage() {
if [ $# -ne 0 ]
        then
        echo "$@"
fi

echo -e "
Usage: $0 -d <Output directory>
     Parameter details
         -d provide input directory where you want to generate output.
         -j to provide java pid to run JVM diagnostics againt java pid.
                Syntax: $0 -d <Output directory> -j <java pid>
         -c Check whether required binaries are available on the system.
	 -h prints this information.
            mPulse manual page can be accessed through 'manual' parameter
                Example $0 -h manual
            This option is under devlopement.
                "

}

#mLogger - Displays the logs on the STDOUT and stores it in the log file.
# Syntax mLogger <-i|-e|-w> "Logs to capture"
# -i => INFO -e => ERROR -w => WARNING
mLogger () {

if [ $# -gt 0 ]
	then
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
else
	exit 100
fi
}

mCheck () {

echo "Checking mPulse requirements"
grep '>' $0 |awk '{print $1}'|egrep -v ":|#|\["|sort|uniq > ~/commands_mPulse
while read cmd
do
        type $cmd > /dev/null 2>&1 && echo -e "$cmd \e[1;32mOK\e[0m" || echo -e "$cmd \e[1;31mNotFound\e[0m Please install $cmd"
done < ~/commands_mPulse
rm ~/commands_mPulse
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

while getopts 'd:j:h:c' opt
do
	GETOPTS=1
	case $opt in
		d)   if [ -d $OPTARG ] 
			then 
				OUTPUT="${OPTARG%/}/mPulse$(date +%Y-%m-%d:%T)" 
		     else
				mUsage "Input directory does not exist"
				exit 4
		     fi
		     ;;
		j)   if [ ! -z $OPTARG ] && [ $(ps -p $OPTARG|wc -l) -gt 1  ]
			then
				JVMPID=$OPTARG
				JVMDATA="TRUE"
		     else
				mUsage "Incorrect JVM parameters"
		     		exit 5
		     fi
		     ;;

		h) if [ $OPTARG==[mM][aA][Nn][Uu][Aa][Ll] ]
		   then
			#Guide function
			mUsage "Manual is under development please refer help"
		   else
			mUsage "mPulse help"
		     	exit 2
			
		   fi
		   ;;
		c) CHECKONLY='TRUE'
		   break
		   ;;
		?) mUsage "Unexpected parameters"
		   exit 10
		   ;;
	esac
done

if [ $# -gt 0 ] && ((GETOPTS==0 ));
	then
		mUsage "Bad parameters"
		exit 10
elif [ ! -z $CHECKONLY ] && [ $CHECKONLY=='TRUE' ]
	then
		echo $CHECKONLY
 		mCheck
		exit 0
elif [ -z $OUTPUT ]
        then
                mUsage "Specify Output directory"
                exit 10

fi

#Create directory structure
mkdir -p $OUTPUT/System_Runtime $OUTPUT/System_Info $OUTPUT/mPulse_log $OUTPUT/System_Logs 
if [ $? -ne 0 ]
	then
	echo Unable to create directory under $OUTPUT
	exit 5
fi

LOG=$OUTPUT/mPulse_log/mPulse.log

}




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

#lastlog
lastlog > lastlog.out

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

#sysctl
sysctl -a > sysctl_a.out 2>&1

#Template
#future scope
#lsblk, lsscsi, lspci, lsusb

}



System_Logs () {

# utmp,wtmp,btmp,

cd $OUTPUT/System_Logs

tail -10000 /var/log/messages > messages_10k.out
tail -10000 /var/log/secure > secure_10k.out
tail -10000 /var/log/maillog > maillog_10k.out
tail -10000 /var/log/cron > cron_10k.out

#Last 2 sar files
ls -ltrh /var/log/sa/sa[0-9]*|tail -2 |awk '{print $NF}'|xargs -I line cp -p line .

}



JVM_Runtime () {

if [ -z $JAVA_HOME  ] || [ ! -d $JAVA_HOME ]
	then
		JAVA_HOME=$(ls -ltdrh /usr/lib/jvm/*jdk*|grep -v jre|tail -1|awk '{print $NF}')
fi

cd $OUTPUT/JVM_Runtime

iotop -n 10 -btqqq -p $JVMPID > iotop_jvm.out

#jmap
jmap -heap $JVMPID > jmap_heap.out
jmap -histo $JVMPID -F > jmap_histo.out
jmap -finalizerinfo $JVMPID > jmap_fininfo.out
jmap -F -dump:file=$JVMPID.bin $JVMPID > jmap_dump.log 2>&1

#jstack
jstack -l $JVMPID > jstack_l.out
jstack -F -l $JVMPID > jstack_Fl.out
jstack -m -F -l $JVMPID > jstack_mlF.out


#strace
strace -o $JVMPID.strace -tt -T -ff -p $JVMPID > strace.log 2>&1 &
STPID=$!
sleep 30
kill -8 $STPID

}


mLogger -i "Initializing.."
Initialize $@
[ $? == 0 ] && mLogger -i "Initialization successful." || mLogger -e "Initialization wasn't successful"

mLogger -i "Data will be stored under the path $OUTPUT"

mLogger -i "mPulse is capturing System Runtime data"
System_Runtime

mLogger -i "mPulse is capturing System Information"
System_Info

mLogger -i "mPulse is dumping system logs"
System_Logs

if [ JVMDATA==TRUE ]
	then
		mkdir $OUTPUT/JVM_Runtime
		JVM_Runtime $JVMPID
fi


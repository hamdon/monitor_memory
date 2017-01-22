#!/bin/sh
#
# monitor the memory usage,if the usage exceed a certain definite value,will record some log
#set -x

# variables: mem_trigger_percentage、server_name come from memory_trigger_record_config.sh

PREFIX=$(cd "$(dirname "$0")"; pwd)
cd $PREFIX
cur_dir=$(pwd)
source "${cur_dir}/memory_trigger_record_config.sh"

is_available=$(free | grep available | wc -l)
if [ "$is_available" = "0" ]; then
  used_memory_percentage="$(free | awk 'FNR == 3 {print $3/($3+$4)*100}')"
else
  used_memory_percentage="$(free | awk 'FNR == 2 {print ($2-$7)/$2*100}')"
fi
if [ `echo "${used_memory_percentage}>${mem_trigger_percentage}" | bc` -eq 1 ]; then
        basepath=$(cd `dirname $0`; pwd)
        log_path="${basepath}/log"
        nowtime=`date --date='0 days ago' "+%Y-%m-%d-%H:%M:%S"`;
        nowdate=`date --date='0 days ago' "+%Y-%m-%d"`;
        #记录所有进程 
        ps_filename="${log_path}/mem_trigger_ps_${nowdate}.log";
        echo ${nowtime} >> ${ps_filename};
        `ps auxef >> ${ps_filename}`;
        echo " " >> ${ps_filename};
       
        #记录ipcs数据
        ipcs_filename="${log_path}/mem_trigger_ipcs_${nowdate}.log";
        echo ${nowtime} >> ${ipcs_filename};
        `ipcs >> ${ipcs_filename}`;
        echo " " >> ${ipcs_filename};
       
        #记录网络连接情况
        netstat_filename="${log_path}/mem_trigger_netstat_${nowdate}.log"
        echo ${nowtime} >> ${netstat_filename}
       `netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}' >> ${netstat_filename}`
        echo " " >> ${netstat_filename}

        #记录top里面cpu占用高的信息
         cpu_top_filename="${log_path}/mem_trigger_top_cpu_${nowdate}.log"
        echo ${nowtime} >> ${cpu_top_filename}
       `COLUMNS=200 top -b -c -n1 | sed -n '7,15p' >> ${cpu_top_filename}`
        echo " " >> ${cpu_top_filename}

        #记录top里面的按内存排的信息
         top_mem_filename="${log_path}/mem_trigger_top_mem_${nowdate}.log"
        echo ${nowtime} >> ${top_mem_filename}
       `COLUMNS=200  top -n1 -b -c| sed -n '7,$p' | sort -r -n -k 10,10 >> ${top_mem_filename}`
        echo " " >> ${top_mem_filename}

        #记录前六条登录记录
         last_filename="${log_path}/mem_trigger_last_${nowdate}.log"
        echo ${nowtime} >> ${last_filename}
       `last | head -n 6 >> ${last_filename}`
        echo " " >> ${last_filename}

         #发报警信息
        `python ${basepath}/sendwechat.py "${nowtime} ${server_name} 内存负载${used_memory_percentage}%"`
        
         #延长50秒再发
         sleep 50

fi
exit 0

#!/bin/sh
#
# monitor file if exist 
#set -x

step=5; #间隔的秒数
monitor_filename="memory_trigger_record.sh"
for (( i = 0; i < 60; i=(i+step) )); do
ret=`ps aux | grep $monitor_filename |grep -v grep`
if [ -z "$ret" ]
then
basepath=$(cd `dirname $0`; pwd)
lockfilename="$basepath/$monitor_filename.lck"
`flock -xn $lockfilename -c $basepath/$monitor_filename`
fi
sleep $step 
done
exit 0

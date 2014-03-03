#!/bin/bash
pwd=`pwd`
broker_file=$pwd/broker_memory_consume
node_file=$pwd/node_memory_consume

if [ $# -ne 1 ];then
	echo "Please input the monitor log file, run format like this:"
	echo -e "\e[1;33m$0 ./log/monitor_*.log \e[0m"
	exit 1
fi

monitor_file=$1

echo "null      total       used       free" > $broker_file
echo "null      total       used       free" > $node_file
cat $monitor_file|grep -A20 jenkins0 | grep 'buffers/cache' >> $broker_file
cat $monitor_file|grep -A66  jenkins0 |grep 'node.*.*' -A20 |grep 'buffers/cache' >> $node_file

./draw2d.sh $broker_file broker_mem_longevity.png 3 4
./draw2d.sh $node_file node_mem_longevity.png 3 4

#cat monitor_server_20130826-225349.log |grep -A 92 jenkins0 |grep -A 50 broker.ose0821.com |grep -A 16 "System process status record"> broker_process.log"
#cat monitor_server_20130826-225349.log |grep -A 92 jenkins0 |grep -A 50 node.ose0821.com |grep -A 16 "System process status record">node_process.log"

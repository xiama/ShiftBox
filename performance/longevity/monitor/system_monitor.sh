#!/bin/bash
which dstat > /dev/null
[ $? -ne 0 ] && yum install dstat -y
dstat -lasmt 1 3
pstree |egrep 'http|java|mongo'
free -m
echo
echo "****** Cpu consume top 3: ******"
ps auxw|head -1;ps auxw|sort -rn -k3|head -3
echo
echo "****** Mem consume top 5: ******"
echo
ps auxw|head -1;ps auxw|sort -rn -k4|head -5

echo
echo "***** System process status record *****"
ps auxw|egrep 'openshift|activemq|mongo|named|cgroup|mcollectived'|grep -v grep

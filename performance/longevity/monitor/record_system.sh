which dstat > /dev/null
[ $? -ne 0 ] && yum install dstat -y

[ -e access_system_log  ] || touch access_system_log
> access_system_log
while true
do
   dstat -lasmt 1 3 >> access_system_log
   echo "" >> access_system_log
   echo "" >> access_system_log
   echo "" >> access_system_log
   sleep 3600
done

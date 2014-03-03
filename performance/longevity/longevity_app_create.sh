#!/bin/bash
###################################### Description ####################################
#  Create app separately with various cartridge, After all the app and cartridge combination
#are created, then cleanup all app, this process is one cycle. 
#
#  We repeated this cycle, During this testing we record the error log, 
#broker and nodes performance record.the time one app create and one cycle testing consumed,
#And these log could help us to know or analysis the performance in a fixed environment.
#
#  You can define the app and cartridge types with config file AutoCreate.cfg by yourself
#######################################################################################
. ./function.sh

[ -d log ] || mkdir log
app_type=$1
pwd=$(pwd)
time=$(date +%Y%m%d-%H%M%S)

#log define
log="$pwd/log/${0%.*}_${time}.log"
cycle_log="$pwd/log/cycle_$time.log"
exec_log="$pwd/log/exec_$time.log"
#monitor_script="monitor-localhost.sh"
monitor_script="system_monitor.sh"

#no_parameter
app_and_cart_delete()
{
        apps=`rhc domain show -p${passwd}|grep uuid|awk '{print $1}'`
        echo_blue "All APPs: $apps"
        value=0
        for app in $apps;do
		output_lines=`rhc app show --state -a $app -p${passwd}|wc -l`
		if [ $output_lines -eq 2 ];then
			cart_name=`rhc app show --state -a $app -p${passwd}|sed -n 2p|awk '{print $2}'`
		else
			if [[ "$app" =~ s$ ]];then
				cart_name=`rhc app show --state -a $app -p${passwd}|awk -F',' 'NF!=2 {print $NF}'|awk '{print $1}'`
			else
				cart_name=`rhc app show --state -a $app -p${passwd}|awk -F',' 'NF!=1 {print $NF}'|awk '{print $1}'`
			fi
		fi
		[ -z "$cart_name" ] || run cartridge_remove $cart_name $app
                run app_delete $app
                [ $? -ne 0 ] && value=1 && break
        done
    return $value
}

#no parameter
app_create_all()
{
	for scale in on off;do
		for app in $app_types;do
			if [ "$app" = "diy-0.1" ] && [ "$scale" = "on" ];then
				echo "Diy is cann't support scalable !"
				continue
			fi
			for cartridge_type in $cartridges;do
				if [ "$scale" = "on" ] && [ "$cartridge_type" = "cron-1.4" ];then
					echo "Cron-1.4 is can not embedded to scalable application!"
				elif [ "$app" = "jbosseap-6.0" ] && [ "$cartridge_type" = "cron-1.4" ];then
					echo "Cron-1.4 is not support jbosseap-6.0"
				elif [ "$scale" = "off" ];then
					run app_create $app
					[ $value -ne 0 ] && run app_create $app
					#run url_check $app_name
					run cartridge_add $cartridge_type $app_name
					[ $value -ne 0 ] && run cartridge_add $cartridge_type $app_name
					#run url_check $app_name
					echo "$app_name			$cartridge_type				nonscalable		$(date +%Y%m%d-%H%M%S)" >> $log
				else
					run app_create $app -s
					[ $value -ne 0 ] && run app_create $app
					#run url_check $app_name
					run cartridge_add $cartridge_type $app_name
					[ $value -ne 0 ] && run cartridge_add $cartridge_type $app_name
					#run url_check $app_name
					echo "$app_name			$cartridge_type				scalable		$(date +%Y%m%d-%H%M%S)" >> $log
				fi
			done
		done
	done
	echo_yellow "Already have $(($app_number)) applications"
}

#node and borker config for monitor
monitor_server_config()
{
if [ -f server.conf ];then
	echo "Will read config from server.conf"
else
	echo -n "Please input the server location: 1(BeiJing), 2(US):"
	read location
	if [ "$location" = "1" ];then
		passwd=redhat
	elif [ "$location" = "2" ];then
		passwd=dog8code
	else
		echo "Please setup the server's password!"
		exit 1
	fi
	nodes=`oo-mco ping|grep time|awk '{print $1}'`	
	
	echo "$(hostname) $(hostname) $passwd" >>server.conf
	for node in $nodes;do
		echo "$node $node $passwd" >>server.conf	
	done
fi
}

#confirm broker and node config ,and deployment script to it
confirm_and_deployment()
{
while read server_alias server_ip server_passwd;do
	echo_yellow "Confirm your $server_alias:"
	echo "HOST: $server_alias,		IP: $server_ip,			Password: $server_passwd"
done < server.conf
echo_blue  "If these info is all right, please input 'yes' to continue: (yes/no)"
read confirm
if [ "$confirm" = "yes" ];then
	while read server_alias server_ip server_passwd;do
		scp_task "$monitor_script" $server_ip $server_passwd "/opt"
	done < server.conf
else 
	echo "Please run it again!"
    exit 1
fi
}
start_monitor()
{
	cd monitor
	monitor_server_config
	confirm_and_deployment
	./performance_monitor.sh ../log/${0%.*}_${time}.log  2>&1 > /dev/null &
	cd -
}

#monitor process start
>$log
start_monitor

run ssh_auth_config
run set_running_parameter
cycle=1
sshkey_name=`rhc sshkey list -l $user -p $passwd|grep type |awk '{print $1}'`
while true;do
	rhc sshkey remove $sshkey_name -l $user -p $passwd
	rhc sshkey add $sshkey_name ~/.ssh/id_rsa.pub -l $user -p $passwd
	[ -d $pwd/testdir ] && rm -rf $pwd/testdir/* || mkdir testdir
	cd testdir
	echo -e "\n### Cycle $cycle start, time : $(date +%Y%m%d-%H%M%S)" |tee -a $cycle_log
	rhc domain show -predhat|grep $jenkins_server > /dev/null
	[ $? -ne 0 ] && run app_create $jenkins_server
	echo "$app_name			jenkins-1			nonscalable		$(date +%Y%m%d-%H%M%S)" >> $log
	run app_create_all 2>&1 |tee -a $exec_log
	echo "### Cycle $cycle end,time : $(date +%Y%m%d-%H%M%S), have $(($app_number)) apps created." |tee -a $cycle_log
	run app_and_cart_delete 2>&1 |tee -a $exec_lo2>&1 |tee -a $exec_log
	app_number=0
	((cycle+=1))
	cd -
done

#!/bin/bash

#Modify the ip address/passwd firstly before testing
brokerIp=10.66.79.85
nodeIp=10.66.78.152
brokerPassword="redhat"
nodePassword="redhat"

[ -f ~/.ssh/id_rsa ] || ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''
rsakey="~/.ssh/id_rsa.pub"

[ -f /usr/bin/expect ] || yum install expect -y
spawn ssh-copy-id  root@${nodeIp} -i ${rsakey}
expect {
	"*password"    {send "${nodePassword}\r";exp_continue}
}
EOF

name="new"
[ -d ./result ] || mkdir ./result

grepBrokerMemOpt=`free |grep Mem|grep -o '[0-9]\+'`
brokerTotalFreeMemory=`echo ${grepBrokerMemOpt} | awk '{print $3}'`
brokerAverageMemory=$((${brokerTotalFreeMemory}/4))
brokerOccupyMemory=$((${brokerAverageMemory}*3))

grepNodeMemOpt=`ssh root@${nodeIp} free |grep Mem|grep -o '[0-9]\+'`
nodeTotalFreeMemory=`echo ${grepNodeMemOpt} | awk '{print $3}'`
nodeAverageMemory=$((${nodeTotalFreeMemory}/8))


haveError()
{

	echo "An error is encountered,will stop the  program."
	# send notify email
	exit 0

}



deleteApp()
{
expect -f - <<EOF
spawn rhc app delete ${name}
expect {
		"*re you sure you want to delete the application"  {send "yes\r";exp_continue}
}
EOF

	[ -d ./${name} ] || rm -rf ${name}
}


createScaleApps()
{
	for types in jbosseap-6 ruby-1.9;
	do
		echo "echo \"Creating Scalable $type $1-$2 ! \" >> load_testing_record" | ssh root@${nodeIp}	
		start_time=$(date '+%s%N')
		ssh root@${nodeIp} mpstat 1 >> load_testing_record &
		rhc app create -a ${name} -t ${types} -s --no-git
		result=$?
		end_time=$(date '+%s%N')
		echo "echo \"Nonscalable $type $1-$2 has been created! \" >> load_testing_record" | ssh root@${nodeIp}
		respone_time=$(((${end_time}-${start_time})/1000000))
		if  [ "${result}" -eq 0 ];then
			echo "${types}:${respone_time}" >> ./result/"$1--$2".txt
			sleep 50

			deleteApp
		fi
		
		ssh root@$nodeIp pkill mpstat
		sleep 50
		
	done
}

createNoScaleApps()
{
	for type in jbosseap-6 ruby-1.9;
	do
	    echo "echo \"Creating Nonscalable $type $1-$2 ! \" >> load_testing_record" | ssh root@${nodeIp}
	    start_time=$(date '+%s%N')
	    ssh root@${nodeIp} mpstat 1 >> load_testing_record &
	    rhc app create -a ${name} -t ${type} --no-git
	    result=$?
	    end_time=$(date '+%s%N')
	    echo "echo \"Nonscalable $type $1-$2 has been created! \" >> load_testing_record" | ssh root@${nodeIp}
	    respone_time=$(((${end_time}-${start_time})/1000000))
	    if  [ "$result" -eq 0 ];then
	        echo "${type}:${respone_time}" >> ./result/"$1--$2".txt
	        sleep 50

	        deleteApp
	    fi
	   
	    ssh root@$nodeIp pkill mpstat
	    sleep 50

	done
}

pkill stress
ssh root@$nodeIp pkill stress

echo "mpstat 1 >> load_testing_record" | ssh root@${nodeIp} &

for i in 0 75
do
        if [[ $i -eq 0 ]]; then
        	pkill stress
        else   
		[ $i -eq 0 ] || stress -c 3 --vm 1  --vm-bytes "${brokerOccupyMemory}k"  --vm-hang 100000000  1>stress.log 2>&1 &
		[ $? -eq 0 ] || haveError
	fi
	
	sleep 50

	for((j=0;j<=8;j++))
	do
		if [[ $j -eq 0 ]]; then
			ssh root@${nodeIp} pkill stress
			sleep 30
		else
			ssh root@${nodeIp}  stress -c 3 --vm 1  --vm-bytes "${nodeAverageMemory}k"  --vm-hang 100000000  1>stress.log 2>&1 &
			[ $? -eq 0 ] || haveError
			sleep 50
		fi

		
		createScaleApps $i $j
		echo "--------------------------------------------------------------------" >> ./result/"${i}--${j}".txt
		createNoScaleApps $i $j
		
	done
done

pkill stress
ssh root@${nodeIp} pkill stress



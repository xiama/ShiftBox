echo "This script will generate 100 users and create 2 app for each user"
sleep 3
[ -f /usr/bin/expect ] || yum install expect -y

#create app
for i in `seq 1 100`
do
  #register users in htpasswd
  htpasswd -nb user$i redhat >> /etc/openshift/htpasswd
 
  #rhc setup for users 
  expect -f - <<EOF
  spawn rhc setup -l user$i -predhat
  expect {
        "checking the certificate?*"      {send "yes\r";exp_continue}
        "Generate a token now?*"      {send "no\r";exp_continue}
        "Upload now?*"                {send "yes\r";exp_continue}
        "Please enter a namespace*"   {send "name$i\r";exp_continue}
  }
EOF
  
  #create 2 apps for each user
  rhc app create app$i python-2.6 -l user$i -predhat --no-git
  rhc app create app jbosseap-6 -l user$i -predhat --no-git
  rhc app stop app -l user$i -predhat
done 

sleep 300

#make result dir
[ -d ./result ] || mkdir ./result
rm -rf result/*

#domain show concurrently
for j in 1 10 20 30 40 50 60 70 80 90 100
do
  echo "**********Get domain info for $j user***********************"
  for i in `seq 1 $j`; do (time -p rhc domain show -l user$i -predhat) 2>>result/domain_show$j  & done
  sleep 60
done

#get the avg response time and write them into file test_results
echo "Now generating the avgs..."
for f in 1 10 20 30 40 50 60 70 80 90 100
do
  echo "$f user: " >> test_results
  cat result/domain_show$f | grep real | awk '{sum+=$2}END{print sum/NR}'  >> test_results
  echo "" >> test_results
  sleep 1
done



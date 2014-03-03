echo "Input the number of apps you want to create concurrently:"
read j
[ -d ./Jboss ] || mkdir ./Jboss

echo "The time of Creating $j JbossEAP-6.0 app:" >> Jboss/Jboss_time$j

for i in `seq 1 $j`
do
  (time -p rhc app create app$i jbosseap-6 -l user$i -predhat) 2>> Jboss/Jboss_time$j  & 
done

#echo "The time of Creating $j php app:" >> PHP/php_time$j
#
#for i in `seq 1 $j`
#do
#  (time -p rhc app create app$i php -l user$i -predhat) 2>> PHP/php_time$j  &    
#done

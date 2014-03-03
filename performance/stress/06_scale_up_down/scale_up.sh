echo "Input the number of apps you want to scale-up:"
read j
[ -d ./up ] || mkdir ./up

echo "The time of scale-up $j apps:" >> up/up_time$j

for i in `seq 1 $j`
do
  (time -p curl -k -H "Accept: application/xml" --user "user$i:redhat" https://broker.stress.com/broker/rest/domains/name$i/applications/app$i/events -X POST -d event=scale-up) 2>> up/upjbosseap_time$j  & 
done

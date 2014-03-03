echo "Input the number of apps you want to create concurrently:"
read j

echo "The time of Deleting $j Jboss app:" >> Jboss/Jboss_dele_time$j
for i in `seq 1 $j`
do
  (time -p rhc app delete --confirm  app$i  -l user$i -predhat) 2>> Jboss/Jboss_dele_time$j  & 
done

rm -rf app*

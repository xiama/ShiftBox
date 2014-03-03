#j in 5 10 20 30 40 50 60 70 80 90 100
echo "Input the number of apps you want to make snapshot-save:"
read j

rm -rf /tmp/app*
[ -d ./save_test ] || mkdir ./save_test

for i in `seq 1 $j`
do
  (time -p rhc snapshot save -a app$i -l user$i -predhat -f /tmp/app$i.tar.gz) 2>>save_test/snapshot_save$j  & 
done

#j in 5 10 20 30 40 50 60 70 80 90 100
echo "Input the number of apps you want to make snapshot-restore:"
read j

[ -d ./restore_test ] || mkdir ./restore_test
[ -d ./app_repo ] || mkdir ./app_repo

cloud_domain=`hostname | sed 's/broker\.//g'`
#make change for the python apps
cd ./app_repo
rm -rf app*
for i in `seq 1 $j`
do
  expect -f - <<EOF
  spawn rhc git-clone app$i -l user$i -predhat
  expect {
        "Are you sure you want to continue connecting*"      {send "yes\r";exp_continue}
  }
EOF
  cd app$i && sed -i 's/OpenShift/basketball/g' wsgi.py && git add . && git commit -a -m'modify' && git push &&cd -
done

cd ..
sleep 300

#restore the apps using tar ball
for i in `seq 1 $j`
do
  (time -p rhc snapshot restore -a app$i -l user$i -predhat -f /tmp/app$i.tar.gz) 2>>restore_test/snapshot_restore$j  &
done

sleep 60
#verify the apps were restored
for i in `seq 1 $j`
do
  aa=$(curl app$i-name$i.$cloud_domain|grep OpenShift)
  if [ -z $aa ];then
    echo "!!!!!!!!!!!!!!!!!!!!1app$i failed"
  else
    echo "app$i succeed^^ ^^ ^^ ^^ ^^"
  fi
done


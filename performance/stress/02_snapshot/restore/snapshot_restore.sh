echo "Input the number of apps you want to make snapshot-restore:"
read j

[ -d ./restore_test ] || mkdir ./restore_test
[ -d ./app_repo ] || mkdir ./app_repo

#make change for the apps
cd ./app_repo
for i in `seq 1 $j`
do
  rhc git-clone app$i -l user$i -predhat
  cd app$i && sed -i 's/OpenShift/basketball/g' wsgi/application && git add . && git commit -a -m'modify' && git push &&cd -
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
  aa=$(curl app$i-name$i.stress.com|grep OpenShift)
  if [ -z $aa ];then
    echo "!!!!!!!!!!!!!!!!!!!!1app$i failed"
  else
    echo "app$i succeed"
  fi
done


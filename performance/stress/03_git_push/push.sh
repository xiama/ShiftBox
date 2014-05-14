echo "Input the number of git push :"
read j

cloud_domain=`hostname | sed 's/broker\.//g'`

[ -d ./git_test ] || mkdir ./git_test
rm -rf git_test/*
[ -d ./app_repo ] || mkdir ./app_repo
rm -rf app_repo/*

#make change for the python-2.6 apps
cd ./app_repo
for i in `seq 1 $j`
do
  expect -f - <<EOF
  spawn rhc git-clone app$i -l user$i -predhat
  expect {
        "Are you sure you want to continue connecting (yes/no)?*"   {send "yes\r";exp_continue}
  }
EOF

 # rhc git-clone app$i -l user$i -predhat
  cd app$i && sed -i 's/OpenShift/basketball/g' wsgi.py && git add . && git commit -a -m 'Update page' &&cd -
done

cd ..
sleep 60

#git push concurrently
for i in `seq 1 $j`
do
  cd app_repo/app$i 
  (time -p git push) 2>> ../../git_test/git_push$j &
  cd -
done

sleep 60

#verify the changes
for i in `seq 1 $j`
do
  aa=$(curl app$i-name$i.$cloud_domain|grep basketball)
  if [ -z $aa ];then
    echo "!!!!!!!!!!!!!!!!!!!!1app$i failed"
  else
    echo "app$i succeed^.^ ^.^ ^.^"
  fi
done


#recovery the changes
cd ./app_repo
for i in `seq 1 $j`
do
  cd app$i && sed -i 's/basketball/OpenShift/g' wsgi.py && git add . && git commit -a -m 'recover the change' &&git push &&cd -
done

cd ..


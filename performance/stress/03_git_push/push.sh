echo "Input the number of git push :"
read j

[ -d ./git_test ] || mkdir ./git_test
[ -d ./app_repo ] || mkdir ./app_repo

#make change for the python apps
cd ./app_repo
for i in `seq 1 $j`
do
  rhc git-clone app$i -l user$i -predhat
  cd app$i && sed -i 's/OpenShift/basketball/g' wsgi/application && git add . && git commit -a -m'modify' &&cd -
done

cd ..
sleep 60

#git push concurrently
for i in `seq 1 $j`
do
  cd app_repo/app$i 
  (time -p git push) 2>> ../../git_test/git_push$m &
  cd -
done

sleep 60

#verify the changes
for i in `seq 1 $j`
do
  aa=$(curl app$i-name$i.stress.com|grep basketball)
  if [ -z $aa ];then
    echo "!!!!!!!!!!!!!!!!!!!!1app$i failed"
  else
    echo "app$i succeed"
  fi
done


#recovery the changes
cd ./app_repo
for i in `seq 1 $j`
do
  cd app$i && sed -i 's/basketball/OpenShift/g' wsgi/application && git add . && git commit -a -m'modify' &&git push &&cd -
done

cd ..


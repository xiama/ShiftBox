echo "Input the number of ssh keys:"
read j

for i in `seq 1 $j`; do (time -p rhc sshkey remove foo$i -l user$i -predhat) 2>> time/remove_key$j & done

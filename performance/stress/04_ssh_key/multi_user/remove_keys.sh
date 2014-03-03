echo "Input the number of ssh keys:"
read j

for i in `seq 1 $j`; do rhc sshkey remove foo$i -l user$i -predhat & done

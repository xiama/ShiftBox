echo "Input the number of keys:"
read j

rm -rf /tmp/foo*

[ -d ./time ] || mkdir ./time
for i in `seq 1 $j`; do ssh-keygen -f /tmp/foo$i -t rsa -N ''; done
echo "SSH keys generated"
sleep 10
for i in `seq 1 $j`; do (time -p rhc sshkey add --confirm foo$i /tmp/foo$i.pub -l user$i -predhat) 2>> time/add_key$j & done

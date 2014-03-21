echo "Input the number of keys:"
read j

rm -rf /tmp/foo*

for i in `seq 1 $j`; do ssh-keygen -f /tmp/foo$i -t rsa -N ''; done
echo "SSH keys generated"
sleep 3
for i in `seq 1 $j`; do rhc sshkey add --confirm foo$i /tmp/foo$i.pub -l user$i -predhat & done

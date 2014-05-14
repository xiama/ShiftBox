#create apps for user gpei
app_type="jbosseap-6 nodejs-0.10 perl-5.10 php-5.3 php-5.4 python-2.6 python-2.7 jbossews-1.0 jbossews-2.0 ruby-1.9"
j=1
rm -rf /tmp/foo*
for i in `seq 1 100`; do ssh-keygen -f /tmp/foo$i -t rsa -N ''; done

for i in $app_type
do 
  
  rhc app create app$j $i --no-git -l gpei -predhat
  let j++
  rhc app create app$j $i -s --no-git -l gpei -predhat
  rhc cartridge scale -c $i -a app$j --min 2 -l gpei -predhat
  let j++
done


for i in `seq 1 30`
do
  echo "the $i app: ">> time 
  (time -p rhc sshkey add --confirm foo$i /tmp/foo$i.pub -l gpei -predhat) 2>> time 
  echo "" >> time
done


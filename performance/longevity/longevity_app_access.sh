#!/bin/bash
pwd=$(pwd)
curl_example_file=$pwd/../src/example.conf
curl_conf_file=$pwd/app_access.conf
[ -d $pwd/log/longevity_app_access ] || mkdir  -p $pwd/log/longevity_app_access

local_ip=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`

. function.sh
app_types="jbosseap-6 php-5.3 diy-0.1 python-2.6 ruby-1.9 ruby-1.8 perl-5.10 jbossews-1.0 jbossews-2.0 python-2.7 nodejs-0.10"



curl_loader_conf_file()
{
cp $curl_example_file $curl_conf_file
sed -i s/192.168.55.16/$local_ip/g $curl_conf_file
app_names=`rhc domain show -predhat|grep http|awk -F'@' '{print $1}'`
number=`echo $app_names|wc -w`
for name in $app_names;do
    cat >> $curl_conf_file <<EOF
########### URL SECTION ####################################
URL=http://$name-$domain.${broker_url#*.}
URL_SHORT_NAME="$name"
REQUEST_TYPE=GET
TIMER_URL_COMPLETION = 8000
TIMER_AFTER_URL_SLEEP = 500
EOF
done
sed -i s/URLS_NUM=6/URLS_NUM=$number/g $curl_conf_file
}

curl_loader_install()
{
cd $pwd/../src/
yum install openssl openssl-devel -y
tar xvf curl-loader*.tar.gz
cd curl-loader-0.56
make && make install
value=$?
cd -
return $value
}

run ssh_auth_config
which curl-loader > /dev/null
[ $? -eq 0 ] || run curl_loader_install

#app created
[ -d $pwd/testdir ] && rm -rf $pwd/testdir/* || mkdir testdir
cd testdir
for app in $app_types;do
    run app_create $app
done
cd -

cd $pwd
run curl_loader_conf_file
cd $pwd/log/longevity_app_access
sleep 10
curl-loader -v -f $curl_conf_file

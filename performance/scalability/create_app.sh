#!/bin/sh
[ -f /usr/bin/expect ] || yum install expect -y
> /etc/openshift/htpasswd

script_dir=$(dirname $0)
pushd $script_dir >/dev/null && script_real_dir=$(pwd) && popd >/dev/null
LIB_DIR="${script_real_dir}/../../lib"

source ${LIB_DIR}/openshift.sh
source ${LIB_DIR}/util.sh

########################################
###             Main                 ###
########################################
APP_TYPE="php-5.3"
#APP_TYPE="jbosseap-6"
#APP_TYPE="nodejs-0.10"
#RHLOGIN="gpei"
PASSWD="redhat"
APP_PREFIX="app"
SCALING="True"
STOPPED="False"
START=1
END=1000
RETRY=5
INTERVAL=40

[ -d app_repo ] || mkdir app_repo

log_file=${script_real_dir}/$(initial_log)

i=$START
while [ $i -le $END ]; do

    htpasswd -nb user$i redhat >> /etc/openshift/htpasswd
    expect -f - <<EOF
  spawn rhc setup -l user$i -predhat
  expect {
        "Generate a token now?*"      {send "no\r";exp_continue}
        "Upload now?*"                {send "yes\r";exp_continue}
        "Please enter a namespace*"   {send "name$i\r";exp_continue}
  }
EOF

    RHLOGIN=user$i
    j=0
    ret="1"
    while [ X"$ret" != X"0" ] && [ $j -le $RETRY ]; do
        rhc app delete ${APP_PREFIX}${i} --confirm -l ${RHLOGIN} -p ${PASSWD}
	cd app_repo/
        if [ X"$SCALING" == X"True" ]; then
            create_app ${APP_PREFIX}${i} ${APP_TYPE} ${RHLOGIN} ${PASSWD} -s
        else
            create_app ${APP_PREFIX}${i} ${APP_TYPE} ${RHLOGIN} ${PASSWD}
        fi
        ret=$?
        j=$(expr $j + 1)
        sleep $INTERVAL
	cd ..
    done

    if [ X"$ret" != X"0" ]; then
        break
    fi

    if [ X"$STOPPED" == X"True" ]; then
        control_app ${APP_PREFIX}${i} ${RHLOGIN} ${PASSWD} stop || break
    fi

    i=$(expr $i + 1)
    echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' | tee -a ${log_file}
done



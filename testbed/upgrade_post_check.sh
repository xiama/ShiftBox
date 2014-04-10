#!/bin/bash
script_dir=$(dirname $0)
script_name=$(basename $0)
pushd $script_dir >/dev/null && script_real_dir=$(pwd) && popd >/dev/null
LIB_DIR="${script_real_dir}/../lib"

source ${LIB_DIR}/openshift.sh
source ${LIB_DIR}/util.sh

########################################
###             Main                 ###
########################################

source check_lib.sh
source app.conf


# initial log
date=$(get_date)
log_file="log/${script_name}.${date}.log"
user_info_file="user_info.${date}"

if [ ! -d log ]; then
    mkdir log
fi

touch ${log_file}

print_warnning "Pls firstly run oo-diagnostics on both broker and nodes to make sure your env pass sanity test !!!"

#set -x
failed_app=""
warnning=""

echo -e "Please input your choice\n 0: all data \n Specified app: ${app_list// /|}"
read choice

echo -e "Do you want to delete and re-add jenkins-client for existing apps? [Y|N]"
read re_add_jenkins_clent

echo '***********************************************' | tee -a ${log_file}
if [ X"${re_add_jenkins_clent}" == X"Y" ]; then
    destroy_app "${jenkins_app}" ${rhlogin} ${password}
    create_app ${jenkins_app} "jenkins" ${rhlogin} ${password} "--no-git" || exit 1
    for app in ${app_list}; do
        eval app_name="$"${app}
        if echo ${app_name} | grep -q 'jks'; then
            destroy_app "${app_name}bldr" ${rhlogin} ${password}
            add_cart "${app_name}" "jenkins-client" ${rhlogin} ${password} || exit 1
        fi
    done
fi


echo '***********************************************' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || include_item "${choice}" "new_app"; then
    create_new_app_check ${new_app} ${rhlogin} ${password} "2" &&
    warnning_msg="${warnning_msg}\n${new_app}: Pls check app's haproxy-status page to make sure all web gears are listed there!!!" || failed_app="${failed_app}${new_app} "
fi


echo '***********************************************' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || include_item "${choice}" "php53_app"; then
    php53_app_check ${php53_app} ${rhlogin} ${password} "1" "2" &&
    warnning_msg="${warnning_msg}\n${php53_app}: Remember to ssh into app to check psql connection!!!" || failed_app="${failed_app}${php53_app} "
fi


echo '***********************************************' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || include_item "${choice}" "perl510_app"; then 
    perl510_app_check ${perl510_app} ${rhlogin} ${password} "1" "2" "modify" || failed_app="${failed_app}${perl510_app} "
fi


echo '***********************************************' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || include_item "${choice}" "python26_app"; then
    python26_app_check ${python26_app} ${rhlogin} ${password} || failed_app="${failed_app}${python26_app} "
fi


echo '***********************************************' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || include_item "${choice}" "python27_app"; then
    python27_app_check ${python27_app} ${rhlogin} ${password} || failed_app="${failed_app}${python27_app} "
fi


echo '***********************************************' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || include_item "${choice}" "ruby18_app"; then 
    ruby18_app_check ${ruby18_app} ${rhlogin} ${password} "bar.${domain}.com" && 
    warnning_msg="${warnning_msg}\n${ruby18_app}: Remember to ssh into app to check mysql connection!!!" || failed_app="${failed_app}${ruby18_app} "
fi


echo '***********************************************' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || include_item "${choice}" "ruby19_app"; then
    ruby19_app_check ${ruby19_app} ${rhlogin} ${password} "1" "2"  &&
    warnning_msg="${warnning_msg}\n${ruby19_app}: Take note of the count of lines including 'SignalException' to compare with next check!!!" || failed_app="${failed_app}${ruby19_app} "
fi


echo '***********************************************' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || include_item "${choice}" "nodejs010_app"; then
    nodejs010_app_check ${nodejs010_app} ${rhlogin} ${password} || failed_app="${failed_app}${nodejs010_app} "
fi


echo '***********************************************' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || include_item "${choice}" "jbossews10_app"; then
    jbossews10_app_check ${jbossews10_app} ${rhlogin} ${password} "1" "2" || failed_app="${failed_app}${jbossews10_app} "
fi


echo '***********************************************' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || include_item "${choice}" "jbossews20_app"; then
    jbossews20_app_check ${jbossews20_app} ${rhlogin} ${password} "1" "2" || failed_app="${failed_app}${jbossews20_app} "
fi


echo '***********************************************' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || include_item "${choice}" "jbosseap6_app"; then
    jbosseap6_app_check ${jbosseap6_app} ${rhlogin} ${password} "1" "2" "modify" || failed_app="${failed_app}${jbosseap6_app} "
fi


echo '***********************************************' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || include_item "${choice}" "diy_app"; then
    diy_app_check ${diy_app} ${rhlogin} ${password} || failed_app="${failed_app}${diy_app} "
fi


echo '***********************************************' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || include_item "${choice}" "scalable_php53_app"; then
    scalable_php53_app_check ${scalable_php53_app} ${rhlogin} ${password} "2"  &&
    warnning_msg="${warnning_msg}\n${scalable_php53_app}: Pls check app's haproxy-status page to make sure all web gears are listed there!!!" || failed_app="${failed_app}${scalable_php53_app} "
fi


echo '***********************************************' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || include_item "${choice}" "scalable_perl510_app"; then
    scalable_perl510_app_check ${scalable_perl510_app} ${rhlogin} ${password} "1" "2" "modify" "2" &&
    warnning_msg="${warnning_msg}\n${scalable_perl510_app}: Pls check app's haproxy-status page to make sure all web gears are listed there!!!" || failed_app="${failed_app}${scalable_perl510_app} "
fi


echo '***********************************************' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || include_item "${choice}" "scalable_python26_app"; then
    scalable_python26_app_check ${scalable_python26_app} ${rhlogin} ${password} "1" "2" "modify" "2" &&
    warnning_msg="${warnning_msg}\n${scalable_python26_app}: Pls check app's haproxy-status page to make sure all web gears are listed there!!!" || failed_app="${failed_app}${scalable_python26_app} "
fi


echo '***********************************************' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || include_item "${choice}" "scalable_python27_app"; then
    scalable_python27_app_check ${scalable_python27_app} ${rhlogin} ${password} "1" "2" "2" &&
    warnning_msg="${warnning_msg}\n${scalable_python27_app}: Pls check app's haproxy-status page to make sure all web gears are listed there!!!" || failed_app="${failed_app}${scalable_python27_app} "
fi


echo '***********************************************' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || include_item "${choice}" "scalable_ruby18_app"; then
    scalable_ruby18_app_check ${scalable_ruby18_app} ${rhlogin} ${password} "rhc-cartridge1" "2" "start" || failed_app="${failed_app}${scalable_ruby18_app} "
fi


echo '***********************************************' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || include_item "${choice}" "scalable_ruby19_app"; then
    scalable_ruby19_app_check ${scalable_ruby19_app} ${rhlogin} ${password} || failed_app="${failed_app}${scalable_ruby19_app} "
fi


echo '***********************************************' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || include_item "${choice}" "scalable_nodejs010_app"; then
    scalable_nodejs010_app_check ${scalable_nodejs010_app} ${rhlogin} ${password} "1" "2" "2" "scale-down" "${domain}" &&
    warnning_msg="${warnning_msg}\n${scalable_nodejs010_app}: Pls check app's haproxy-status page to make sure all web gears are listed there!!!" || failed_app="${failed_app}${scalable_nodejs010_app} "
fi


echo '***********************************************' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || include_item "${choice}" "scalable_jbossews10_app"; then
    scalable_jbossews10_app_check ${scalable_jbossews10_app} ${rhlogin} ${password} "1" "2" && 
    warnning_msg="${warnning_msg}\n${scalable_jbossews10_app}: Remember to ssh into app to check mysql connection!!!" || failed_app="${failed_app}${scalable_jbossews10_app} "
fi


echo '***********************************************' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || include_item "${choice}" "scalable_jbossews20_app"; then
    scalable_jbossews20_app_check ${scalable_jbossews20_app} ${rhlogin} ${password} "1" "2" &&
    warnning_msg="${warnning_msg}\n${scalable_jbossews20_app}: Take note of the count of lines including 'PSPermGen' to compare with next check!!!" || failed_app="${failed_app}${scalable_jbossews20_app} "
fi


echo '***********************************************' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || include_item "${choice}" "scalable_jbosseap6_app"; then
    scalable_jbosseap6_app_check ${scalable_jbosseap6_app} ${rhlogin} ${password} "1" "2" "modify" "scale-up" && 
    warnning_msg="${warnning_msg}\n${scalable_jbosseap6_app}: Remember to ssh into app to check psql connection!!!" &&
    warnning_msg="${warnning_msg}\n${scalable_jbosseap6_app}: Take note of the count of lines including 'PSPermGen' to compare with next check!!!" &&
    warnning_msg="${warnning_msg}\n${scalable_jbosseap6_app}: Pls check app's haproxy-status page to make sure all web gears are listed there!!!" || failed_app="${failed_app}${scalable_jbosseap6_app} "

fi

echo '***********************************************' | tee -a ${log_file}
if [ X"$choice" == X"0" ] || include_item "${choice}" "scalable_jbosseap6_app1"; then
    scalable_jbosseap6_app1_check ${scalable_jbosseap6_app1} ${rhlogin} ${password} "1" "2" "2" &&
    warnning_msg="${warnning_msg}\n${scalable_jbosseap6_app1}: Pls check app's haproxy-status page to make sure all web gears are listed there!!!" || failed_app="${failed_app}${scalable_jbosseap6_app1} "
fi

echo '***********************************************' | tee -a ${log_file}

warnning_msg="${warnning_msg}\nWeb Console: Pls remember to log into web console to make sure it woking well !!!"
warnning_msg="${warnning_msg}\nAuth Tokens: Pls remember to check previous auth tokens is working well, and use 'rm -rf ~/.openshift/token*; rhc setup' to create a new one, make sure rhc command does NOT requrired password !!!"
print_warnning "${warnning_msg}"

echo "Failed app list:"
print_red_txt "${failed_app}"

# Save user info into file
#echo "Saving user info for ${domain}"
#rhc domain show -l ${rhlogin} -p ${password} | tee ${user_info_file}

#set +x

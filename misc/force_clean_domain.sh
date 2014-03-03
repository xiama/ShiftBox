#!/bin/sh
script_dir=$(dirname $0)
pushd $script_dir >/dev/null && script_real_dir=$(pwd) && popd >/dev/null
LIB_DIR="${script_real_dir}/../lib"

source ${LIB_DIR}/openshift.sh
source ${LIB_DIR}/util.sh

########################################
###             Main                 ###
########################################

if [ X"$#" != X"3" ]; then
    echo "rhlogin password and namespace ???"
    exit 1
fi

rest_api_force_clean_domain  $3 $1 $2

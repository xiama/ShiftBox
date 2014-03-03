#!/bin/sh

echo "Input domain name. By default, its domains is rhn.com"
read domain_name
if [ X"$domain_name" == X"" ]; then
    domain_name="rhn.com"
fi

echo "Input internal IP for broker"
read broker_ip

echo "Input node name, e.g: node1"
read node_name

echo "Input external IP for ${node_name}"
read node_ip

echo "Start sync date"
service ntpd stop; ntpdate clock.redhat.com; service ntpd start


ip_addr=$(ifconfig eth0 | grep 'inet addr:' | awk '{print $2}' | awk -F':' '{print $2}')

sed -i "s|prepend domain-name-servers .*|prepend domain-name-servers ${broker_ip};|g" /etc/dhcp/dhclient-eth0.conf

sed -i "s|supersede host-name .*|supersede host-name \"${node_name}.${domain_name}\";|g" /etc/dhcp/dhclient-eth0.conf

sed -i "s|supersede domain-name .*|supersede domain-name \"${domain_name}\";|g" /etc/dhcp/dhclient-eth0.conf

sed -i "s|HOSTNAME=.*|HOSTNAME=${node_name}.${domain_name}|g" /etc/sysconfig/network

sed -i "s|PUBLIC_IP=.*|PUBLIC_IP=${node_ip}|g" /etc/openshift/node.conf

sed -i "s|PUBLIC_HOSTNAME=.*|PUBLIC_HOSTNAME=${node_name}.${domain_name}|g" /etc/openshift/node.conf

sed -i "s|BROKER_HOST=.*|BROKER_HOST=broker.${domain_name}|g" /etc/openshift/node.conf

sed -i "s|CLOUD_DOMAIN=.*|CLOUD_DOMAIN=${domain_name}|g" /etc/openshift/node.conf

if [ -e /etc/openshift/env/OPENSHIFT_CLOUD_DOMAIN ]; then
    old_domain_name=$(cat /etc/openshift/env/OPENSHIFT_CLOUD_DOMAIN)
    if [ X"${old_domain_name}" != X"${domain_name}" ]; then
        sed -i "s|${old_domain_name}|${domain_name}|g" /etc/openshift/env/*
    fi
fi

sed -i "s|ServerName .*|ServerName ${node_name}.${domain_name}|g" /etc/httpd/conf.d/000001_openshift_origin_node_servername.conf

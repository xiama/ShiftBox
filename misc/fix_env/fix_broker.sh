#!/bin/sh

echo "Input domain name that the exising DNS is using. if you input empty, domain name will be rhn.com"
read domain_name
if [ X"$domain_name" == X"" ]; then
    domain_name="rhn.com"
fi

echo "Input external IP for broker"
read broker_ip

echo "What is your node's hostnmae?"
read node_name

echo "Input external IP for ${node_name}"
read node_ip

echo "Start sync date"
service ntpd stop
ntpdate clock.redhat.com
service ntpd start

ip_addr=$(ifconfig eth0 | grep 'inet addr:' | awk '{print $2}' | awk -F':' '{print $2}')
oo-register-dns -h activemq -n ${ip_addr} -d ${domain_name}
oo-register-dns -h datastore -n ${ip_addr} -d ${domain_name}
oo-register-dns -h ns1 -n ${ip_addr} -d ${domain_name}
oo-register-dns -h broker -n ${broker_ip} -d -d ${domain_name}
oo-register-dns -h ${node_name} -n ${node_ip} -d -d ${domain_name}

sed -i "s|prepend domain-name-servers .*|prepend domain-name-servers ${ip_addr};|g" /etc/dhcp/dhclient-eth0.conf

sed -i "s|BIND_SERVER=.*|BIND_SERVER=${ip_addr}|g" /etc/openshift/plugins.d/openshift-origin-dns-*.conf

#!/bin/bash
#ubuntu14.04

#install openssl-1.0.1g instead of 1.0.1f
curl https://www.openssl.org/source/openssl-1.0.1g.tar.gz | tar xz && cd openssl-1.0.1g
./configure && make && make install_sw
apt-get update -y -q && apt-get install openvpn easy-rsa -y
gzip  -d /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz
cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf /etc/openvpn/
ln -s openssl-1.0.0.cnf openssl.cnf


chmod +x /etc/openvpn/vars
cd /etc/openvpn && source ./vars
./clean-all
./build-ca
./build-key-server oa.xxx.com
./build-dh
./build-key oa-xxx-cd
openvpn --genkey --secret /etc/openvpn/keys/ta.key
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p 
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to 5.79.17.xx

cat > /etc/openvpn/server.conf <<EOF
port 1194
proto udp
dev tun
ca keys/ca.crt
cert keys/oa.xxx.com.crt
key keys/oa.xxx.com.key  # This file should be kept secret
dh keys/dh2048.pem
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 208.67.220.222"
push "dhcp-option DNS 208.67.220.220"
keepalive 10 120
tls-auth keys/ta.key 0 # This file is secret
comp-lzo
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
log         /var/log/openvpn.log
verb 3
EOF


# dnsmasq pdnsd ipset shadowsocks-libev iptables
#install dnsmasq
touch ser.conf ser-ipset.conf

#install pdns
apt-get install -y pdnsd
#see pdnsd.conf notice: query_method=tcp_only;
#and find a kr dns server:59.11.140.26

#create ipset
ipset -N bypass_vpn iphash

ipset list


#install  shadowsocks-libev
#ref:https://github.com/binhoul/shadowsocks-libev
cd shadowsocks-libev/
sudo apt-get install build-essential autoconf libtool libssl-dev     gawk debhelper dh-systemd init-system-helpers pkg-config
dpkg-buildpackage -us -uc -i
#run ss-dir
screen ss-redir -v -b 0.0.0.0 -c /etc/shadowsocks-libev/config.json


#set a server as a nat server
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -s 10.0.1.0/24 -j SNAT --to-source 10.0.0.242
iptables -t nat -A PREROUTING -p tcp -m set --match-set bypass_vpn dst -j REDIRECT --to-ports 1080



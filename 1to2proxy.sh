#!/bin/bash
#
# 1to2proxy - IP Address Replacement Script
#
# РЕКОМЕНДОВАННЫЙ СПОСОБ ЗАПУСКА:
# sudo bash <(wget -qO- https://raw.githubusercontent.com/Mortyo666/1to2proxy/main/1to2proxy.sh)
#
# ВНИМАНИЕ: Запускайте скрипт ТОЛЬКО из официального репозитория!
# Официальный репозиторий: https://github.com/Mortyo666/1to2proxy
#

iplist=$(ip a | grep "inet " | grep -v '127.0.0.1\|10.180.' | cut -d "/" -f1 | rev | cut -d " " -f1 | rev )
ip1=$(echo $iplist | cut -d " " -f1)
ip2=$(echo $iplist | cut -d " " -f2)

echo "Replacing incoming ip's from $ip1 to $ip2"

sed -i "s/internal ${ip1}/internal ${ip2}/g" /etc/3proxy.cfg && service 3proxy restart && echo "3proxy Ok"

sed -i "s/local ${ip1}/local ${ip2}/g" /etc/openvpn/server/server-udp.conf && \
sed -i "s/local ${ip1}/local ${ip2}/g" /etc/openvpn/server/server-tcp.conf && \
systemctl restart openvpn-server@server-tcp.service && \
systemctl restart openvpn-server@server-udp.service && \
echo "OpenVPN Ok"

cd /var/www/html/*/ && \
find . -type f | xargs sed -i "s/${ip1}/${ip2}/g" && \
rm -f all.zip *.png && \
zip all.zip *.ovpn && \
echo "OpenVPN config replace Ok"

cd /var/www/html/*/ && \
find . -iname '*.conf' -exec sh -c "cat {} | qrencode -t PNG -o {}.png" \;

sed -i "s/${ip2}/${ip1}/g" /etc/sysconfig/iptables && \
service iptables save && \
systemctl restart iptables.service

systemctl restart wg-quick@wg00.service

#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
clear
read -p "Password: " -e username
CLIENT_EXISTS=$(grep -w $username /etc/shadowsocks-libev/akun.conf | wc -l)
if [[ ${CLIENT_EXISTS} == '0' ]]; then
exit 1
fi
user=$(grep -E "^### " "/etc/shadowsocks-libev/akun.conf" | cut -d ' ' -f 2 | egrep -w "$username")
data=$(grep -E "^### " "/etc/shadowsocks-libev/akun.conf" | cut -d ' ' -f 2-3 | egrep -w "$username")
cat > /root/ss.txt <<-END
$data
END
exp=$(cat /root/ss.txt | cut -d ' ' -f 2)

# remove [Peer] block matching $CLIENT_NAME
sed -i "/^### $user $exp/,/^port_http/d" "/etc/shadowsocks-libev/akun.conf"
# remove generated client file
service cron restart
systemctl disable shadowsocks-libev-server-$user-tls.service
systemctl disable shadowsocks-libev-server-$user-http.service
systemctl stop shadowsocks-libev-server-$user-tls.service
systemctl stop shadowsocks-libev-server-$user-http.service
rm -f "/etc/shadowsocks-libev/$user-tls.json"
rm -f "/etc/shadowsocks-libev/$user-http.json"
clear
echo " SS OBFS Account Deleted Successfully"
echo " =========================="
echo " Client Name : $user"
echo " Expired On  : $exp"
echo " =========================="
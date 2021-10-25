#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
clear
read -p "Password: " -e username
CLIENT_EXISTS=$(grep -w $username /etc/wireguard/wg0.conf | wc -l)
if [[ ${CLIENT_EXISTS} == '0' ]]; then
exit 1
fi
user=$(grep -E "^### Client" "/etc/wireguard/wg0.conf" | cut -d ' ' -f 3 | egrep -w "$username")
data=$(grep -E "^### Client" "/etc/wireguard/wg0.conf" | cut -d ' ' -f 3-4 | egrep -w "$username")
cat > /root/wg.txt <<-END
$data
END
exp=$(cat /root/wg.txt | cut -d ' ' -f 2)
# remove [Peer] block matching $CLIENT_NAME
sed -i "/^### Client $user $exp/,/^AllowedIPs/d" /etc/wireguard/wg0.conf
# remove generated client file
rm -f "/home/vps/public_html/$user.conf"

# restart wireguard to apply changes
systemctl restart "wg-quick@$SERVER_WG_NIC"
service cron restart
clear
echo " Wireguard Account Deleted Successfully"
echo " =========================="
echo " Client Name : $user"
echo " Expired  On : $exp"
echo " =========================="
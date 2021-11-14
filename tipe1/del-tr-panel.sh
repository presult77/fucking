#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
clear
read -p "Password: " -e username
CLIENT_EXISTS=$(grep -w $username /etc/trojan/akun.conf | wc -l)
if [[ ${CLIENT_EXISTS} == '0' ]]; then
exit 1
fi
user=$(grep -E "^### " "/etc/trojan/akun.conf" | cut -d ' ' -f 2 | egrep -w "$username")
data=$(grep -E "^### " "/etc/trojan/akun.conf" | cut -d ' ' -f 2-3 | egrep -w "$username")
cat > /root/trojan.txt <<-END
$data
END
exp=$(cat /root/trojan.txt | cut -d ' ' -f 2)
sed -i "/^### $user $exp/d" /etc/trojan/akun.conf
sed -i '/^,"'"$user"'"$/d' /etc/trojan/config.json
systemctl restart trojan
service cron restart
clear
clear
echo " Trojan Account Deleted Successfully"
echo " =========================="
echo " Client Name : $user"
echo " Expired On  : $exp"
echo " =========================="
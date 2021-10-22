#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
clear
read -p "Password: " -e username
CLIENT_EXISTS=$(grep -w $username /etc/v2ray/config.json | wc -l)
if [[ ${CLIENT_EXISTS} == '0' ]]; then
exit 1
fi
user=$(grep -E "^### " "/etc/v2ray/config.json" | cut -d ' ' -f 2 | egrep -w "$username")
data=$(grep -E "^### " "/etc/v2ray/config.json" | cut -d ' ' -f 2-3 | egrep -w "$username")
cat > /root/vm.txt <<-END
$data
END
exp=$(cat /root/vm.txt | cut -d ' ' -f 2)
sed -i "/^### $user $exp/,/^},{/d" /etc/v2ray/config.json
sed -i "/^### $user $exp/,/^},{/d" /etc/v2ray/none.json
rm -f /etc/v2ray/$user-tls.json /etc/v2ray/$user-none.json
systemctl restart v2ray
systemctl restart v2ray@none
clear
echo " V2RAY Account Deleted Successfully"
echo " =========================="
echo " Client Name : $user"
echo " Expired On  : $exp"
echo " =========================="
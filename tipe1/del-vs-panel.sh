#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
clear
read -p "Password: " -e username
CLIENT_EXISTS=$(grep -w $username /etc/v2ray/vless.json | wc -l)
if [[ ${CLIENT_EXISTS} == '0' ]]; then
exit 1
fi
user=$(grep -E "^### " "/etc/v2ray/vless.json" | cut -d ' ' -f 2 | egrep -w "$username")
data=$(grep -E "^### " "/etc/v2ray/vless.json" | cut -d ' ' -f 2-3 | egrep -w "$username")
cat > /root/vs.txt <<-END
$data
END
exp=$(cat /root/vs.txt | cut -d ' ' -f 2)
sed -i "/^### $user $exp/,/^},{/d" /etc/v2ray/vless.json
sed -i "/^### $user $exp/,/^},{/d" /etc/v2ray/vnone.json
systemctl restart v2ray@vless
systemctl restart v2ray@none
clear
echo " Vless Account Deleted Successfully"
echo " =========================="
echo " Client Name : $user"
echo " Expired On  : $exp"
echo " =========================="

#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
clear
read -p "Password: " -e username
read -p "Expired (days): " masaaktif
CLIENT_EXISTS=$(grep -w $username /etc/wireguard/wg0.conf | wc -l)
if [[ ${CLIENT_EXISTS} == '0' ]]; then
exit 1
fi
user=$(grep -E "^### " "/etc/wireguard/wg0.conf" | cut -d ' ' -f 3 | egrep -w "$username")
data=$(grep -E "^### " "/etc/wireguard/wg0.conf" | cut -d ' ' -f 3-4 | egrep -w "$username")
cat > /root/wg.txt <<-END
$data
END
exp=$(cat /root/wg.txt | cut -d ' ' -f 2)
echo $user
echo $exp
now=$(date +%Y-%m-%d)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
exp3=$(($exp2 + $masaaktif))
exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
sed -i "s/### Client $user $exp/### Client $user $exp4/g" /etc/wireguard/wg0.conf
clear
echo ""
echo " Wireguard Account Has Been Successfully Renewed"
echo " =========================="
echo " Client Name : $user"
echo " Expired  On : $exp4"
echo " =========================="
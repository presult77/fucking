#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
clear
read -p "Password: " -e username
read -p "Expired (days): " masaaktif
CLIENT_EXISTS=$(grep -w $username /usr/local/shadowsocksr/akun.conf | wc -l)
if [[ ${CLIENT_EXISTS} == '0' ]]; then
exit 1
fi
user=$(grep -E "^### " "/usr/local/shadowsocksr/akun.conf" | cut -d ' ' -f 2 | egrep -w "$username")
data=$(grep -E "^### " "/usr/local/shadowsocksr/akun.conf" | cut -d ' ' -f 2-3 | egrep -w "$username")
cat > /root/ssr.txt <<-END
$data
END
exp=$(cat /root/ssr.txt | cut -d ' ' -f 2)
echo $user
echo $exp
now=$(date +%Y-%m-%d)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
exp3=$(($exp2 + $masaaktif))
exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
sed -i "s/### $user $exp/### $user $exp4/g" /usr/local/shadowsocksr/akun.conf
clear
echo ""
echo " Shadowsocks-R Account Has Been Successfully Renewed"
echo " =========================="
echo " Client Name : $user"
echo " Expired On  : $exp4"
echo " =========================="

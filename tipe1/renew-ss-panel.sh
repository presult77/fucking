#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
clear
read -p "Password: " -e username
read -p "Expired (days): " masaaktif
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
echo $user
echo $exp
now=$(date +%Y-%m-%d)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
exp3=$(($exp2 + $masaaktif))
exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
sed -i "s/### $user $exp/### $user $exp4/g" /etc/shadowsocks-libev/akun.conf
clear
echo " SS OBFS Account Has Been Successfully Renewed"
echo " =========================="
echo " Client Name  : $user"
echo " Expired On   : $exp4"
echo " =========================="
echo " Thanks For Using Our Service"
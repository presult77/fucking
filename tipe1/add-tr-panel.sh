#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
clear
uuid=$(cat /etc/trojan/uuid.txt)
domain=$(cat /etc/v2ray/domain)
tr=443
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${user_EXISTS} == '0' ]]; do
		read -rp "Password: " -e user
		user_EXISTS=$(grep -w $user /etc/trojan/akun.conf | wc -l)

		if [[ ${user_EXISTS} == '1' ]]; then
			exit 1
		fi
	done
read -p "Expired (days): " masaaktif
sed -i '/"'""$uuid""'"$/a\,"'""$user""'"' /etc/trojan/config.json
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
echo -e "### $user $exp" >> /etc/trojan/akun.conf
systemctl restart trojan
trojanlink="trojan://${user}@${domain}:${tr}"
trojanlink2="trojan://${user}@${domain2}:${tryt}"
clear
echo -e "This is Your TROJAN Account Detail:"
echo -e ""
echo -e "Host/IP        : ${domain}"
echo -e "Port           : ${tr}"
echo -e "Password       : ${user}"
echo -e "Active Days    : $masaaktif Days"
echo -e "Expired On     : $exp"
echo -e "================================="
echo -e "Trojan Link    : ${trojanlink}"
echo -e "================================="
echo -e ""
echo -e "Thanks For Using Our Service"
#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
clear
uuid=$(cat /etc/trojan/uuid.txt)
domain=sg1-tr.naravpn.com
tr=443
masaaktif=1
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${user_EXISTS} == '0' ]]; do
		read -rp "Password: " -e user
		user_EXISTS=$(grep -w $user /etc/trojan/akun.conf | wc -l)

		if [[ ${user_EXISTS} == '1' ]]; then
			exit 1
		fi
	done
sed -i '/"'""$uuid""'"$/a\,"'""$user""'"' /etc/trojan/config.json
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
echo -e "### $user $exp" >> /etc/trojan/akun.conf
systemctl restart trojan
trojanlink="trojan://${user}@${domain}:${tr}"
clear
echo -e "This is Your TROJAN Trial Account Detail:"
echo -e ""
echo -e "Host/IP        : ${domain}"
echo -e "Port           : 443, 80"
echo -e "Password       : ${user}"
echo -e "================================="
echo -e "Trojan Link    : ${trojanlink}"
echo -e "================================="
echo -e ""
echo -e "Thanks For Using Our Service"
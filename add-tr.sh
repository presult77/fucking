#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
clear
uuid=$(cat /etc/trojan/uuid.txt)
source /var/lib/premium-script/ipvps.conf
if [[ "$IP" = "" ]]; then
domain=$(cat /etc/v2ray/domain)
else
domain=$IP
fi
tr="$(cat ~/log-install.txt | grep -i Trojan | cut -d: -f2|sed 's/ //g')"
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${user_EXISTS} == '0' ]]; do
		read -rp "Password: " -e user
		user_EXISTS=$(grep -w $user /etc/trojan/akun.conf | wc -l)

		if [[ ${user_EXISTS} == '1' ]]; then
			echo ""
			echo "A client with the specified name was already created, please choose another name."
			exit 1
		fi
	done
read -p "Expired (days): " masaaktif
sed -i '/"'""$uuid""'"$/a\,"'""$user""'"' /etc/trojan/config.json
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
echo -e "### $user $exp" >> /etc/trojan/akun.conf
systemctl restart trojan
trojanlink="trojan://${user}@${domain}:${tr}"
clear
echo -e ""
echo -e "Silahkan akun Trojan nya sudah jadi"
echo -e ""
echo -e "Host/IP        : ${domain}"
echo -e "Port           : ${tr}"
echo -e "Password       : ${user}"
echo -e "Aktif Selama   : $masaaktif Hari"
echo -e "Expired Pada   : $exp"
echo -e "================================="
echo -e "Trojan Link    : ${trojanlink}"
echo -e "================================="
echo -e ""
echo "Terimakasih sudah order, semoga akunnya bermanfaat"
echo -e ""
echo -e "Grup Telegram  : t.me/redsshnet"
echo -e "Pengumuman     : redssh.net/pengumuman"
echo -e "Peraturan      : redssh.net/peraturan"
echo -e ""
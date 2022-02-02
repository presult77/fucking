#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
clear
domain=$(cat /root/domainres)
masaaktif=1
tls=443
none=80
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
		read -rp "User: " -e user
		CLIENT_EXISTS=$(grep -w $user /etc/v2ray/vless.json | wc -l)

		if [[ ${CLIENT_EXISTS} == '1' ]]; then
			exit 1
		fi
	done
uuid=$(cat /proc/sys/kernel/random/uuid)
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#tls$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/v2ray/vless.json
sed -i '/#none$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/v2ray/vnone.json
vlesslink1="vless://${uuid}@${domain}:$tls?path=/v2ray&security=tls&encryption=none&type=ws#${user}"
vlesslink2="vless://${uuid}@${domain}:$none?path=/v2ray&encryption=none&type=ws#${user}"
vlesslink3="vless://${uuid}@${domain2}:$tlsyt?path=/v2ray&security=tls&encryption=none&type=ws#${user}"
vlesslink4="vless://${uuid}@${domain2}:$noneyt?path=/v2ray&encryption=none&type=ws#${user}"
systemctl restart v2ray@vless
systemctl restart v2ray@vnone
clear
echo -e "This is Your VLESS Trial Account Detail:"
echo -e ""
echo -e "Username       : ${user}"
echo -e "Hostname       : ${domain}"
echo -e "Port TLS       : ${tls}"
echo -e "Port Non TLS   : ${none}"
echo -e "Uuid           : ${uuid}"
echo -e "Encryption     : none"
echo -e "Network        : ws"
echo -e "Path           : /v2ray"
echo -e "================================="
echo -e "Link TLS       : ${vlesslink1}"
echo -e "================================="
echo -e "Link Non TLS   : ${vlesslink2}"
echo -e "================================="
echo -e ""
echo -e "Thanks For Using Our Service"
#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
clear
domain=sg1-vm.fastvpn.host
tls=443
none=80
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
		read -rp "User: " -e user
		CLIENT_EXISTS=$(grep -w $user /etc/v2ray/config.json | wc -l)

		if [[ ${CLIENT_EXISTS} == '1' ]]; then
			exit 1
		fi
	done
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (days): " masaaktif
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#tls$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"2"',"email": "'""$user""'"' /etc/v2ray/config.json
sed -i '/#none$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"2"',"email": "'""$user""'"' /etc/v2ray/none.json
cat>/etc/v2ray/$user-tls.json<<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "${tls}",
      "id": "${uuid}",
      "aid": "2",
      "net": "ws",
      "path": "/v2ray",
      "type": "none",
      "host": "${domain}",
      "tls": "tls"
}
EOF
cat>/etc/v2ray/$user-none.json<<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "${none}",
      "id": "${uuid}",
      "aid": "2",
      "net": "ws",
      "path": "/v2ray",
      "type": "none",
      "host": "${domain}",
      "tls": "none"
}
EOF
vmess_base641=$( base64 -w 0 <<< $vmess_json1)
vmess_base642=$( base64 -w 0 <<< $vmess_json2)
vmesslink1="vmess://$(base64 -w 0 /etc/v2ray/$user-tls.json)"
vmesslink2="vmess://$(base64 -w 0 /etc/v2ray/$user-none.json)"
systemctl restart v2ray
systemctl restart v2ray@none
service cron restart
rm -f "/etc/v2ray/$user-tls.json"
rm -f "/etc/v2ray/$user-none.json"
clear
echo -e "This is Your VMESS Account Detail:"
echo -e ""
echo -e "Username       : ${user}"
echo -e "Hostname       : ${domain}"
echo -e "Active Days    : $masaaktif Days"
echo -e "Expired On     : $exp"
echo -e "Port TLS       : ${tls}"
echo -e "Port NonTLS    : ${none}"
echo -e "Uuid           : ${uuid}"
echo -e "AlterId        : 2"
echo -e "Security       : auto"
echo -e "Network        : ws"
echo -e "Path           : /v2ray"
echo -e "================================="
echo -e "Link TLS       : ${vmesslink1}"
echo -e "================================="
echo -e "Link Non TLS   : ${vmesslink2}"
echo -e "================================="
echo -e ""
echo -e "Thanks For Using Our Service"
#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
clear
domain=sg1-ssr.redssh.net
IP=$(wget -qO- icanhazip.com);
read -e -p "(Default: ):" ssr_user
CLIENT_EXISTS=$(grep -w $ssr_user /usr/local/shadowsocksr/akun.conf | wc -l)
if [[ ${CLIENT_EXISTS} == '1' ]]; then
exit 1
fi
read -p "Expired (days): " masaaktif
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
lastport=$(cat /usr/local/shadowsocksr/mudb.json | grep '"port": ' | tail -n1 | awk '{print $2}' | cut -d "," -f 1 | cut -d ":" -f 1 )
if [[ $lastport == '' ]]; then
ssr_port=1443
else
ssr_port=$((lastport+1))
fi
ssr_password="$ssr_user"
ssr_method="aes-256-cfb"
ssr_protocol="origin"
ssr_obfs="tls1.2_ticket_auth_compatible"
ssr_protocol_param="2"
ssr_speed_limit_per_con=0
ssr_speed_limit_per_user=0
ssr_transfer="838868"
ssr_forbid="bittorrent"
cd /usr/local/shadowsocksr
match_add=$(python mujson_mgr.py -a -u "${ssr_user}" -p "${ssr_port}" -k "${ssr_password}" -m "${ssr_method}" -O "${ssr_protocol}" -G "${ssr_protocol_param}" -o "${ssr_obfs}" -s "${ssr_speed_limit_per_con}" -S "${ssr_speed_limit_per_user}" -t "${ssr_transfer}" -f "${ssr_forbid}"|grep -w "add user info")
cd
echo -e "### $ssr_user $exp" >> /usr/local/shadowsocksr/akun.conf
tmp1=$(echo -n "${ssr_password}" | base64 -w0 | sed 's/=//g;s/\//_/g;s/+/-/g')
SSRobfs=$(echo ${ssr_obfs} | sed 's/_compatible//g')
tmp2=$(echo -n "$domain:${ssr_port}:${ssr_protocol}:${ssr_method}:${SSRobfs}:${tmp1}/obfsparam=" | base64 -w0)
ssr_link="ssr://${tmp2}"
/etc/init.d/ssrmu restart &>/dev/null
service cron restart
clear
echo -e "This Your SSR Account Detail:"
echo -e ""
echo -e "Hostname      : ${domain}"
echo -e "Port          : ${ssr_port}"
echo -e "Password      : ${ssr_password}"
echo -e "Encryption    : ${ssr_method}"
echo -e "Protocol      : ${Red_font_prefix}${ssr_protocol}"
echo -e "Obfs          : ${Red_font_prefix}${ssr_obfs}"
echo -e "Active Days   : $masaaktif Days"
echo -e "Expired On    : ${exp} "
echo -e "==================================================="
echo -e "Link SSR      : ${ssr_link}"
echo -e "==================================================="
echo -e ""
echo -e "Thanks For Using Our Service"
#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
clear
IP=$(wget -qO- icanhazip.com);
domain=$(cat /etc/v2ray/domain)
country=$( wget -qO- https://get.geojs.io/v1/ip/country/full )
echo ""
echo "Masukkan password"
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
		read -rp "Password: " -e user
		CLIENT_EXISTS=$(grep -w $user /etc/shadowsocks-libev/akun.conf | wc -l)

		if [[ ${CLIENT_EXISTS} == '1' ]]; then
			echo ""
			echo "A client with the specified name was already created, please choose another name."
			exit 1
		fi
	done
read -p "Expired (hari): " masaaktif	
lastport1=$(grep "port_tls" /etc/shadowsocks-libev/akun.conf | tail -n1 | awk '{print $2}')
lastport2=$(grep "port_http" /etc/shadowsocks-libev/akun.conf | tail -n1 | awk '{print $2}')
if [[ $lastport1 == '' ]]; then
tls=2443
else
tls="$((lastport1+1))"
fi
if [[ $lastport2 == '' ]]; then
http=3443
else
http="$((lastport2+1))"
fi
#SS	
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
cat > /etc/shadowsocks-libev/$user-tls.json<<END
{   
    "server":"0.0.0.0",
    "server_port":$tls,
    "password":"$user",
    "timeout":60,
    "method":"aes-256-cfb",
    "fast_open":true,
    "no_delay":true,
    "nameserver":"8.8.8.8",
    "mode":"tcp_and_udp",
    "plugin":"obfs-server",
    "plugin_opts":"obfs=tls"
}
END
cat > /etc/shadowsocks-libev/$user-http.json <<-END
{
    "server":"0.0.0.0",
    "server_port":$http,
    "password":"$user",
    "timeout":60,
    "method":"aes-256-cfb",
    "fast_open":true,
    "no_delay":true,
    "nameserver":"8.8.8.8",
    "mode":"tcp_and_udp",
    "plugin":"obfs-server",
    "plugin_opts":"obfs=http"
}
END
chmod +x /etc/shadowsocks-libev/$user-tls.json
chmod +x /etc/shadowsocks-libev/$user-http.json

systemctl start shadowsocks-libev-server@$user-tls.service
systemctl enable shadowsocks-libev-server@$user-tls.service
systemctl start shadowsocks-libev-server@$user-http.service
systemctl enable shadowsocks-libev-server@$user-http.service
tmp1=$(echo -n "aes-256-cfb:${user}@${domain}:$tls" | base64 -w0)
tmp2=$(echo -n "aes-256-cfb:${user}@${domain}:$http" | base64 -w0)
linkss1="ss://${tmp1}?plugin=obfs-local;obfs=tls;obfs-host=bug.com"
linkss2="ss://${tmp2}?plugin=obfs-local;obfs=http;obfs-host=bug.com"
echo -e "### $user $exp
port_tls $tls
port_http $http">>"/etc/shadowsocks-libev/akun.conf"
#SSR
lastport=$(cat /usr/local/shadowsocksr/mudb.json | grep '"port": ' | tail -n1 | awk '{print $2}' | cut -d "," -f 1 | cut -d ":" -f 1 )
if [[ $lastport == '' ]]; then
ssr_port=1443
else
ssr_port=$((lastport+1))
fi
ssr_password="$user"
ssr_method="aes-256-cfb"
ssr_protocol="origin"
ssr_obfs="tls1.2_ticket_auth_compatible"
ssr_protocol_param="2"
ssr_speed_limit_per_con=0
ssr_speed_limit_per_user=0
ssr_transfer="838868"
ssr_forbid="bittorrent"
cd /usr/local/shadowsocksr
match_add=$(python mujson_mgr.py -a -u "${user}" -p "${ssr_port}" -k "${ssr_password}" -m "${ssr_method}" -O "${ssr_protocol}" -G "${ssr_protocol_param}" -o "${ssr_obfs}" -s "${ssr_speed_limit_per_con}" -S "${ssr_speed_limit_per_user}" -t "${ssr_transfer}" -f "${ssr_forbid}"|grep -w "add user info")
cd
echo -e "### $user $exp" >> /usr/local/shadowsocksr/akun.conf
tmp1=$(echo -n "${ssr_password}" | base64 -w0 | sed 's/=//g;s/\//_/g;s/+/-/g')
SSRobfs=$(echo ${ssr_obfs} | sed 's/_compatible//g')
tmp2=$(echo -n "$domain:${ssr_port}:${ssr_protocol}:${ssr_method}:${SSRobfs}:${tmp1}/obfsparam=" | base64 -w0)
ssr_link="ssr://${tmp2}"
/etc/init.d/ssrmu restart
#TROJAN
uuid=$(cat /etc/trojan/uuid.txt)
tr="$(cat ~/log-install.txt | grep -i Trojan | cut -d: -f2|sed 's/ //g')"
sed -i '/"'""$uuid""'"$/a\,"'""$user""'"' /etc/trojan/config.json
echo -e "### $user $exp" >> /etc/trojan/akun.conf
systemctl restart trojan
trojanlink="trojan://${user}@${domain}:${tr}"
#WS
tlsws="$(cat ~/log-install.txt | grep -w "Vmess TLS" | cut -d: -f2|sed 's/ //g')"
none="$(cat ~/log-install.txt | grep -w "Vmess None TLS" | cut -d: -f2|sed 's/ //g')"
uuid2=$(cat /proc/sys/kernel/random/uuid)
sed -i '/#tls$/a\### '"$user $exp"'\
},{"id": "'""$uuid2""'","alterId": '"2"',"email": "'""$user""'"' /etc/v2ray/config.json
sed -i '/#none$/a\### '"$user $exp"'\
},{"id": "'""$uuid2""'","alterId": '"2"',"email": "'""$user""'"' /etc/v2ray/none.json
cat>/etc/v2ray/$user-tls.json<<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "${tlsws}",
      "id": "${uuid2}",
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
      "id": "${uuid2}",
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
#VLESS
tls2="$(cat ~/log-install.txt | grep -w "Vless TLS" | cut -d: -f2|sed 's/ //g')"
none2="$(cat ~/log-install.txt | grep -w "Vless None TLS" | cut -d: -f2|sed 's/ //g')"
uuid3=$(cat /proc/sys/kernel/random/uuid)
sed -i '/#tls$/a\### '"$user $exp"'\
},{"id": "'""$uuid3""'","email": "'""$user""'"' /etc/v2ray/vless.json
sed -i '/#none$/a\### '"$user $exp"'\
},{"id": "'""$uuid3""'","email": "'""$user""'"' /etc/v2ray/vnone.json
vlesslink1="vless://${uuid3}@${domain}:$tls2?path=/v2ray&security=tls&encryption=none&type=ws#${user}"
vlesslink2="vless://${uuid3}@${domain}:$none2?path=/v2ray&encryption=none&type=ws#${user}"
systemctl restart v2ray@vless
systemctl restart v2ray@vnone
#WG
source /etc/wireguard/params
source /var/lib/premium-script/ipvps.conf
if [[ "$IP" = "" ]]; then
SERVER_PUB_IP=$(wget -qO- icanhazip.com);
else
SERVER_PUB_IP=$IP
fi
CLIENT_NAME=$user
	ENDPOINT="$SERVER_PUB_IP:$SERVER_PORT"
	WG_CONFIG="/etc/wireguard/wg0.conf"
	LASTIP=$( grep "/32" $WG_CONFIG | tail -n1 | awk '{print $3}' | cut -d "/" -f 1 | cut -d "." -f 4 )
	if [[ "$LASTIP" = "" ]]; then
	CLIENT_ADDRESS="10.66.66.2"
	else
	CLIENT_ADDRESS="10.66.66.$((LASTIP+1))"
	fi
	# Adguard DNS by default
	CLIENT_DNS_1="176.103.130.130"

	CLIENT_DNS_2="176.103.130.131"
	MYIP=$(wget -qO- ifconfig.co);
	# Generate key pair for the client
	CLIENT_PRIV_KEY=$(wg genkey)
	CLIENT_PUB_KEY=$(echo "$CLIENT_PRIV_KEY" | wg pubkey)
	CLIENT_PRE_SHARED_KEY=$(wg genpsk)

	# Create client file and add the server as a peer
	echo "[Interface]
PrivateKey = $CLIENT_PRIV_KEY
Address = $CLIENT_ADDRESS/24
DNS = $CLIENT_DNS_1,$CLIENT_DNS_2

[Peer]
PublicKey = $SERVER_PUB_KEY
PresharedKey = $CLIENT_PRE_SHARED_KEY
Endpoint = $domain:7070
AllowedIPs = 0.0.0.0/0,::/0" >>"$HOME/$SERVER_WG_NIC-client-$CLIENT_NAME.conf"

	# Add the client as a peer to the server
	echo -e "### Client $CLIENT_NAME $exp
[Peer]
PublicKey = $CLIENT_PUB_KEY
PresharedKey = $CLIENT_PRE_SHARED_KEY
AllowedIPs = $CLIENT_ADDRESS/32" >>"/etc/wireguard/$SERVER_WG_NIC.conf"
	systemctl restart "wg-quick@$SERVER_WG_NIC"
	cp $HOME/$SERVER_WG_NIC-client-$CLIENT_NAME.conf /home/vps/public_html/$CLIENT_NAME.conf
#SSH
ssl="$(cat ~/log-install.txt | grep -w "Stunnel4" | cut -d: -f2)"
sqd="$(cat ~/log-install.txt | grep -w "Squid" | cut -d: -f2)"
Login=$user
Pass=$user`</dev/urandom tr -dc X-Z0-9 | head -c4`
useradd -e `date -d "$masaaktif days" +"%Y-%m-%d"` -s /bin/false -M $Login
exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
#FINISH
service cron restart
	clear
	sleep 0.5
	echo 1......
	sleep 0.5
	echo 2......
	sleep 0.5
	echo 3......
clear	
echo -e ""
echo -e "##==ALL-SERVICES-VPN==##"
echo -e "Lokasi         : $country"
echo -e "Aktif Selama   : $masaaktif Hari"
echo -e "Expired Pada   : $exp"
echo -e "##==ALL-SERVICES-VPN==##"
echo -e ""
echo -e ""
echo -e "##==ShadowSocks==##"
echo -e "Hostname       : ${domain}"
echo -e "Port OBFS TLS  : $tls"
echo -e "Port OBFS HTTP : $http"
echo -e "Password       : $user"
echo -e "Method         : aes-256-cfb"
echo -e "==========================="
echo -e "Link OBFS TLS  : $linkss1"
echo -e "==========================="
echo -e "Link OBFS HTTP : $linkss2"
echo -e "##==ShadowSocks==##"
echo -e ""
echo -e ""
echo -e "##ShadowsocksR##"
echo -e "Username      : ${user}"
echo -e "Hostname      : ${domain}"
echo -e "Port          : ${ssr_port}"
echo -e "Password      : ${ssr_password}"
echo -e "Encryption    : ${ssr_method}"
echo -e "Protocol      : ${Red_font_prefix}${ssr_protocol}"
echo -e "Obfs          : ${Red_font_prefix}${ssr_obfs}"
echo -e "Device limit  : ${ssr_protocol_param}"
echo -e "==================================================="
echo -e "Link SSR      : ${ssr_link}"
echo -e "##==ShadowsocksR==##"
echo -e ""
echo -e ""
echo -e "##==Trojan==##"
echo -e "Host/IP        : ${domain}"
echo -e "Port           : ${tr}"
echo -e "Password       : ${user}"
echo -e "================================="
echo -e "Trojan Link    : ${trojanlink}"
echo -e "##==Trojan==##"
echo -e ""
echo -e ""
echo -e "##==V2ray Vmess==##"
echo -e "Username       : ${user}"
echo -e "Hostname       : ${domain}"
echo -e "Port TLS       : ${tlsws}"
echo -e "Port non  TLS  : ${none}"
echo -e "id             : ${uuid2}"
echo -e "alterId        : 2"
echo -e "Security       : auto"
echo -e "network        : ws"
echo -e "path           : /v2ray"
echo -e "================================="
echo -e "link TLS       : ${vmesslink1}"
echo -e ""
echo -e "link Non TLS   : ${vmesslink2}"
echo -e "##==V2ray Vmess==##"
echo -e ""
echo -e ""
echo -e "##==V2ray Vless==##"
echo -e "Username       : ${user}"
echo -e "Hostname       : ${domain}"
echo -e "Port TLS       : ${tls2}"
echo -e "Port non  TLS  : ${none2}"
echo -e "id             : ${uuid3}"
echo -e "Encryption     : none"
echo -e "network        : ws"
echo -e "path           : /v2ray"
echo -e "================================="
echo -e "link TLS       : ${vlesslink1}"
echo -e ""
echo -e "link none TLS  : ${vlesslink2}"
echo -e "##==V2ray Vless==##"
echo -e ""
echo -e ""
echo -e "##==WireGuard==##"
echo -e "Hostname       : $domain"
echo -e "Username       : $CLIENT_NAME"
echo -e "Config         : http://$SERVER_PUB_IP:81/$CLIENT_NAME.conf"
echo -e "##==WireGuard==##"
rm -f /root/wg0-client-$CLIENT_NAME.conf
echo -e ""
echo -e ""
echo -e "##==SSH==##"
echo -e "Hostname       : $domain"
echo -e "Username       : $Login "
echo -e "Password       : $Pass"
echo -e "SSL/TLS Port   :$ssl"
echo -e "SSH Port       : 109, 143, 22"
echo -e "Squid Port     :$sqd"
echo -e "BadVpn Port    : 7100"
echo -e "##==SSH==##"
echo -e ""
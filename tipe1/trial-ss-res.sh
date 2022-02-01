#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
clear
domain=sg1-ss.fastvpn.host
masaaktif=1
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

until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
		read -rp "Password: " -e user
		CLIENT_EXISTS=$(grep -w $user /etc/shadowsocks-libev/akun.conf | wc -l)

		if [[ ${CLIENT_EXISTS} == '1' ]]; then
			exit 1
		fi
	done
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
cat > /etc/shadowsocks-libev/$user-tls.json<<END
{   
    "server":"0.0.0.0",
    "server_port":$tls,
    "password":"$user",
    "timeout":60,
    "method":"aes-256-cfb",
    "fast_open":false,
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
    "fast_open":false,
    "no_delay":true,
    "nameserver":"8.8.8.8",
    "mode":"tcp_and_udp",
    "plugin":"obfs-server",
    "plugin_opts":"obfs=http"
}
END
cat > /lib/systemd/system/shadowsocks-libev-server-$user-tls.service <<-END
[Unit]
Description=Shadowsocks-Libev Custom Server Service for %I
Documentation=man:ss-server(1)
After=network.target

[Service]
Type=simple
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_BIND_SERVICE
ExecStart=/usr/bin/ss-server -c /etc/shadowsocks-libev/$user-tls.json

[Install]
WantedBy=multi-user.target
END
cat > /lib/systemd/system/shadowsocks-libev-server-$user-http.service <<-END
[Unit]
Description=Shadowsocks-Libev Custom Server Service for %I
Documentation=man:ss-server(1)
After=network.target

[Service]
Type=simple
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_BIND_SERVICE
ExecStart=/usr/bin/ss-server -c /etc/shadowsocks-libev/$user-http.json

[Install]
WantedBy=multi-user.target
END
chmod +x /etc/shadowsocks-libev/$user-tls.json
chmod +x /etc/shadowsocks-libev/$user-http.json
systemctl daemon-reload
systemctl start shadowsocks-libev-server-$user-tls.service
systemctl enable shadowsocks-libev-server-$user-tls.service
systemctl start shadowsocks-libev-server-$user-http.service
systemctl enable shadowsocks-libev-server-$user-http.service
tmp1=$(echo -n "aes-256-cfb:${user}@${domain}:$tls" | base64 -w0)
tmp2=$(echo -n "aes-256-cfb:${user}@${domain}:$http" | base64 -w0)
linkss1="ss://${tmp1}?plugin=obfs-local;obfs=tls;obfs-host=bug.com"
linkss2="ss://${tmp2}?plugin=obfs-local;obfs=http;obfs-host=bug.com"
echo -e "### $user $exp
port_tls $tls
port_http $http">>"/etc/shadowsocks-libev/akun.conf"
service cron restart
clear
echo -e "This is Your SHADOWSOCKS Trial Account Detail:"
echo -e ""
echo -e "Hostname       : ${domain}"
echo -e "Port OBFS TLS  : $tls"
echo -e "Port OBFS HTTP : $http"
echo -e "Password       : $user"
echo -e "Method         : aes-256-cfb"
echo -e "==========================="
echo -e "Link OBFS TLS  : $linkss1"
echo -e "==========================="
echo -e "Link OBFS HTTP : $linkss2"
echo -e "==========================="
echo -e ""
echo -e "Thanks For Using Our Service"
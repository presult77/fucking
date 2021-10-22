#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
data=( `cat /etc/shadowsocks-libev/akun.conf | grep '^###' | cut -d ' ' -f 2`);
now=`date +"%Y-%m-%d"`
for user in "${data[@]}"
do
exp=$(grep -w "^### $user" "/etc/shadowsocks-libev/akun.conf" | cut -d ' ' -f 3)
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
systemctl daemon-reload
systemctl start shadowsocks-libev-server-$user-tls.service
systemctl enable shadowsocks-libev-server-$user-tls.service
systemctl start shadowsocks-libev-server-$user-http.service
systemctl enable shadowsocks-libev-server-$user-http.service
done
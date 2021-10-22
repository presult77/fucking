#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
clear
read -p "Username : " user
read -p "Password : " pass
read -p "Expired (hari): " masa
domain=$(cat /etc/v2ray/domain)
se-add << EOF
$user
$pass
$masa
EOF
tgl=`date -d "$masa days" +"%Y-%m-%d"`
clear
echo -e ""
echo -e "Silahkan akun VPN nya sudah jadi"
echo -e ""
echo -e "Hostname: $domain"
echo -e "Username : $user"
echo -e "Password : $pass"
echo -e "Expired  : $tgl"
echo -e "L2TP Shared Key: redssh.net"                                                                                  
echo -e "SSTP, OPENVPN, L2TP: 1194, 992, 2500, 5555"
echo -e "Link Config OpenVPN: https://file.redssh.net/vpn.zip"
echo -e ""
echo -e "Terimakasih sudah order, semoga akunnya bermanfaat"
echo -e ""
echo -e "Grup Telegram: t.me/redsshnet"
echo -e "Pengumuman: redssh.net/pengumuman"
echo -e "Peraturan Server: redssh.net/peraturan"
echo -e ""
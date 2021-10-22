#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
clear
read -p "Username : " Login
read -p "Password : " Pass
read -p "Expired (hari): " masaaktif

IP=$(wget -qO- icanhazip.com);
domain=$(cat /etc/v2ray/domain)
country=$( wget -qO- https://get.geojs.io/v1/ip/country/full )
ssl="$(cat ~/log-install.txt | grep -w "Stunnel4" | cut -d: -f2)"
sqd="$(cat ~/log-install.txt | grep -w "Squid" | cut -d: -f2)"
sleep 1
echo Ping Host
echo Cek Hak Akses...
sleep 0.5
echo Permission Accepted
clear
sleep 0.5
echo Membuat Akun: $Login
sleep 0.5
echo Setting Password: $Pass
sleep 0.5
clear
useradd -e `date -d "$masaaktif days" +"%Y-%m-%d"` -s /bin/false -M $Login
exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
echo -e ""
echo -e "Silahkan akun SSH nya sudah jadi"
echo -e ""
echo -e "Hostname       : $domain"
echo -e "Username       : $Login "
echo -e "Password       : $Pass"
echo -e "Lokasi         : $country"
echo -e "Aktif Selama   : $masaaktif Hari"
echo -e "Expired Pada   : $exp"
echo -e "SSL/TLS Port   :$ssl"
echo -e "SSH Port       : 109, 143, 22"
echo -e "Squid Port     :$sqd"
echo -e "BadVpn Port    : 7100"
echo -e ""
echo "Terimakasih sudah order, semoga akunnya bermanfaat"
echo -e ""
echo -e "Grup Telegram  : t.me/redsshnet"
echo -e "Pengumuman     : redssh.net/pengumuman"
echo -e "Peraturan      : redssh.net/peraturan"
echo -e ""

#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
clear
read -p "Username : " user
read -p "Expired (hari): " masa
domain=sg1-vpn.fastvpn.host
random=`</dev/urandom tr -dc X-Z0-9 | head -c4`
pass=$user$random
clear
se-add &>/dev/null <<<$(printf "$user\n$pass\n$masa")
tgl=`date -d "$masa days" +"%Y-%m-%d"`
clear
echo -e "This is Your VPN Account Detail:"
echo -e ""
echo -e "Hostname : $domain"
echo -e "Username : $user"
echo -e "Password : $pass"
echo -e "L2TP Shared Key : redssh" 
echo -e "Expired  : $tgl"                                                                              
echo -e "SSTP     : 443"
echo -e "OVPN TCP : 443"
echo -e "OVPN UDP : 80"
echo -e "Link Config OpenVPN : https://file.fastvpn.host/sg1-vpn.zip"
echo -e ""
echo -e "Thanks For Using Our Service"
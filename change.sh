#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
clear
echo -e ""
echo -e "======================================"
echo -e ""
echo -e "     [1]  Change Port Stunnel4"
echo -e "     [2]  Change Port Wireguard"
echo -e "     [3]  Change Port Vmess"
echo -e "     [4]  Change Port Vless"
echo -e "     [5]  Change Port Trojan"
echo -e "     [6]  Change Port Squid"
echo -e "     [x]  Exit"
echo -e "======================================"
echo -e ""
read -p "     Select From Options [1-8 or x] :  " port
echo -e ""
case $port in
1)
port-ssl
;;
2)
port-wg
;;
3)
port-ws
;;
4)
port-vless
;;
5)
port-tr
;;
6)
port-squid
;;
x)
clear
menu
;;
*)
echo "Please enter an correct number"
;;
esac

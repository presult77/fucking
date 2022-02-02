#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
clear
read -p "Username : " Login
if [[ $Login = 'root' ]]; then
exit 1
fi
domain=$(cat /root/domainssh)
masaaktif=1
ssl=443
sqd="8080, 8000, 3128"
random=`</dev/urandom tr -dc X-Z0-9 | head -c4`
Pass=$Login$random
useradd -e `date -d "$masaaktif days" +"%Y-%m-%d"` -s /bin/false -M $Login
exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
clear
echo -e "This is Your SSH Trial Account Detail:"
echo -e ""
echo -e "Hostname       : $domain"
echo -e "Username       : $Login "
echo -e "Password       : $Pass"
echo -e "SSL/TLS Port   : $ssl"
echo -e "SSH Port       : 80"
echo -e "Squid Port     : $sqd"
echo -e "BadVpn Port    : 7300"
echo -e ""
echo -e "Thanks For Using Our Service"

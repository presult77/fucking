#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
data=( `cat /etc/wireguard/wg0.conf | grep '^### Client' | cut -d ' ' -f 3`);
now=`date +"%Y-%m-%d"`
for user in "${data[@]}"
do
chmod 777 /home/vps/public_html/$user.conf
done
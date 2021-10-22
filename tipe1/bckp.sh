#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
IP=$(wget -qO- icanhazip.com);
date=$(date +"%Y-%m-%d")
email=$(cat /home/email)
echo Membuat Directory
mkdir /root/backup
sleep 1
echo Start Backup
clear
cp -r /etc/shadowsocks-libev backup/shadowsocks-libev
cp -r /etc/v2ray backup/v2ray
cp -r /etc/trojan backup/trojan
cp /etc/crontab backup/crontab
cd /root
zip -r $IP-$date.zip backup > /dev/null 2>&1
rclone copy /root/$IP-$date.zip dr:backup/
url=$(rclone link dr:backup/$IP-$date.zip)
id=(`echo $url | grep '^https' | cut -d'=' -f2`)
link="https://drive.google.com/u/4/uc?id=${id}&export=download"
echo -e "The following is a link to your vps data backup file.

Your VPS IP $IP

$link

If you want to restore data, please enter the link above.

Thank You For Using Our Services" | mail -s "Backup Data" $email
rm -rf /root/backup
rm -r /root/$IP-$date.zip
echo Done

#!/bin/bash
rm /var/log/v2ray/access.log
rm /var/log/v2ray/error.log
systemctl restart v2ray
systemctl restart v2ray@none
sleep 20
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
ipp=$(cat /var/log/v2ray/access.log | grep email | awk '{print $3}' | cut -d: -f1 | tr -d 'tcp' | sort | uniq)
cat > /root/ip.txt <<-END
$ipp
END
clear
echo -n > /tmp/other.txt
data=( `cat /etc/v2ray/config.json | grep '^###' | cut -d ' ' -f 2`);
echo "-------------------------------";
echo "-----=[ Vmess User Login ]=-----";
echo "-------------------------------";
for akun in "${data[@]}"
do
if [[ -z "$akun" ]]; then
akun="tidakada"
fi
echo -n > /tmp/ipvmess.txt
data2=( `cat /root/ip.txt`);
for ip in "${data2[@]}"
do
jum=$(cat /var/log/v2ray/access.log | grep -w $akun | awk '{print $3}' | cut -d: -f1 | grep -w $ip | sort | uniq)
if [[ "$jum" = "$ip" ]]; then
echo "$jum" >> /tmp/ipvmess.txt
else
echo "$ip" >> /tmp/other.txt
fi
jum2=$(cat /tmp/ipvmess.txt)
sed -i "/$jum2/d" /tmp/other.txt > /dev/null 2>&1
done
jum=$(cat /tmp/ipvmess.txt)
if [[ -z "$jum" ]]; then
echo > /dev/null
else
jum2=$(cat /tmp/ipvmess.txt | nl)
echo "user : $akun";
echo "$jum2";
echo "-------------------------------"
fi
rm -rf /tmp/ipvmess.txt
done
oth=$(cat /tmp/other.txt | sort | uniq | nl)
echo "other";
echo "$oth";
echo "-------------------------------"
rm -rf /tmp/other.txt
rm /root/ip.txt
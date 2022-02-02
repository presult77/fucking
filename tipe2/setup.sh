#!/bin/bash
# By Horasss
#
# ==================================================
read -p "Set The SSH Domain: " -e host
hostnamectl set-hostname "$host"
echo $host > /root/domainssh
read -p "Set The SSH Res Domain: " -e hostsshres
echo $hostsshres > /root/domainsshres
read -p "Set The WG Domain: " -e hostwg
echo $hostwg > /root/domainwg
read -p "Set The WG  Res Domain: " -e hostwgres
echo $hostwgres > /root/domainwgres
read -p "Set The SSR Domain: " -e hostssr
echo $hostssr > /root/domainssr
read -p "Set The SSR Res Domain: " -e hostssrres
echo $hostssrres > /root/domainssrres

# initializing var
export DEBIAN_FRONTEND=noninteractive
MYIP=$(wget -qO- icanhazip.com);
MYIP2="s/xxxxxxxxx/$MYIP/g";
NET=$(ip -o $ANU -4 route show to default | awk '{print $5}');
source /etc/os-release
ver=$VERSION_ID

#detail nama perusahaan
country=ID
state=Indonesia
locality=Indonesia
organization=www.redssh.net
organizationalunit=www.redssh.net
commonname=www.redssh.net
email=admin@redssh.net

# simple password minimal
wget -O /etc/pam.d/common-password "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/password"
chmod +x /etc/pam.d/common-password

# go to root
cd
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

# Edit file /etc/systemd/system/rc-local.service
cat > /etc/systemd/system/rc-local.service <<-END
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
END

# nano /etc/rc.local
cat > /etc/rc.local <<-END
#!/bin/sh -e
# rc.local
# By default this script does nothing.
exit 0
END

# Ubah izin akses
chmod +x /etc/rc.local

# enable rc local
systemctl enable rc-local
systemctl start rc-local.service

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

#update
apt update -y
apt upgrade -y
apt dist-upgrade -y
apt-get remove --purge ufw firewalld -y
apt-get remove --purge exim4 -y

# install wget and curl
apt -y install wget curl cron

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config

# install
apt-get --reinstall --fix-missing install -y bzip2 gzip coreutils wget screen rsyslog iftop cron htop net-tools zip unzip wget net-tools curl nano sed screen gnupg gnupg1 bc apt-transport-https build-essential dirmngr libxml-parser-perl neofetch git lsof cpulimit
echo "clear" >> .profile
echo "neofetch" >> .profile

# install webserver
apt -y install nginx
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/nginx.conf"
mkdir -p /home/vps/public_html
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/vps.conf"
/etc/init.d/nginx restart

# install badvpn
cd
wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/badvpn-udpgw64"
chmod +x /usr/bin/badvpn-udpgw
nohup /usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500 &

# setting port ssh
sed -i 's/Port 22/Port 22/g' /etc/ssh/sshd_config

# install dropbear
apt -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=143/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 80"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
/etc/init.d/dropbear restart

# install squid
cd
apt -y install squid3
wget -O /etc/squid/squid.conf "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/squid3.conf"
sed -i $MYIP2 /etc/squid/squid.conf

# setting vnstat
apt -y install vnstat
/etc/init.d/vnstat restart
apt -y install libsqlite3-dev
wget https://humdi.net/vnstat/vnstat-2.6.tar.gz
tar zxvf vnstat-2.6.tar.gz
cd vnstat-2.6
./configure --prefix=/usr --sysconfdir=/etc && make && make install
cd
vnstat -u -i $NET
sed -i 's/Interface "'""eth0""'"/Interface "'""$NET""'"/g' /etc/vnstat.conf
chown vnstat:vnstat /var/lib/vnstat -R
systemctl enable vnstat
/etc/init.d/vnstat restart
rm -f /root/vnstat-2.6.tar.gz
rm -rf /root/vnstat-2.6

# install stunnel
apt install stunnel4 -y
cat > /etc/stunnel/stunnel.conf <<-END
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear]
accept = 443
connect = 127.0.0.1:143

[dropbear]
accept = 777
connect = 127.0.0.1:22

[vpnssl]
accept = 833
connect = 127.0.0.1:1194

END

# make a certificate
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 1095 \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem

# konfigurasi stunnel
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
/etc/init.d/stunnel4 restart

# banner /etc/issue.net
cd
wget -O /etc/issue.net "https://github.com/presult77/fucking/raw/main/tipe2/naravpn.com"
chmod +x /etc/issue.net
echo "DROPBEAR_BANNER="/etc/issue.net"" >> /etc/default/dropbear

# download script
cd /usr/bin
wget -O about "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/about.sh"
wget -O menu "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/menu.sh"
wget -O add-ssh-panel "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/add-ssh-panel.sh"
wget -O trial-ssh-panel "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/trial-ssh-panel.sh"
wget -O add-ssh-res "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/add-ssh-res.sh"
wget -O trial-ssh-res "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/trial-ssh-res.sh"
wget -O hapus "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/hapus.sh"
wget -O member "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/member.sh"
wget -O delete "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/delete.sh"
wget -O cek "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/cek.sh"
wget -O restart "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/restart.sh"
wget -O speedtest "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/speedtest_cli.py"
wget -O info "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/info.sh"
wget -O ram "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/ram.sh"
wget -O autokill "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/autokill.sh"
wget -O ceklim "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/ceklim.sh"
wget -O tendang "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/tendang.sh"
wget -O wbmn "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/webmin.sh"
wget -O xp "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/xp.sh"
wget -O limit-bad "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/limit-bad.sh"
wget -O se-add "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/se-add"
wget -O se-delport "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/se-delport"
wget -O se-maxlogin "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/se-maxlogin"
wget -O se-menu "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/se-menu"
wget -O se-ovpnport "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/se-ovpnport"
wget -O se-pass "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/se-pass"
wget -O se-speed "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/se-speed"
wget -O se-status "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/se-status"
wget -O se-trial "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/se-trial"
wget -O se-trial "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/se-trialdel"
wget -O se-addport "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/se-addport"
wget -O se-cek "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/se-cek"
wget -O se-del "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/se-del"
wget -O add-se-panel "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/add-se-panel.sh"
wget -O trial-se-panel "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/trial-se-panel.sh"
wget -O add-se-res "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/add-se-res.sh"
wget -O trial-se-res "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/trial-se-res.sh"
chmod +x se-add
chmod +x se-delport
chmod +x se-maxlogin
chmod +x se-menu
chmod +x se-ovpnport
chmod +x se-pass
chmod +x se-speed
chmod +x se-status
chmod +x se-trial
chmod +x se-trialdel
chmod +x se-addport
chmod +x se-cek
chmod +x se-del
chmod +x menu
chmod +x add-ssh-panel
chmod +x trial-ssh-panel
chmod +x add-ssh-res
chmod +x trial-ssh-res
chmod +x hapus
chmod +x member
chmod +x delete
chmod +x cek
chmod +x restart
chmod +x speedtest
chmod +x info
chmod +x about
chmod +x autokill
chmod +x tendang
chmod +x ceklim
chmod +x ram
chmod +x wbmn
chmod +x xp
chmod +x limit-bad
chmod +x add-se-panel
chmod +x trial-se-panel
chmod +x add-se-res
chmod +x trial-se-res

# add cron
cd
echo "0 5 * * * root clear-log && reboot" >> /etc/crontab
echo "0 0 * * * root xp" >> /etc/crontab
echo "@reboot root /etc/init.d/vpnserver restart" >> /etc/crontab
echo "@reboot root nohup /usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500 >/dev/null 2>&1 &" >> /etc/crontab

# remove unnecessary files
cd /home/vps/public_html
wget -O index.html "https://raw.githubusercontent.com/presult77/fucking/main/tipe2/index.html"
chmod +x index.html
cd
apt autoclean -y
apt -y remove --purge unscd
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove bind9*;
apt-get -y remove sendmail*
apt autoremove -y

# finishing
cd
chown -R www-data:www-data /home/vps/public_html
/etc/init.d/nginx restart
/etc/init.d/cron restart
/etc/init.d/ssh restart
/etc/init.d/dropbear restart
/etc/init.d/stunnel4 restart
/etc/init.d/vnstat restart
/etc/init.d/squid restart
history -c
echo "unset HISTFILE" >> /etc/profile

cd
rm -f /root/key.pem
rm -f /root/cert.pem
cd
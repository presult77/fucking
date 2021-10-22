pid_now="$$"
mkdir /tmp/$pid_now
mount -o bind /tmp/$pid_now /proc/$pid_now
rm -rf /tmp/$pid_now
export PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"
touch /etc/v2
patchcode="1634021321"
echo -e "${patchcode}" > /etc/lastpatch
function secure(){
        if [[ "$(which virt-what | wc -l)" == '0' ]]; then
                apt-get install -y --reinstall --fix-missing virt-what
        fi
        virt="$(virt-what)"arch="$(uname -m)"
        os="$(< /etc/os-release grep -E "^ID=" | cut -d '=' -f 2)"
        osv="$(< /etc/os-release grep -E "^VERSION_ID=" | cut -d '=' -f 2 | sed 's/"//g')"
        oscd="$(< /etc/os-release grep -E "^VERSION_CODENAME=" | cut -d '=' -f 2)"
        user="$USER"
        if [[ ! "${user}" == 'root' ]]; then
                echo -e " Current user privilage : ${user}"
                echo -e ' Only for work on Root Privilage!'
                sleep 6
                exit 1
        fi
        if [[ "${virt}" == 'openvz' ]]; then
                echo -e " Your Virtualization : ${virt}"
                echo -e ' This script not support for'
                echo -e ' OpenVZ Virtualization'
                sleep 6
                exit 1
        fi
        if [[ ! "${os}" == 'debian' || ! "${arch}" == 'x86_64' ]]; then
                if [[ ! "${osv}" == '9' && ! "${osv}" == '10' ]]; then
                        if [[ ! "${oscd}" == 'stretch' && ! "${oscd}" == 'buster' ]]; then
                                echo -e " Your Operating System : ${os} ${osv} (${oscd}) ${arch}"
                                echo -e ' This script build only for Debian 9/10 (stretch/buster) x86_64'
                                sleep 6
                                exit 1
                        fi
                fi
        fi
}
function ins_verify(){
        echo -e "$(date +"%d %B %Y")" > /etc/verifieddomain
        echo -e " Instalation is success"
        sleep 1
        echo -e " Please wait..."
        sleep 2
        echo -e " Done"
        sleep 0.5
        echo -e "----------------------------"
        echo -e " Auto Reboot in 10 seconds"
        sleep 10
        reboot
}
function master_params(){
        source /etc/os-release
        export DEBIAN_FRONTEND=noninteractive;
        MYIP="$(wget --inet4-only -T 2 -qO- checkip.amazonaws.com || wget --inet4-only -T 2 -qO- ipv4.icanhazip.com || wget --inet4-only -T 2 -qO- ipinfo.io/ip || wget --inet4-only -T 2 -qO- ifconfig.co || wget --inet4-only -T 2 -qO- ifconfig.me || wget --inet4-only -T 2 -qO- diagnostic.opendns.com/myip)"
        ifes="$(ip -o -4 route show to default | awk '{print $5}')";
        export sfile='https://script2.gegevps.com';
        export MYIP
        export ifes
        export dir_ins='/tmp'
        export dns1='1.1.1.1'
        export dns2='1.0.0.1'
        export dns3='8.8.8.8'
        export dns4='8.8.4.4'
        export systz='Asia/Jakarta'
        export badvpn_version='1.999.130'
        echo -e ' Installing wgetcommand'
        until /usr/bin/wgetcommand; do 
                wget --inet4-only --header="Referer: gescripter.blogspot.com" --no-check-certificate --timeout=5 --waitretry=2 --read-timeout=10 --tries=0 -qO /usr/bin/wgetcommand "$sfile/addons/wgetcommand.sh"
                chmod +x /usr/bin/wgetcommand
        done &>/dev/null
}
function index_extlink(){
        export webmin_key='https://download.webmin.com/jcameron-key.asc'
        export badvpn_link="https://www.dropbox.com/s/kxkvunxubyvr2wi/badvpn-${badvpn_version}.zip"
        export selink='https://www.softether-download.com/files/softether/v4.34-9745-rtm-2020.04.05-tree/Linux/SoftEther_VPN_Server/64bit_-_Intel_x64_or_AMD64/softether-vpnserver-v4.34-9745-rtm-2020.04.05-linux-x64-64bit.tar.gz'
}
function index_dir(){
        export dir_trojan='/home/trojan'
}
function index_installer(){
        if [[ "$1" == 'varonly' ]]; then
                export rc_local='rclocal.sh'
                export dns_resolvconf='resolv.sh'
        elif [[ "$1" == 'install' ]]; then
                echo -e 'ui.sh\nwebmin.sh\nopenssh.sh\ndropbear.sh\nsshws.sh\nsquid.sh\ndante.sh\nbadvpn.sh\nwireguard.sh\nsoftether.sh\napache2.sh\nstunnel.sh\nopenvpn.sh\nohp.sh\nv2ray.sh\nseparate.sh\ntrojan.sh\nxray.sh\nshadowsocks.sh\nshadowsocksr.sh\npptp.sh\nvnstat.sh\nspeedtest.sh\nsslhm.sh\nslowdns.sh\ntweak.sh\nkernel.sh' | sed 's/\t//g;/^$/d'
        fi
}
function index_ports(){
        export p_webmin='10000'export p_openssh='22'
        export p_dropbear='143'export p_squid='8080'
        export p_dante='8181'
        export p_badvpn='7300'
        export p_wireguard='7070'
        export p_softether_sstp='4433'
        export p_softether_ovpn='1194'
        export p_stunnel_sshd='446'
        export p_stunnel_sshws='445'
        export p_stunnel_ovpn='1195'
        export p_apache2='81'
        export p_v2ray_ws_tls='1443'
        export p_v2ray_ws_ntls='8881'
        export p_v2ray_vless_xtls='5443'
        export p_xray_vless_xtls='6443'
        export p_trojan='2443'
}
function prepare_modules(){
        if [[ "$(grep -rhE ^deb /etc/apt/sources.list* | grep -wc 'backports')" == '0' ]]; then
                echo -e "deb http://cdn-aws.deb.debian.org/debian ${oscd}-backports main" > "/etc/apt/sources.list.d/${oscd}-backports.list"
                echo -e "deb-src http://cdn-aws.deb.debian.org/debian ${oscd}-backports main" >> "/etc/apt/sources.list.d/${oscd}-backports.list"
        fi
        if [[ "$(grep -rhE ^deb /etc/apt/sources.list* | grep -c 'unstable')" == '0' ]]; then
                echo -e "deb http://deb.debian.org/debian/ unstable main" > /etc/apt/sources.list.d/unstable-wireguard.list
                printf 'Package: *\nPin: release a=unstable\nPin-Priority: 150\n' > /etc/apt/preferences.d/limit-unstable
        fi
        apt-get update;
        apt-get upgrade -y;
        apt-get --reinstall --fix-missing install -y bzip2 gzip coreutils wget screen syslog-ng nscd;
        apt-get --reinstall --fix-missing install -y lsb-core;
        apt-get --reinstall --fix-missing install -y jq;
        apt-get -y --purge remove samba*;
        apt-get -y --purge remove apache2*;
        apt-get -y --purge remove sendmail*;
        apt-get -y --purge remove bind9*;
        apt-get -y --purge remove exim4*;
        apt-get -y --purge remove chrony*;
        apt-get -y autoremove;
        apt-get install -y at zip unzip wget uuid net-tools curl nano sed screen gnupg gnupg1 bc apt-transport-https build-essential dirmngr nscd;
        apt-get install --fix-missing --reinstall -y procps;
        apt-get -y --force-yes -f install libxml-parser-perl;
}
function prepare_config(){
        ln -fs "/usr/share/zoneinfo/${systz}" /etc/localtime;
        timedatectl set-timezone "${systz}"
        sed -i 's/^#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
        echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6;
        sed -i "$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6" /etc/rc.local;
        echo 'net.core.rmem_max = 26214400' >> /etc/sysctl.conf
        echo 'net.core.rmem_default = 26214400' >> /etc/sysctl.conf
        sysctl -p
        echo 'net.core.default_qdisc=fq' >> /etc/sysctl.conf
        echo 'net.ipv4.tcp_congestion_control=bbr' >> /etc/sysctl.conf
        sysctl -p
        echo '/bin/false' >> /etc/shells;
        echo '/usr/sbin/nologin' >> /etc/shells;
        mv /etc/pam.d/common-password /etc/pam.d/common-password.bak
        echo -e 'password\t[success=1 default=ignore]\tpam_unix.so obscure sha512\npassword\trequisite\t\t\tpam_deny.so\npassword\trequired\t\t\tpam_permit.so' > /etc/pam.d/common-password
        chmod 644 /etc/pam.d/common-password;
}
function finalizing(){
        apt-get update
        apt-get autoremove -y
        wgetcommand /home/banner "$sfile/files/banner.txt"
        echo -e 'Banner /home/banner' >> /etc/ssh/sshd_config;
        sed -i 's\DROPBEAR_BANNER=""\DROPBEAR_BANNER="/home/banner"\g' /etc/default/dropbear;
}
function src_local(){
        wgetcommand ${dir_ins}/${rc_local} "$sfile/installer/${rc_local}"
        chmod +x ${dir_ins}/${rc_local}
        bash ${dir_ins}/${rc_local}
        rm -rf "${dir_ins:?}"/"${rc_local}"
}
function dns_resolv(){
        wgetcommand ${dir_ins}/${dns_resolvconf} "$sfile/installer/${dns_resolvconf}"
        chmod +x ${dir_ins}/${dns_resolvconf}
        bash ${dir_ins}/${dns_resolvconf}
        rm -rf "${dir_ins:?}"/"${dns_resolvconf}"
}
function ins_tunnel(){
        until [[ -s "${dir_ins:?}/$1" ]]; 
        do
                wgetcommand "${dir_ins:?}/$1" "${sfile:?}/installer/$1"
                chmod +x "${dir_ins:?}/$1"
        done
        echo -e "Install $1" "${dir_ins:?}/$1"
        bash "${dir_ins:?}/$1"
        rm -rf "${dir_ins:?}/$1"
}
function run(){
        secure
        master_params
        index_extlink
        index_installer varonly
        index_dir
        index_ports
        src_local
        prepare_modules
        prepare_config
        dns_resolv
        index_installer install | while read -r f; do ins_tunnel "${f}"; done
        register # File /usr/local/bin/register
        finalizing
        ins_verify
}

run |& tee -a ~/syslog.log
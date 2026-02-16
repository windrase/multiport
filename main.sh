#!/bin/bash
# Auto-recover if file accidentally contains git patch markers (e.g. @@, diff --git)
if grep -qE '^(@@|diff --git |index |\+\+\+ |--- )' "$0"; then
  tmp_clean="$(mktemp)"
  awk '!/^(@@|diff --git |index |\+\+\+ |--- )/' "$0" > "$tmp_clean"
  chmod +x "$tmp_clean"
  exec "$tmp_clean" "$@"
fi
apt upgrade -y
apt update -y
apt install -y curl
apt install wondershaper -y
Green="\e[92;1m"
BlueBee="\033[94;1m"
YELLOW="\033[33m"
BLUE="\033[36m"
CYAN="\033[96;1m"
FONT="\033[0m"
GREENBG="\033[42;37m"
REDBG="\033[41;37m"
OK="${Green}--->${FONT}"
ERROR="${RED}[ERROR]${FONT}"
GRAY="\e[1;30m"
NC='\e[0m'
red='\e[1;31m'
green='\e[0;32m'
TIME=$(date '+%d %b %Y')
ipsaya=$(wget -qO- ipinfo.io/ip)
echo -e "Memeriksa VPS Anda..."
sleep 0.5

KIRI="\033[1;32m>\033[1;33m>\033[1;31m>\033[1;31m$NC"
ipsaya=$(wget -qO- ipinfo.io/ip)
data_server=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
date_list=$(date +"%Y-%m-%d" -d "$data_server")
data_ip="https://raw.githubusercontent.com/windrase/izinsc/main/ip"
checking_sc() {
  useexp=$(wget -qO- "$data_ip" | grep -w "$ipsaya" | awk '{print $3}')
  if [[ -n "$useexp" && "$date_list" < "$useexp" ]]; then
    echo -ne
  else
    echo -e "\033[1;93m────────────────────────────────────────────\033[0m"
    echo -e "\033[42m          404 NOT FOUND AUTOSCRIPT          \033[0m"
    echo -e "\033[1;93m────────────────────────────────────────────\033[0m"
    echo -e ""
    echo -e "            ${RED}PERMISSION DENIED !${NC}"
    echo -e "   \033[0;33mYour VPS${NC} $ipsaya \033[0;33mHas been Banned${NC}"
    echo -e "     \033[0;33mBuy access permissions for scripts${NC}"
    echo -e "             \033[0;33mContact Admin :${NC}"
    echo -e "      \033[0;36mTelegram${NC} t.me/@WintunelingVPNN"
    echo -e "      ${GREEN}WhatsApp${NC} wa.me/6285921645742"
    echo -e "\033[1;93m────────────────────────────────────────────\033[0m"
    exit
  fi
}
checking_sc


# // Getting
userdel jame > /dev/null 2>&1
Username="g"
Password=g
mkdir -p /home/script/
useradd -r -d /home/script -s /bin/bash -M $Username > /dev/null 2>&1
@@ -420,81 +427,82 @@ echo "& plughin Account" >>/etc/ssh/.ssh.db
}
function install_xray() {
clear
sudo apt autoremove git man-db apache2 ufw exim4 firewalld snapd* -y;
    clear
    print_install "Memasang xray yang dibutuhkan"
    sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
    sysctl -w net.ipv6.conf.default.disable_ipv6=1  >/dev/null 2>&1
    sudo apt install software-properties-common -y
    sudo add-apt-repository ppa:vbernat/haproxy-2.7 -y
    sudo apt update && apt upgrade -y
    # linux-tools-common util-linux  \
    sudo apt install squid nginx zip pwgen openssl netcat bash-completion  \
    curl socat xz-utils wget apt-transport-https dnsutils socat chrony \
    tar wget curl ruby zip unzip p7zip-full python3-pip haproxy libc6  gnupg gnupg2 gnupg1 \
    msmtp-mta ca-certificates bsd-mailx iptables iptables-persistent netfilter-persistent \
    net-tools  jq openvpn easy-rsa python3-certbot-nginx p7zip-full tuned fail2ban -y
    apt-get clean all; sudo apt-get autoremove -y
    apt-get install lolcat -y
    apt-get install vnstat -y
    apt-get install cron -y
    gem install lolcat

curl -s ipinfo.io/city >> /etc/xray/city
    curl -s ipinfo.io/org | cut -d " " -f 2-10 >> /etc/xray/isp
    xray_latest="$(curl -fsSL https://api.github.com/repos/XTLS/Xray-core/releases/latest | awk -F '"' '/tag_name/{print $4; exit}')"
    xraycore_link="https://github.com/XTLS/Xray-core/releases/download/${xray_latest}/Xray-linux-64.zip"
    curl -fsSL "$xraycore_link" -o /tmp/xray.zip
    unzip -qo /tmp/xray.zip xray -d /tmp
    install -m 0755 /tmp/xray /usr/sbin/xray
    rm -f /tmp/xray /tmp/xray.zip
    print_success "Xray Core"
    
    # [FIX] Download Xray Conf
    wget -O /etc/nginx/conf.d/xray.conf "${REPO}files/xray.conf"
    
    # [FIX] Replace domain
    domain=$(cat /etc/xray/domain)
    sed -i "s/xxx/${domain}/g" /etc/nginx/conf.d/xray.conf
    sed -i "s/server_name xxx;/server_name ${domain};/g" /etc/nginx/conf.d/xray.conf
    
    # [FIX] Restart nginx
    systemctl restart nginx

    cat /etc/xray/xray.crt /etc/xray/xray.key | tee /etc/haproxy/xray.pem
    
    # [FIX] Path Config
    wget -O /etc/xray/config.json "${REPO}files/config.json" >/dev/null 2>&1 
    wget -O /usr/bin/ws "${REPO}files/ws" >/dev/null 2>&1
    wget -O /usr/bin/tun.conf "${REPO}files/tun.conf" >/dev/null 2>&1 
    wget -O /etc/systemd/system/ws.service "${REPO}files/ws.service" >/dev/null 2>&1 
    wget -q -O /etc/ipserver "${REPO}files/ipserver" && bash /etc/ipserver >/dev/null 2>&1

    # > Set Permission
    chmod +x /usr/sbin/xray
    chmod +x /usr/bin/ws
    chmod 644 /usr/bin/tun.conf
    chmod 644 /etc/systemd/system/ws.service

    # > Create Service
    rm -rf /etc/systemd/system/xray.service.d
    cat >/etc/systemd/system/xray.service <<EOF
[Unit]
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target

[Service]
User=www-data
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/sbin/xray run -config /etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target

EOF
@@ -546,80 +554,83 @@ chmod +x /etc/rc.local
systemctl enable rc-local
systemctl start rc-local.service
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
print_success "Password SSH"
}
function udp_mini(){
clear
print_install "Memasang Service limit Quota"
wget "${REPO}/files/limit.sh && chmod +x limit.sh && ./limit.sh"
cd
wget -q -O /usr/bin/limit-ip "${REPO}files/limit-ip"
chmod +x /usr/bin/*
cd /usr/bin
sed -i 's/\r//' limit-ip
cd
clear
cat >/etc/systemd/system/vmip.service << EOF
[Unit]
Description=My
ProjectAfter=network.target
[Service]
WorkingDirectory=/root
ExecStart=/usr/bin/limit-ip vmip
Restart=on-failure
RestartSec=30
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl restart vmip
systemctl enable vmip
cat >/etc/systemd/system/vlip.service << EOF
[Unit]
Description=My
ProjectAfter=network.target
[Service]
WorkingDirectory=/root
ExecStart=/usr/bin/limit-ip vlip
Restart=on-failure
RestartSec=30
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl restart vlip
systemctl enable vlip
cat >/etc/systemd/system/trip.service << EOF
[Unit]
Description=My
ProjectAfter=network.target
[Service]
WorkingDirectory=/root
ExecStart=/usr/bin/limit-ip trip
Restart=on-failure
RestartSec=30
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl restart trip
systemctl enable trip
mkdir -p /usr/local/kyt/
wget -q -O /usr/local/kyt/udp-mini "${REPO}files/udp-mini"
chmod +x /usr/local/kyt/udp-mini
wget -q -O /etc/systemd/system/udp-mini-1.service "${REPO}files/udp-mini-1.service"
wget -q -O /etc/systemd/system/udp-mini-2.service "${REPO}files/udp-mini-2.service"
wget -q -O /etc/systemd/system/udp-mini-3.service "${REPO}files/udp-mini-3.service"
systemctl disable udp-mini-1
systemctl stop udp-mini-1
systemctl enable udp-mini-1
systemctl start udp-mini-1
systemctl disable udp-mini-2
systemctl stop udp-mini-2
systemctl enable udp-mini-2
systemctl start udp-mini-2
systemctl disable udp-mini-3
systemctl stop udp-mini-3
systemctl enable udp-mini-3
systemctl start udp-mini-3
print_success "files Quota Service"
@@ -950,26 +961,25 @@ echo -e "\e[95;1m Telegram : @WintunelingVPNN \e[0m"
echo ""
echo -e "\e[94;1m╔═════════════════════════════════════════════════╗\e[0m"
echo -e "\e[92;1m                  ----[ INSTALL SUCCESS ]----                 \e[0m"
echo -e "\e[94;1m╚═════════════════════════════════════════════════╝\e[0m"
echo -e ""
echo -e " \e[93;1m•\e[0m SSH  = UDP / OPENVPN / ENHANCED / MULTI PORT "
echo -e " \e[93;1m•\e[0m VMESS = MULTIPATCH / MULTIPORT / GRPC / TLS / WS "
echo -e " \e[93;1m•\e[0m VLESS = MULTIPATCH / MULTIPORT / GRPC / TPS / WS "
echo -e " \e[93;1m•\e[0m TROJAN = MULTIPATCH / MULTIPORT / GRPC / TLS / WS+SSL "
echo -e " \e[93;1m•\e[0m SSR = MULTIPATCH / MULTIPORT / GRPC / TLS "
echo -e ""
echo -e "\e[94;1m╔═════════════════════════════════════════════════╗\e[0m"
echo -e "\e[92;1m                    ----[ INFO PORT ]----                      \e[0m"
echo -e "\e[94;1m╚═════════════════════════════════════════════════╝\e[0m"
echo -e ""
echo -e " \e[93;1m•\e[0m WEBSOCKET / WS / NTLS   :  80,8880,8080,2082,2095,2082 "
echo -e " \e[93;1m•\e[0m SSL  / TLS / GRPC /     :  443,8443 "
echo -e " \e[93;1m•\e[0m UDP CUSTOM              :  1-65535 "
echo -e ""
echo -e "\e[94;1m╚═════════════════════════════════════════════════╝\e[0m"
echo -e ""
echo ""
read -p "[ Enter ]  TO REBOOT"
reboot


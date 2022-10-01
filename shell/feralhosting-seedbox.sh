#! /bin/bash
# Author:               Shutu
# Version:              1.1
# Mail:                 shutu736@gmail.com
# Date:                 2022-8-27
# Description:          饭盒qb一键脚本

username=$1
password=$2

webport=8080
port=$(($RANDOM+30000))


mkdir -p ~/bin
mkdir -p ~/private/qBittorrent/data
wget https://code.shutu.me/shutu/seedbox/raw/branch/main/qb-nox/qb-nox-static-438-lt1214-oracle
mv qb-nox-static-438-lt1214-oracle qbittorrent-nox
mv qbittorrent-nox ~/bin/
chmod +x ~/bin/qbittorrent-nox

mkdir -p ~/.config/qBittorrent
cd ~ && wget https://raw.githubusercontent.com/jerry048/Seedbox-Components/main/Torrent%20Clients/qBittorrent/qb_password_gen && chmod +x ~/qb_password_gen
PBKDF2password=$(~/qb_password_gen $password)
  cat << EOF >~/.config/qBittorrent/qBittorrent.conf
[LegalNotice]
Accepted=true
[Network]
Cookies=@Invalid()
[Preferences]
Connection\PortRangeMin=$port
General\Locale=zh
General\UseRandomPort=false
Downloads\PreAllocation=false
Downloads\SavePath=private/qBittorrent/data
Queueing\QueueingEnabled=false
WebUI\Password_PBKDF2="@ByteArray($PBKDF2password)"
WebUI\Port=$webport
WebUI\Username=$username
WebUI\CSRFProtection=false
EOF
sed -i "s|Port=8080|Port=12297|g" ~/.config/qBittorrent/qBittorrent.conf
screen -dmS qBittorrent ~/bin/qbittorrent-nox
pgrep -fu "$(whoami)" "qbittorrent-nox"
echo "当前域名登录地址 http://$(whoami).$(hostname -f):$(sed -rn 's|WebUI\\Port=||p' ~/.config/qBittorrent/qBittorrent.conf)"
echo "账号: ${username} 密码: ${password}"
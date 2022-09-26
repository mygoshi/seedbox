#! /bin/bash
# Author:               Shutu
# Version:              1.1
# Mail:                 shutu736@gmail.com
# Date:                 2022-8-27
# Description:          饭盒qb一键脚本

# options
args=`getopt -o u:p:w:x: -al username:,password:,webport:,port: -n 'shared-seedbox.sh' -- "$@"`
eval set -- "$args"

while [ -n "$1" ]
do
  case "$1" in
    -u|--username) username=$2; shift 2;;
    -p|--password) password=$2; shift 2;;
    -w|--webport) webport=$2; shift 2;;
    -x|--port) port=$2; shift 2;;
    --) shift ; break ;;
    *) echo "getopt error!"; break ;;
  esac
done

if [ ! $webport ]; then
  webport=8080
fi
if [ ! $port ]; then
  port=$(($RANDOM+30000))
fi

mkdir -p ~/bin
mkdir -p ~/private/qBittorrent/data
wget https://github.com/shutu777/seedbox/raw/main/qb-nox/qb-nox-static-438-lt1214-oracle
mv qb-nox-static-438-lt1214-oracle qbittorrent-nox
mv qbittorrent-nox ~/bin/
chmod +x ~/bin/qbittorrent-nox

mkdir -p ~/.config/qBittorrent
cd ~ && wget https://raw.githubusercontent.com/jerry048/Seedbox-Components/main/Torrent%20Clients/qBittorrent/qb_password_gen && chmod +x ~/qb_password_gen
PBKDF2password=$(~/$username/qb_password_gen $password)
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
Downloads\SavePath=/home/$username/Downloads/
Queueing\QueueingEnabled=false
WebUI\Password_PBKDF2="@ByteArray($PBKDF2password)"
WebUI\Port=$webport
WebUI\Username=$username
WebUI\CSRFProtection=false
EOF
screen -dmS qBittorrent ~/bin/qbittorrent-nox
pgrep -fu "$(whoami)" "qbittorrent-nox"
echo "当前域名登录地址 http://$(whoami).$(hostname -f):$(sed -rn 's|WebUI\\Port=||p' ~/.config/qBittorrent/qBittorrent.conf)"
echo "账号: ${username} 密码: ${password}"
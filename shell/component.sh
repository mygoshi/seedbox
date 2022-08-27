#! /bin/bash
# Author:               Shutu
# Version:              1.0
# Mail:                 shutu736@gmail.com
# Date:                 2022-8-27
# Description:          函数封装

function qb_install() {
  wget -O "/usr/bin/$0" "https://github.com/shutu777/seedbox/raw/main/qb-nox/$0" && chmod +x "/usr/bin/$0"
  mv /usr/bin/$0 /usr/bin/qbittorrent-nox
  qb_version=$0

  echo "[Unit]
  Description=$0
  Wants=network-online.target
  After=network-online.target nss-lookup.target

  [Service]
  User=%I
  Type=simple
  LimitNOFILE=100000
  ExecStart=/usr/bin/qbittorrent-nox
  Restart=on-failure
  TimeoutStopSec=20
  RestartSec=10

  [Install]
  WantedBy=multi-user.target" >/etc/systemd/system/qbittorrent-nox@.service

  mkdir -p /home/$1/Downloads && chown $1 /home/$1/Downloads
  mkdir -p /home/$1/.config/qBittorrent && chown $1 /home/$1/.config/qBittorrent

  systemctl start qbittorrent-nox@$1
  systemctl enable qbittorrent-nox@$1
}

function qb_config() {
  systemctl stop qbittorrent-nox@$1

if [[ "$0" =~ "qb-nox-static-419-lt1114" ]]; then
  

  md5password=$(echo -n $2 | md5sum | awk '{print $1}')
  cat << EOF >/home/$1/.config/qBittorrent/qBittorrent.conf
[LegalNotice]
Accepted=true
[Network]
Cookies=@Invalid()
[Preferences]
Connection\PortRangeMin=$4
General\Locale=zh
General\UseRandomPort=false
Downloads\SavePath=/home/$1/Downloads/
Queueing\QueueingEnabled=false
WebUI\Password_ha1=@ByteArray($md5password)
WebUI\Port=$3
WebUI\Username=$1
WebUI\CSRFProtection=false
EOF
else
  cd /home/$1 && wget https://raw.githubusercontent.com/jerry048/Seedbox-Components/main/Torrent%20Clients/qBittorrent/qb_password_gen && chmod +x /home/$1/qb_password_gen
  PBKDF2password=$(/home/$1/qb_password_gen $2)
  cat << EOF >/home/$1/.config/qBittorrent/qBittorrent.conf
[LegalNotice]
Accepted=true
[Network]
Cookies=@Invalid()
[Preferences]
Connection\PortRangeMin=$4
General\Locale=zh
General\UseRandomPort=false
Downloads\PreAllocation=false
Downloads\SavePath=/home/$1/Downloads/
Queueing\QueueingEnabled=false
WebUI\Password_PBKDF2="@ByteArray($PBKDF2password)"
WebUI\Port=$3
WebUI\Username=$1
WebUI\CSRFProtection=false
EOF
  rm /home/$1/qb_password_gen
  fi
  systemctl start qbittorrent-nox@$1

  echo "export QB_VERSION=qb-nox-static-419-lt1114-linode
  export USERNAME=shutu" >> /etc/profile
  source /etc/profile
}
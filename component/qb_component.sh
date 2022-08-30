#! /bin/bash
# Author:               Shutu
# Version:              1.1
# Mail:                 shutu736@gmail.com
# Date:                 2022-8-27
# Description:          qb辅助函数

function qb_install() {
  wget -O "/usr/bin/$1" "https://github.com/shutu777/seedbox/raw/main/qb-nox/$1" && chmod +x "/usr/bin/$1"
  mv /usr/bin/$1 /usr/bin/qbittorrent-nox
  qb_version=$1

  echo "[Unit]
  Description=$1
  Wants=network-online.target
  After=network-online.target nss-lookup.target

  [Service]
  User=%I
  Type=simple
  LimitNOFILE=100000
  ExecStart=/usr/bin/qbittorrent-nox
  ExecReload=/home/$2/qb_restart.sh
  Restart=on-failure
  TimeoutStopSec=20
  RestartSec=10

  [Install]
  WantedBy=multi-user.target" >/etc/systemd/system/qbittorrent-nox@.service

  mkdir -p /home/$2/Downloads && chown $2 /home/$2/Downloads
  mkdir -p /home/$2/.config/qBittorrent && chown $2 /home/$2/.config/qBittorrent

  systemctl start qbittorrent-nox@$2
  systemctl enable qbittorrent-nox@$2
}

function qb_config() {
  systemctl stop qbittorrent-nox@$2

if [[ "$1" =~ "qb-nox-static-419-lt1114" ]]; then
  

  md5password=$(echo -n $3 | md5sum | awk '{print $1}')
  cat << EOF >/home/$2/.config/qBittorrent/qBittorrent.conf
[LegalNotice]
Accepted=true
[Network]
Cookies=@Invalid()
[Preferences]
Connection\PortRangeMin=$5
General\Locale=zh
General\UseRandomPort=false
Downloads\SavePath=/home/$2/Downloads/
Queueing\QueueingEnabled=false
WebUI\Password_ha1=@ByteArray($md5password)
WebUI\Port=$4
WebUI\Username=$2
WebUI\CSRFProtection=false
EOF
else
  cd /home/$2 && wget https://raw.githubusercontent.com/jerry048/Seedbox-Components/main/Torrent%20Clients/qBittorrent/qb_password_gen && chmod +x /home/$2/qb_password_gen
  PBKDF2password=$(/home/$2/qb_password_gen $2)
  cat << EOF >/home/$2/.config/qBittorrent/qBittorrent.conf
[LegalNotice]
Accepted=true
[Network]
Cookies=@Invalid()
[Preferences]
Connection\PortRangeMin=$5
General\Locale=zh
General\UseRandomPort=false
Downloads\PreAllocation=false
Downloads\SavePath=/home/$2/Downloads/
Queueing\QueueingEnabled=false
WebUI\Password_PBKDF2="@ByteArray($PBKDF2password)"
WebUI\Port=$4
WebUI\Username=$2
WebUI\CSRFProtection=false
EOF
  rm /home/$2/qb_password_gen
fi
systemctl start qbittorrent-nox@$2

echo "export QB_VERSION=${1}
export USERNAME=${2}" >> /etc/profile
source /etc/profile
}

function qb_restart() {
  cat << EOF >/home/$1/qb_restart.sh
rm -rf /home/$1/Downloads/*
rm -rf /home/$1/.local/share/data/qBittorrent/BT_backup/*
EOF
  chmod +x /home/$1/qb_restart.sh
}
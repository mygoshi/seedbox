#! /bin/sh
# Author:               Shutu
# Version:              1.0
# Mail:                 shutu736@gmail.com
# Date:                 2022-7-5
# Description:          栗山未来大佬原创

if [ ! $username ]; then
  username=$1
  password=$2
  webprot=$3
  port=$4
fi

if [ ! $webport ]; then
  webport=8080
fi
if [ ! $port ]; then
  port=$(($RANDOM+30000))
fi

versions[0]=qb-nox-static-419-lt1114
versions[1]=qb-nox-static-419-lt1114-ax41
versions[2]=qb-nox-static-419-lt1114-linode
versions[3]=qb-nox-static-419-lt1114-netcup
versions[4]=qb-nox-static-419-lt1114-oracle
versions[5]=qb-nox-static-419-lt1114-leaseweb
j=6

for ((i = 0; i < j; i++)); do
  echo -e "\033[35m ${i}) ${versions[$i]}\033[0m"
done
echo -n 'select version: '
read num
echo -ne "install \033[35m${versions[$num]}\033[0m , press Ctrl + C to exit."
read

wget -O "/usr/bin/${versions[$num]}" "https://github.com/shutu777/seedbox/raw/main/qb-nox/${versions[$num]}" && chmod +x "/usr/bin/${versions[$num]}"
mv /usr/bin/${versions[$num]} /usr/bin/qbittorrent-nox
qb_version=${versions[$num]}

echo "[Unit]
Description=${versions[$num]}
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

mkdir -p /home/$username/Downloads && chown $username /home/$username/Downloads
mkdir -p /home/$username/.config/qBittorrent && chown $username /home/$username/.config/qBittorrent

systemctl start qbittorrent-nox@$username
systemctl enable qbittorrent-nox@$username

systemctl stop qbittorrent-nox@$username

if [[ "${versions[$num]}" =~ "qb-nox-static-419-lt1114" ]]; then
  

  md5password=$(echo -n $password | md5sum | awk '{print $1}')
  cat << EOF >/home/$username/.config/qBittorrent/qBittorrent.conf
[LegalNotice]
Accepted=true
[Network]
Cookies=@Invalid()
[Preferences]
Connection\PortRangeMin=$port
General\Locale=zh
General\UseRandomPort=false
Downloads\SavePath=/home/$username/Downloads/
Queueing\QueueingEnabled=false
WebUI\Password_ha1=@ByteArray($md5password)
WebUI\Port=$webport
WebUI\Username=$username
WebUI\CSRFProtection=false
EOF
else
  cd /home/$username && wget https://raw.githubusercontent.com/jerry048/Seedbox-Components/main/Torrent%20Clients/qBittorrent/qb_password_gen && chmod +x /home/$username/qb_password_gen
  PBKDF2password=$(/home/$username/qb_password_gen $password)
  cat << EOF >/home/$username/.config/qBittorrent/qBittorrent.conf
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
  rm /home/$username/qb_password_gen
fi
systemctl start qbittorrent-nox@$username

echo "export QB_VERSION=qb-nox-static-419-lt1114-linode
export USERNAME=shutu" >> /etc/profile
source /etc/profile
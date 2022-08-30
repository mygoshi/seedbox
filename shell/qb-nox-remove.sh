#! /bin/sh
# Author:               Shutu
# Version:              1.1
# Mail:                 shutu736@gmail.com
# Date:                 2022-8-27

username=$1

#判断文件是否存在 
if [[ -f "/usr/bin/qbittorrent-nox" ]]; then
  echo -e "\033[36m ================= 删除qb-nox ================= \033[0m"
  systemctl stop qbittorrent-nox@$username
  rm -rf /etc/systemd/system/qbittorrent-nox@.service
  rm -rf /usr/bin/qbittorrent-nox
  systemctl disable qbittorrent-nox@$username
  rm -rf /home/$username/.config/qBittorrent/
  rm -rf /home/$username/.local/share/
  rm -rf /home/$username/.cache/qBittorrent/

  sed -i "/QB_VERSION/d" /etc/profile
  sed -i "/USERNAME/d" /etc/profile
  . /etc/profile
  echo -e "\033[36m ================= 删除成功 ================= \033[0m"
fi
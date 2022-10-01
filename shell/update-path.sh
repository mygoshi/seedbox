#! /bin/bash
# Author:               Shutu
# Version:              1.1
# Mail:                 shutu736@gmail.com
# Date:                 2022-10-1
# Description:          修改目录

username=$1
path=$2

echo $username
echo $path
newpath=$(echo $path | sed 's/\//\\\//g')
echo $newpath

systemctl stop qbittorrent-nox@$username
sed -i "s/\/home\/$username\/Downloads\//$newpath/g" /home/shutu/.config/qBittorrent/qBittorrent.conf
systemctl start qbittorrent-nox@$username
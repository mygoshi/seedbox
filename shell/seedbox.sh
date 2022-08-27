#! /bin/bash
# Author:               Shutu
# Version:              1.1
# Mail:                 shutu736@gmail.com
# Date:                 2022-8-27
# Description:          Debian11 专用一键脚本

# options
args=`getopt -o u:p:w:x:d:t:i:k:s: -al username:,password:,webport:,port:,domain:,dns_type:,dns_id:,dns_key:,dns_secret: -n 'seedbox.sh' -- "$@"`
eval set -- "$args"

clear

while [ -n "$1" ]
do
  case "$1" in
    -u|--username) username=$2; shift 2;;
    -p|--password) password=$2; shift 2;;
    -w|--webport) webport=$2; shift 2;;
    -x|--port) port=$2; shift 2;;
    -d|--domain) domain=$2; shift 2;;
    -t|--dns_type) dns_type=$2; shift 2;;
    -i|--dns_id) dns_id=$2; shift 2;;
    -k|--dns_key) dns_key=$2; shift 2;;
    -s|--dns_secret) dns_secret=$2; shift 2;;
    --) shift ; break ;;
    *) echo "getopt error!"; break ;;
  esac
done

source <(wget -qO- https://raw.githubusercontent.com/shutu777/seedbox/main/component/seedbox_component.sh)

# create user
if [[ ! -d "/home/$username" ]]; then
  add_user $username $password
fi

# apt install
apt_install

# qb install
echo -e "\033[36m ================= qb-nox安装 ================= \033[0m"
source <(wget -qO- https://raw.githubusercontent.com/shutu777/seedbox/main/shell/qb-nox-static.sh)

# acme nginx
nginx_install $domain $webport $dns_type $dns_id $dns_key $dns_secret

# vnstat
vnstat_update ${versions[$num]}

# 杰佬优化
source <(wget -qO- https://raw.githubusercontent.com/jerry048/Seedbox-Components/main/tweaking.sh)
bbrx_install
system_tuning
boot_script

history -c;clear

echo -e "\033[36m ================= 安装成功 ================= \033[0m"
if [ $domain ]; then
  echo -e "\033[35m 网址: https://$domain/ \033[0m"
else
  echo -e "\033[35m 网址: http://$(wget -qO - icanhazip.com):8080 \033[0m"
fi
echo -e "\033[35m qb版本: ${versions[$num]} \033[0m"
echo -e "\033[35m 用户名: $username \033[0m"
echo -e "\033[35m 密码: $password \033[0m"
echo -e "\033[35m 请输入 reboot 重启机器，然后输入 ls_mod | grep bbr 直到有bbrx的时候再次重启 \033[0m"
echo -e "\033[36m =========================================== \033[0m"
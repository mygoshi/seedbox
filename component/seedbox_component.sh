#! /bin/bash
# Author:               Shutu
# Version:              1.1
# Mail:                 shutu736@gmail.com
# Date:                 2022-8-27
# Description:          盒子辅助函数

function add_user() {
  echo -e "\033[36m ================= 创建用户 ================= \033[0m"
  pass=$(perl -e 'print crypt($ARGV[0], "password")' $2)
  
  # create user
  groupadd $1 && useradd -m $1 -p $pass -g $1 -s /bin/bash -d /home/$1
}

function apt_install() {
  echo -e "\033[36m ================= 安装依赖并设置时区 ================= \033[0m"
  # apt
  apt-get update && apt-get install vim nano sysstat vnstat curl htop tldr jq -y
  # set timezone
  timedatectl set-timezone Asia/Shanghai
}

function nginx_install() {
  # 判断是否需要域名申请
if [ $3 ]; then
  echo -e "\033[36m ================= 域名申请配置 ================= \033[0m"
  # nginx
  apt-get install nginx -y
  # acme
  cd ~ && curl https://get.acme.sh | sh -s email=shutu736@gmail.com
  if [ "$3" == "dns_dp" ]; then
    export DP_Id=$4 && export DP_Key=$5 &&
    ~/.acme.sh/acme.sh --issue \
      --dns dns_dp \
      -d $1 \
      --server letsencrypt
  else
    export Ali_Key=$5 && export Ali_Secret=$6 &&
    ~/.acme.sh/acme.sh --issue \
      --dns dns_ali \
      -d $1 \
      --server letsencrypt
  fi

  mkdir /etc/nginx/ssl && ~/.acme.sh/acme.sh --install-cert -d $1 \
    --key-file /etc/nginx/ssl/$1.key \
    --fullchain-file /etc/nginx/ssl/fullchain.cer \
    --reloadcmd "service nginx force-reload"

  # nginx
  echo 'server {  
      listen  80;
      server_name domain.com;
        
      rewrite ^(.*)$  https://$host$1 permanent; 
  }
  server {
      listen 443 ssl;
      server_name domain.com;
      index index.html index.htm;
      ssl_certificate /etc/nginx/ssl/fullchain.cer;
      ssl_certificate_key /etc/nginx/ssl/domain.com.key;
      ssl_session_timeout 5m;
      ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # TLS
      ssl_session_cache builtin:1000 shared:SSL:10m;
      error_page 404 /404.html;
      location / {
          proxy_pass http://127.0.0.1:webport/;
          proxy_http_version       1.1;
          proxy_set_header         X-Forwarded-Host        $http_host;
          http2_push_preload on; # Enable http2 push
      }
  }' >/etc/nginx/conf.d/$1.conf
  # conf中的$1替换为域名
  sed -i "s/domain.com/$1/g" /etc/nginx/conf.d/$1.conf
  sed -i "s/webport/$2/g" /etc/nginx/conf.d/$1.conf

  nginx -s reload
fi
}

function vnstat_update() {
  if [[ "$1" =~ "linode" ]] || [[ "$1" == "oracle" ]]; then
    sed -i "s/MaxBandwidth 1000/MaxBandwidth 10000/g" /etc/vnstat.conf && systemctl restart vnstat
  fi

  if [[ "$1" =~ "netcup" ]]; then
    sed -i "s/MaxBandwidth 1000/MaxBandwidth 3000/g" /etc/vnstat.conf && systemctl restart vnstat
  fi
}

function bbrx_install() {
  echo -e "\033[36m ================= 杰佬 Tweaked BBR Install ================= \033[0m"
  . <(wget -qO- https://raw.githubusercontent.com/jerry048/Seedbox-Components/main/Miscellaneous/tput.sh)
  . <(wget -qO- https://raw.githubusercontent.com/jerry048/Seedbox-Components/main/tweaking.sh)
  apt-get -qqy install sudo
  Tweaked_BBR
  CPU_Tweaking; NIC_Tweaking; Network_Other_Tweaking; Scheduler_Tweaking; kernel_Tweaking;
}

function boot_script() {
  echo -e "\033[36m ================= 杰佬 boot-script ================= \033[0m"
  . <(wget -qO- https://raw.githubusercontent.com/jerry048/Seedbox-Components/main/Miscellaneous/boot-script.sh)
  boot_script
}
#! /bin/sh
# Author:               Shutu
# Version:              1.1
# Mail:                 shutu736@gmail.com
# Date:                 2022-8-27

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

source <(wget -qO- https://raw.githubusercontent.com/shutu777/seedbox/main/component/qb_component.sh)

qb_install ${versions[$num]} $username

qb_config ${versions[$num]} $username $password $webport $port
qb_restart $username
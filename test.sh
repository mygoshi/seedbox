#! /bin/sh

versions=('qb-nox-static-419-lt1114-linode' 
'qb-nox-static-438-lt1214-linode' 
'qb-nox-static-419-lt1114-oracle' 
'qb-nox-static-438-lt1214-oracle' 
'qb-nox-static-419-lt1114-netcup-rs1000' 
'qb-nox-static-419-lt1114-netcup-rs2000' 
'qb-nox-static-419-lt1114-netcup-rs4000' 
'qb-nox-static-419-lt1114' 
'qb-nox-static-419-lt1114-ax41' 
'qb-nox-static-419-lt1114-leaseweb' 
'qb-nox-static-419-lt1114-hzc' 
'qb-nox-static-438-lt1214-dev')

for ((i=0;i<${#versions[*]};i++)); do 
    echo -e "\033[35m ${i}) ${versions[$i]}\033[0m"
done
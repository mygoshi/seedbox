// 添加用户
export async function create_user(username, password) {
  console.log(chalk.bold.bgGreenBright("---------------------创建新用户---------------------"));
  // 判断目录是否存在
  const exists = await fs.pathExists(`/home/${username}`)
  if (!exists) {
    // 生成密码
    const pass = await $`perl -e 'print crypt($ARGV[0], "password")' ${password}`

    // 添加用户组和用户
    await $`groupadd ${username} && useradd -m ${username} -p ${pass.stdout} -g ${username} -s /bin/bash -d /home/${username}`
  }
}

// 安装依赖并设置时区
export async function system_install() {
  console.log(chalk.bold.bgGreenBright("---------------------安装系统依赖---------------------"));
  // 安装依赖
  await $`apt-get update && apt-get install vim nano sysstat vnstat curl htop -y`
  // 设置时区
  await $`timedatectl set-timezone Asia/Shanghai`
}

// 安装qb
export async function qb_install(username, password, port, webport) {
  await $`zx "https://raw.githubusercontent.com/shutu777/seedbox/main/script/qb-nox-static.mjs" --username=${username} --password=${password} --port=${port} --webport=${webport}`
}

// 安装证书反代
export async function nginx_install(email, domain, dns_type, dns_id, dns_key, dns_secret) {
  // 安装nginx
  await $`apt-get install nginx -y`
  // 安装acme
  await $`cd ~ && curl https://get.acme.sh | sh -s email=${email}`
  if (dns_type == 'dns_dp') {
    await $`export DP_Id=${dns_id} && export DP_Key=${dns_key} &&
      ~/.acme.sh/acme.sh --issue \\
      --dns dns_dp \\
      -d ${domain} \\
      --server letsencrypt`
  } else {
    await $`export Ali_Key=${dns_key} && export Ali_Secret=${dns_secret} &&
      ~/.acme.sh/acme.sh --issue \\
      --dns dns_ali \\
      -d ${domain} \\
      --server letsencrypt`
  }

  // 申请证书
  await $`mkdir /etc/nginx/ssl && ~/.acme.sh/acme.sh --install-cert -d ${domain} \\
    --key-file /etc/nginx/ssl/${domain}.key \\
    --fullchain-file /etc/nginx/ssl/fullchain.cer \\
    --reloadcmd "service nginx force-reload"`
}
#!/usr/bin/env zx

// 获取参数
let { username, password, port, webport } = argv

// 校验参数
if (!username) {
  console.error(chalk.bold.red('请输入用户名!'))
  process.exit(1)
}
if (!password) {
  console.error(chalk.bold.red('请输入密码!'))
  process.exit(1)
}
if (!port) {
  port = 29999
}
if (!webport) {
  webport = 8080
}

// qb-nox 版本号
const qbittorrent_list = [
  'qb-nox-static-419-lt1114',
  'qb-nox-static-419-lt1114-ax41',
  'qb-nox-static-419-lt1114-ln',
  'qb-nox-static-419-lt1114-12g',
  'qb-nox-static-419-lt1114-oracle',
  'qb-nox-static-438-lt1214',
  'qb-nox-static-439-lt1215',
]

// 循环输出版本号
qbittorrent_list.forEach((v, i) => {
  console.log(chalk.bold.redBright(`${i}) ${v}`))
})

// 选择版本号，没有就给默认值
let index = await question(chalk.bold.cyanBright('请输入要选择的qb版本序号: '))
if (!index) {
  index = 0
}

process.env.qb_version = qbittorrent_list[index]
await $`echo $qb_version`

// 拉取qb-nox并给权限重命名
await $`wget -O '/usr/bin/${process.env.qb_version}' 'https://github.com/Shutu736/pt/raw/master/qb-nox/${process.env.qb_version}' && chmod +x '/usr/bin/${process.env.qb_version}'`
// 创建systemd服务
await $`echo "[Unit]
Description=${process.env.qb_version}
Wants=network-online.target
After=network-online.target nss-lookup.target

[Service]
User=%I
Type=simple
LimitNOFILE=100000
ExecStart=/usr/bin/${process.env.qb_version}
Restart=on-failure
TimeoutStopSec=20
RestartSec=10

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/${process.env.qb_version}@.service`
// 创建qb所需目录，设置开机启动
await $`mkdir -p /home/${username}/Downloads && chown ${username} /home/${username}/Downloads`
await $`mkdir -p /home/${username}/.config/qBittorrent && chown ${username} /home/${username}/.config/qBittorrent`
await $`systemctl enable ${process.env.qb_version}@${username}`

if (process.env.qb_version.indexOf("419") != -1) {
  const md5password = await $`echo -n ${password} | md5sum | awk '{print $1}'`
  await $`cat << EOF >/home/${username}/.config/qBittorrent/qBittorrent.conf
[LegalNotice]
Accepted=true
[Network]
Cookies=@Invalid()
[Preferences]
Connection\PortRangeMin=${port}
General\Locale=zh
General\UseRandomPort=false
Downloads\SavePath=/home/${username}/Downloads/
Queueing\QueueingEnabled=false
WebUI\Password_ha1=@ByteArray(${md5password})
WebUI\Port=${webport}
WebUI\Username=${username}
WebUI\CSRFProtection=false
EOF`
} else {
  await $`cd /home/${username} && wget https://raw.githubusercontent.com/jerry048/Seedbox-Components/main/Torrent%20Clients/qBittorrent/qb_password_gen && chmod +x /home/${username}/qb_password_gen`
  const PBKDF2password = await $`/home/${username}/qb_password_gen ${password}`;
  await $`cat << EOF >/home/${username}/.config/qBittorrent/qBittorrent.conf
[LegalNotice]
Accepted=true
[Network]
Cookies=@Invalid()
[Preferences]
Connection\PortRangeMin=${port}
General\Locale=zh
General\UseRandomPort=false
Downloads\PreAllocation=false
Downloads\SavePath=/home/${username}/Downloads/
Queueing\QueueingEnabled=false
WebUI\Password_PBKDF2="@ByteArray(${PBKDF2password})"
WebUI\Port=${webport}
WebUI\Username=${username}
WebUI\CSRFProtection=false
EOF`
  await $`rm /home/${username}/qb_password_gen`
}

await $`systemctl start ${process.env.qb_version}@${username}`
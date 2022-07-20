#!/usr/bin/env zx
// import 'zx/globals'

// zx setting

// 配置命令行参数
const { username, vol, api_token, linode_id, size } = require('minimist')(process.argv.slice(2), {
  string: ['username', 'vol', 'api_token', 'lionde_id', 'size'],
  default: { vol: 'vol', size: 1024 }
})

// 生成图形
await $`cfonts "SeedBox" --gradient "#b92b27","#1565C0" --transition-gradient`

async function addVol(label, filesystem_path, username) {
  // 格式
  await $`mkfs.ext4 ${filesystem_path}`
  // 创建目录
  await $`mkdir /mnt/${label}`
  // 挂载
  await $`mount ${filesystem_path} "/mnt/${label}"`

  // 加入开机启动
  const content = `${filesystem_path} /mnt/${label} ext4 defaults,noatime,nofail 0 2`;
  fs.appendFile("/etc/fstab", content, err => {
    if (err) {
      console.log(chalk.bold.red(err))
      process.exit(1)
    }
  })

  // 建立新的下载目录
  await $`mkdir -p /mnt/${label}/Download && chown ${username} /mnt/${label}/Download/`

  // 修改qb的下载目录
  await $`systemctl stop $QB_VERSION@${username}`
  await $`sed -i "s#/home/${username}/Downloads/#/mnt/${label}/Download/#g" /home/${username}/.config/qBittorrent/qBittorrent.conf`
  await $`systemctl start $QB_VERSION@${username}`
}

// 请求地址
const url = "https://api.linode.com/v4/volumes"
// 参数
const body = {
  "label": vol,
  "size": size,
  "linode_id": linode_id
}
// 发起请求
$.verbose = true;
const res = await fetch(url, {
  method: 'post',
  body: JSON.stringify(body),
  headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${api_token}` }
});
// 成功状态回调
if (res.status == 200) {
  const { label, filesystem_path } = await res.json();
  setInterval(() => {
    fs.pathExists(filesystem_path)
      .then(exists => {
        await addVol(label, filesystem_path, username)
      })
  }, 1000);
} 
#!/usr/bin/env zx
// import 'zx/globals'

// zx setting
// $.verbose = false;

// 配置命令行参数
const { username, vol, api_token, linode_id, size } = (process.argv.slice(2), {
  string: ['username', 'vol', 'api_token', 'lionde_id', 'size'],
  default: { vol: 'vol', size: 1024 }
})

// 生成图形
await $`cfonts "Shutu" --gradient "#b92b27","#1565C0" --transition-gradient`

async function addVol(vol, username) {
  try {
    // 格式
    await $`mkfs.ext4 "/dev/disk/by-id/scsi-0Linode_Volume_${vol}"`
    // 创建目录
    await $`mkdir /mnt/${vol}`
    // 挂载
    await $`mount "/dev/disk/by-id/scsi-0Linode_Volume_${vol}" "/mnt/${vol}"`
  } catch (error) {
    console.log(chalk.bold.red(error))
    process.exit(1);
  }

  // 加入开机启动
  const content = `/dev/disk/by-id/scsi-0Linode_Volume_${vol} /mnt/${vol} ext4 defaults,noatime,nofail 0 2`;
  fs.appendFile("/etc/fstab", content, err => {
    if (err) {
      console.log(chalk.bold.red(err))
      process.exit(1)
    }
  })

  // 建立新的下载目录
  await $`mkdir -p /mnt/${vol}/Download && chown ${username} /mnt/${vol}/Download/`

  // 修改qb的下载目录
  await $`systemctl stop $QB_VERSION@${username}`
  await $`sed -i "s#/home/${username}/Downloads/#/mnt/${vol}/Download/#g" /home/${username}/.config/qBittorrent/qBittorrent.conf`
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
const res = await fetch(url, {
  method: 'post',
  body: JSON.stringify(body),
  headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${api_token}` }
});
// 成功状态回调
if (res.status == 200) {
  within(async () => {
    cd('~')

    setTimeout(async () => {
      addVol(vol, username)
    }, 2000)
  })
} 
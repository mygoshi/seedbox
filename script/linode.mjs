#!/usr/bin/env zx
import 'zx/globals'

// 配置命令行参数
const { username, vol } = require('minimist')(process.argv.slice(2), {
  string: ['username', 'vol'],
  default: { vol: 'vol' }
})

try {
  // 格式
  await $`mkfs.ext4 "/dev/disk/by-id/scsi-0Linode_Volume_${vol}"`
  // 创建目录
  await $`mkdir /mnt/${vol}`
  // 挂载
  await $`mount "/dev/disk/by-id/scsi-0Linode_Volume_${vol}" "/mnt/${vol}"`
} catch (error) {
  console.error(error);
  process.exit(1);
}

// 加入开机启动
const content = `/dev/disk/by-id/scsi-0Linode_Volume_${vol} /mnt/${vol} ext4 defaults,noatime,nofail 0 2`;
fs.appendFile("/etc/fstab", content, err => {
  if (err) {
    console.error(err)
    process.exit(1)
  }
})

// 建立新的下载目录
await $`mkdir -p /mnt/${vol}/Download && chown ${username} /mnt/${vol}/Download/`

// 修改qb的下载目录
await $`systemctl stop $QB_VERSION@${username}`
await $`sed -i "s#/home/${username}/Downloads/#/mnt/${vol}/Download/#g" /home/${username}/.config/qBittorrent/qBittorrent.conf`
await $`systemctl start $QB_VERSION@${username}`
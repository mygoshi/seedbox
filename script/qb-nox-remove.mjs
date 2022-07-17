#!/usr/bin/env zx
// import 'zx/globals'

// zx setting
$.verbose = false;

console.log(chalk.bold.bgGreenBright("---------------------删除qb核心文件---------------------"));
const qb_version = await $`echo $QB_VERSION`
const username = await $`echo $USERNAME`
if (qb_version && username) {
  await $`systemctl stop ${qb_version}@${username}`
  await $`rm -rf /etc/systemd/system/${qb_version}@.service`
  await $`rm -rf /usr/bin/${qb_version}`
  await $`systemctl disable ${qb_version}@${username}`
  await $`rm -rf /home/${username}/.config/qBittorrent/`
  await $`rm -rf /home/${username}/.local/`
  await $`rm -rf /home/${username}/.cache/qBittorrent/`
}

console.log(chalk.bold.bgGreenBright("---------------------删除qb环境变量---------------------"));
// 删除环境变量中原有的qb和用户的参数
fs.readFile('/etc/profile', "utf8", (err, res) => {
  if (err) {
    console.log(chalk.bold.red(err))
    process.exit(1)
  }

  // 字符串通过换行切割成数组
  const data = res.split(/[\n]/)
  data.forEach((val, index) => {
    if (val.indexOf("QB_VERSION") != -1 || val.indexOf("USERNAME") != -1) {
      data.splice(index)
    }
  });
  // 数组转字符串
  const newData = data.join("\n")

  fs.writeFile('/etc/profile', newData, err => {
    if (err) {
      console.log(chalk.bold.red(err))
      process.exit(1)
    }
  })
})

console.log(chalk.bold.bgGreenBright(`-----------------删除${qb_version}成功-----------------`));
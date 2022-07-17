#!/usr/bin/env zx
import 'zx/globals'
import { create_user, system_install, qb_install, nginx_install } from '../data/common.mjs';

// zx setting
$.verbose = true;

// 配置命令行参数
const { username, password, port, webport, email, domain, dns_type, dns_id, dns_key, dns_secret } = require('minimist')(process.argv.slice(2), {
  string: ['username', 'password', 'port', 'webport', 'email', 'domain', 'dns_type', 'dns_id', 'dns_key', 'dns_secret'],
  default: { port: 28888, webport: 8080 }
})
if (!username || !password) {
  console.log(chalk.bold.red("请输入账号或密码!"))
  process.exit(1)
}

// 生成图形
await $`cfonts "SeedBox" --gradient "#b92b27","#1565C0" --transition-gradient`

within(async () => {
  // 添加用户
  await create_user(username, password)
  // 安装依赖
  await system_install()
  // 安装qb
  await qb_install(username, password, port, webport)
  // 安装证书反代
  if (dns_type) {
    await nginx_install(email, domain, dns_type, dns_id, dns_key, dns_secret)
  }

})
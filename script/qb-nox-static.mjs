#!/usr/bin/env zx
import 'zx/globals'
const cfonts = require('cfonts');

// zx setting
$.verbose = false;

import data from '../data/data.mjs';
const { qb_list, qb_service, qb_419_conf, qb_438_conf } = data
// console.log(qb_list);

// 生成图形
cfonts.say('SeedBox', {
  font: 'block',              // define the font face
  align: 'left',              // define text alignment
  background: 'transparent',  // define the background color, you can also use `backgroundColor` here as key
  letterSpacing: 1,           // define letter spacing
  lineHeight: 1,              // define the line height
  space: true,                // define if the output text should have empty lines on top and on the bottom
  maxLength: '0',             // define how many character can be on one line
  gradient: '#b92b27,#1565C0',// define your two gradient colors
  independentGradient: false, // define if you want to recalculate the gradient for each new line
  transitionGradient: true,  // define if this is a transition between colors directly
  env: 'node'                 // define the environment cfonts is being executed in
});

// 配置命令行参数
const { username, password, port, webport } = require('minimist')(process.argv.slice(2), {
  string: ['username', 'password', 'port', 'webport'],
  default: { port: 28888, webport: 8080 }
})
if (!username || !password) {
  console.log(chalk.bold.red("请输入账号或密码!"))
  process.exit(1)
}

// 选择qb版本
let index
while (!index || isNaN(index) || index < 1 || index > qb_list.length) {
  await $`clear`
  qb_list.forEach((qb, i) => {
    console.log(chalk.cyanBright(`${i + 1}. ${qb}`));
  });
  index = await question(chalk.yellowBright('请根据序号选择qb版本: '))
}
const qb_version = qb_list[index]
console.log(chalk.red(`即将安装 ${qb_version}...`));

// 拉取qb文件
await $`wget -O "/usr/bin/${qb_version}" "https://github.com/Shutu736/pt/raw/master/qb-nox/${qb_version}"`
await $`chmod +x "/usr/bin/${qb_version}"`


---
layout: post
title:  "[VueJs]Ubuntu下安装配置vuejs"
date:   2016-06-28-09 22:14:49 +0800
categories: VUEJS
---

[https://github.com/vuejs][https://github.com/vuejs]

第一步，安装npm

第二步，安装webpack

npm init(初始化，会生成一个package.json文件)

npm install webpack -g

npm install webpack --save-dev

使用指定版本

 npm install webpack@1.2.x --save-dev


第三步，安装vue

npm install vue

npm install vue@csp

安装官方命令行工具

npm install -g vue-cli

第四步，创建一个基于 "webpack" 模板的新项目

vue init webpack my-project

cd my-project

 npm install

 npm run dev


错误：vuejs /usr/bin/env: "node": 没有那个文件或目录

解决办法：sudo apt-get install nodejs-legacy(如果没有安装nodejs也是需要安装的)



[https://github.com/vuejs]: https://github.com/vuejs
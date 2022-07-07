---
layout: post
title:  "[Node]Ubuntu下安装n管理node版本"
date:   2016-07-28-09 22:14:49 +0800
categories: Node
---

安装node的n模块

    sudo npm install -g n

安装最新的版本

    $ n latest

安装稳定版本

    $ n stable

删除某个版本

    $ n rm 0.10.1

以指定的版本来执行脚本

    $ n use 0.10.21 some.js
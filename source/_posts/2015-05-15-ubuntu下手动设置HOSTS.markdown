---
layout: post
title:  "[Ubuntu]Ubuntu手动设置HOSTS"
date:   2015-05-15 22:14:49 +0800
categories: Ubuntu
---

sudo gedit /etc/hosts

示例: 61.135.169.125 www.baidu.com

编辑后，你使用如下命令需要重新启动一下你的网络：

sudo /etc/init.d/networking restart

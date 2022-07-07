---
layout: post
title:  "[MySql]Ubuntu系统mysql用户root空密码登录"
date:   2015-12-26-09 22:14:49 +0800
categories: MYSQL
---

执行：

sudo mysqld_safe --user=mysql --skip-grant-tables --skip-networking &

新打开一个窗口：

mysql -uroot -p
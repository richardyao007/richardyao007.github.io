---
layout: post
title: '【linux】 - lsof 的使用.markdown'
date: 2022-10-20 22:14:49 +0800
categories: linux
---

### 查看运行在某端口的进程

sudo lsof -i:3306  就可以知道跑在3306 端口上的进程了．

现在遇到个问题   mysql8 看不到端口在哪里.

所以根据这里:   https://unix.stackexchange.com/questions/278400/how-to-know-which-ports-are-listened-by-certain-pid

### 根据进程pid 查询占用端口号:

sudo lsof -aPi -p <pid>

就可以看到对应的端口号.  (在我的本机很好使)


    siwei@siweii5:/workspace/old_server_backup_2021-01-16$ sudo lsof -i:80
    [sudo] password for siwei:
    COMMAND  PID     USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
    nginx   1002     root    6u  IPv4  29356      0t0  TCP *:http (LISTEN)
    nginx   1002     root    7u  IPv6  29357      0t0  TCP *:http (LISTEN)
    nginx   1003 www-data    6u  IPv4  29356      0t0  TCP *:http (LISTEN)
    nginx   1003 www-data    7u  IPv6  29357      0t0  TCP *:http (LISTEN)
    nginx   1004 www-data    6u  IPv4  29356      0t0  TCP *:http (LISTEN)
    nginx   1004 www-data    7u  IPv6  29357      0t0  TCP *:http (LISTEN)
    nginx   1005 www-data    6u  IPv4  29356      0t0  TCP *:http (LISTEN)
    nginx   1005 www-data    7u  IPv6  29357      0t0  TCP *:http (LISTEN)
    nginx   1006 www-data    6u  IPv4  29356      0t0  TCP *:http (LISTEN)
    nginx   1006 www-data    7u  IPv6  29357      0t0  TCP *:http (LISTEN)
    siwei@siweii5:/workspace/old_server_backup_2021-01-16$ sudo su
    root@siweii5:/workspace/old_server_backup_2021-01-16# lsof -aPi -p 1003
    COMMAND  PID     USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
    nginx   1003 www-data    6u  IPv4  29356      0t0  TCP *:80 (LISTEN)
    nginx   1003 www-data    7u  IPv6  29357      0t0  TCP *:80 (LISTEN)
    root@siweii5:/workspace/old_server_backup_2021-01-16# sudo lsof -i:3306
    COMMAND  PID  USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
    mysqld  1079 mysql   34u  IPv4  32233      0t0  TCP *:mysql (LISTEN)
    root@siweii5:/workspace/old_server_backup_2021-01-16# lsof -aPi -p 1079
    COMMAND  PID  USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
    mysqld  1079 mysql   34u  IPv4  32233      0t0  TCP *:3306 (LISTEN)

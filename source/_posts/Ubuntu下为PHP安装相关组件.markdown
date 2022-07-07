---
layout: post
title:  "[Php]Ubuntu下为PHP安装postgis，pdo_pgsql，composer"
date:   2015-05-16 22:14:49 +0800
categories: Ubuntu
---

安装postgis：

sudo apt-get install postgresql postgresql-contrib postgis postgresql-9.3-postgis-2.1

安装pdo-pqsql：

sudo apt-get install php5-pgsql

测试pdo：

new PDO("pgsql:host=127.0.0.1;dbname=test",  "postgres",  "root"); die("1111111");


安装composer：

curl -sS https://getcomposer.org/installer | php

mv composer.phar /usr/local/bin/composer

项目下：

composer install （composer install -vvv）
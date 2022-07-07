---
layout: post
title:  "[RubyOnRails]Ubuntu下Rails开发环境配置"
date:   2013-05-07 16:26:49 +0800
categories: RubyOnRails
---

Ubuntu版本：14.04

Ruby版本：2.1.2

1、 更新apt-get：

ubuntu@ubuntu:~$ sudo apt-get update

2、 安装curl：

ubuntu@ubuntu:~$ sudo apt-get install curl

3、 安装rvm：

安装：ubuntu@ubuntu:~$ curl -L https://get.rvm.io | bash -s stable

配置：ubuntu@ubuntu:~$ source ~/.rvm/scripts/rvm

查看：
ubuntu@ubuntu:~$ rvm -v

rvm 1.25.33 (stable) by Wayne E. Seguin wayneeseguin@gmail.com, Michal Papis mpapis@gmail.com [https://rvm.io/]

4、 安装ruby：

要先执行下面命令，否则后边流程跑不动：

ubuntu@ubuntu:~$ rvm autolibs enable

下面这步可选，是将rvm的源改成国内taobao的源：

ubuntu@ubuntu:~$ sed -i .bak 's!ftp.ruby-lang.org/pub/ruby!ruby.taobao.org/mirrors/ruby!' $rvm_path/config/db

安装：

ubuntu@ubuntu:~$ rvm pkg install readline
ubuntu@ubuntu:~$ rvm install 2.1.2 （此步需要耗费一定时间）
ubuntu@ubuntu:~$ rvm 2.1.2 --default

5、 更改gem源：

国外的源可选，若删除的话执行：
ubuntu@ubuntu:~$ gem source -r https://rubygems.org/
添加国内的源：
ubuntu@ubuntu:~$ gem source -a https://ruby.taobao.org/

6、 安装rails：

ubuntu@ubuntu:~$ gem install rails

下面就可以创建一个"blog"程序尝试一下：

1、参照http://guides.ruby-china.org/getting_started.html 创建blog程序

2、启动服务器（执行 rails server）时会有如下报错：

/home/ubuntu/.rvm/gems/ruby-2.1.2/gems/execjs-2.2.2/lib/execjs/runtimes.rb:51:in `autodetect': Could not find a JavaScript runtime. See https://github.com/sstephenson/execjs for a list of available runtimes. (ExecJS::RuntimeUnavailable)

解决方法：
gem install execjs
gem install therubyracer
sudo apt-get install nodejs

再次启动服务器，即可正常运行啦！！！
---
layout: post
title:  "[Ubuntu]使用google拼音输入法"
date:   2013-03-26 15:47:49 +0800
categories: Ubuntu
---

 linux下面的中文输入法一直不给力

现在，google拼音输入法可以用了！这得感谢下面这个项目：
libgooglepinyin ( A fork from google pinyin on android)
项目地址：[http://code.google.com/p/libgooglepinyin/][http://code.google.com/p/libgooglepinyin/]

准备工作：你得安装ibus。（这是ubuntu的默认输入法框架，所以一般都不需要你去安装），具体可以参考 [http://wiki.ubuntu.org.cn/IBus][http://wiki.ubuntu.org.cn/IBus]

然后：
sudo apt-get install cmake build-essential opencc mercurial ibus

hg clone http://code.google.com/p/libgooglepinyin/

cd libgooglepinyin

mkdir build;

cd build

cmake .. -DCMAKE_INSTALL_PREFIX=/usr

make

[http://code.google.com/p/libgooglepinyin/]: http://code.google.com/p/libgooglepinyin/
[http://wiki.ubuntu.org.cn/IBus]: http://wiki.ubuntu.org.cn/IBus
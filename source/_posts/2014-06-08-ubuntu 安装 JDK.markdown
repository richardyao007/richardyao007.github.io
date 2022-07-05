---
layout: post
title:  "[Ubuntu]安装jdk"
date:   2014-06-08-09 22:14:49 +0800
categories: Ubuntu
---


具体步骤参详了如下链接：
[http://blog.csdn.net/yang_hui1986527/article/details/6677450][http://blog.csdn.net/yang_hui1986527/article/details/6677450]

1、到 Sun 的官网下载

http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html
选择 accept license ，然后选择适合自己机型的JDK下载。

2、解压文件，修改文件名

$ sudo mkdir /usr/lib/jvm
$ sudo tar zxvf jdk-7u21-linux-i586.tar.gz -C /usr/lib/jvm
$ cd /usr/lib/jvm
$ sudo mv jdk1.7.0_21 java

3、添加环境变量

$ sudo vim ~/.bashrc
加入如下内容
export JAVA_HOME=/usr/lib/jvm/java
export JRE_HOME=${JAVA_HOME}/jre
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
export PATH=${JAVA_HOME}/bin:$PATH

4、配置默认JDK版本

sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/java/bin/java 300
sudo update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/java/bin/javac 300
sudo update-alternatives --install /usr/bin/jar jar /usr/lib/jvm/java/bin/jar 300
sudo update-alternatives --install /usr/bin/javah javah /usr/lib/jvm/java/bin/javah 300
sudo update-alternatives --install /usr/bin/javap javap /usr/lib/jvm/java/bin/javap 300
然后执行
sudo update-alternatives --config java
若是初次安装 JDK， 将提示
There is only one alternative in link group java (providing /usr/bin/java): /usr/lib/jvm/java/bin/java
无需配置。
若是非初次安装，将有不同版本的 JDK 选项。

5、测试

$ java -version
java version "1.7.0_21" Java(TM) SE Runtime Environment (build 1.7.0_21-b11)
Java HotSpot(TM) Server VM (build 23.21-b01, mixed mode)

[http://blog.csdn.net/yang_hui1986527/article/details/6677450]: http://blog.csdn.net/yang_hui1986527/article/details/6677450
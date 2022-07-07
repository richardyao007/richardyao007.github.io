---
layout: post
title:  "[Android]ubuntu下adb连接android手机"
date:   2016-11-17 09:14:49 +0800
category: Android
---


ubuntu下adb连接android手机

1. sudo apt install android-tools-adb

2. 设置usb选项， 媒体设备(MTP)

3. 查看手机的usb信息    lsusb

Bus 002 Device 004: ID 18c3:6255

Bus 002 Device 002: ID 8087:0020 Intel Corp. Integrated Rate Matching Hub

Bus 002 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub

Bus 001 Device 005: ID 22b8:41db Motorola PCS Motorola Droid (USB Debug)

Bus 001 Device 004: ID 04d9:a06b Holtek Semiconductor, Inc.

Bus 001 Device 003: ID 058f:b002 Alcor Micro Corp.

Bus 001 Device 002: ID 8087:0020 Intel Corp. Integrated Rate Matching Hub

4. 添加udev规则

cd /etc/udev/rules.d/

sudo vim 50-android-usb.rules

编辑规则文件并保存

 SUBSYSTEM=="usb", SYSFS("Motorola PCS Motorola Droid (USB Debug)")=="22b8",MODE="0666"

 其中，sysfs括号内是自己android手机的实际描述信息，==后面的是id号，mode是读取模式，0666是所有人可以访问，以上的信息都是lsusb查处来的。

5. 设置规则文件权限以及重启

sudo chmod a+rx /etc/udev/rules.d/50-android-usb.rules

sudo /etc/init.d/udev restart


6. 设置adb信息

 进入sdk得platform-tools目录

hang@CAPF:/opt/android-sdk-linux_x86/platform-tools$ sudo ./adb kill-server

hang@CAPF:/opt/android-sdk-linux_x86/platform-tools$ sudo ./adb devices

* daemon not running. starting it now on port 5037 *

* daemon started successfully *

List of devices attached




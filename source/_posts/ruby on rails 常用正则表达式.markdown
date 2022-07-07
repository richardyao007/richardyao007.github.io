---
layout: post
title:  "[RubyOnRails]常用正则表达式"
date:   2013-05-07 16:26:49 +0800
categories: RubyOnRails
---

    #1.用戶名注冊
    /^[a-z0-9_-]{3,16}$/
    #以字母開頭,包含字母,數字,_,-的3-16個字符

    #2.用戶密碼
    /^[a-z0-9_-]{6,18}$/
    #同上

    #3.十六進制數
    /^#?([a-f0-9]{6}|[a-f0-9]{3})$/
    #以#开头或者不以#开头, 后面跟 6个字符(a-f或者0-9) 或者 3个字符(a-f或者0-9)

    #4.匹配一個Slug(啥叫Slug?看看上面地址栏里的那一陀)
    /^[a-z0-9-]+$/
    #多個字母(a-z),數字(0-9),和-組成的字符

    #5.匹配Email地址,此乃神器也
    /^([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$/

    #6.匹配Url
    /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/

    #7.匹配IP地址
    num = /\d|[01]?\d\d|2[0-4]\d|25[0-5]/
    exp = /^(#{num}\.){3}#{num}$/

    #num是每个数字串的匹配模式, exp就是最终的RegExp了,下面是演示:

    irb(main):001:0> num = /\d|[01]?\d\d|2[0-4]\d|25[0-5]/
    => /\d|[01]?\d\d|2[0-4]\d|25[0-5]/
    irb(main):002:0> exp = /^(#{num}\.){3}#{num}$/
    => /^((?-mix:\d|[01]?\d\d|2[0-4]\d|25[0-5])\.){3}(?-mix:\d|[01]?\d\d|2[0-4]\d|25[0-5])$/
    irb(main):003:0> exp.match("192.168.1.22")
    => #<MatchData "192.168.1.22" 1:"1.">

    #8.匹配时间/日期类型（yyyy.mm.dd hh:mm:ss)
    yyyy = /[1-9]\d\d\d/
    mm = /0?[1-9]|1[12]/
    dd = /0?[1-9]|[12]\d|3[01]/
    hh = /[01]?[1-9]|2[0-4]/
    MM = /[0-5]\d/
    ss = /[0-5]\d/
    date_time = /^(#{yyyy}\.#{mm}\.#{dd}) (#{hh}:#{MM}:#{ss})$/

   #9.只能是数字或者小数

    with_options :format => {:with => /^[1-9][0-9]{0,2}(?:,?[0-9]{3})*(?:\.[0-9]{1,2})?$/, :message => "格式错误，只能是数字或者小数"},:allow_blank=>true do |v|
      v.validates :realOperationsKm
      v.validates :realTravelKm
      v.validates :addOil
      v.validates :addOilBycash
      v.validates :extraHourQty
      v.validates :realExtraHourFee
      v.validates :realXKm
      v.validates :realXKmFee
      v.validates :roadBridgeFee
      v.validates :realParkingCharge
      v.validates :othercharge
    end

   #10.车牌号正则
   /^[\u4e00-\u9fa5]{1}[A-Z]{1}-[A-Z_0-9]{5}$/
validates :car_tag,:engine_type, :format=>{:with=>/^[\u4e00-\u9fa5]{1}[A-Z]{1}-[A-Z_0-9]{5}$/,:message=>"车牌号格式不正确"}

   #11.手机号码
   /^1[3|4|5|8][0-9]\d{4,8}$/

   #12.传真/电话号码
   /^((\d{11})|^((\d{7,8})|(\d{4}|\d{3})-(\d{7,8})|(\d{4}|\d{3})-(\d{7,8})-(\d{4}|\d{3}|\d{2}|\d{1})|(\d{7,8})-(\d{4}|\d{3}|\d{2}|\d{1}))$)/
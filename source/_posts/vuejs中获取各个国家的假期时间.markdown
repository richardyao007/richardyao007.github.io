---
layout: post
title: '[Vue]vuejs中获取各个国家的假期时间'
date: 2022-07-10 22:14:49 +0800
categories: 
- Vue
- JavaScript
---

### 使用yarn或者npm安装包
``` bash
yarn add date-holidays
or
npm install date-holidays
```

>这块注意自己的node版本，不同node版本匹配不同版本的包

### 在.vue中的使用
``` bash
import Holidays from "date-holidays";
// JP指取日本的数据: (具体国家代码缩写后面有说明)
let holidays = new Holidays('JP')

//下面是比较常用的方法
//获取指定年的假期数据信息, year为指定年份
holidays.getHolidays(year)

//判断指定日期是否为假期, date为需要判断的日期字符串
holidays.isHoliday(date)   //该方法返回结果为false即不是假期，如果是一个对象即相应的假期信息
```

<sub>具体国家代码缩写，以及相应版本请参考</sub>
[Click this](https://yarnpkg.com/package/date-holidays).

>非常方便，有使用到类似功能开发的，推荐使用.

>我这边是后端的数据需要进行判断和比对，所以这块是前端调用`getHolidays`方法获取假期数据，传递到后台，后台处理，前端再显示。
---
layout: post
title:  "[RubyOnRails]Ruby Array学习总结"
date:   2013-05-07 16:26:49 +0800
categories: RubyOnRails
---

Array

&取两数组相同

*数组相乘

+数组相加

-[1,2,3]-[1,2,4] = [3]

<<追加

<=>比较每个元素 小于-1等于0大于1(每个元素比较)

to_ary转换成数组

==相等

[]        下标引用。a=[1,2,3,4].a[1]下标为1的元素,a[1,3]从下标为1顺序取三个,a[1..3]1-3的元素.特殊 a[4]=>nil, a[4..6]=>[], a[5..7] => nil

[]=        赋值

｜并集操作,也就是把不同的组合在一起

assoc('a')    匹配子数组第一个元素,匹配到返回子数组，否则nil不匹配字符串

at        返回下标处元素,比[]快，不支持range(范围,例:1..5)参数

clear        清楚数组

collect收集    对每个元素调用block。！号模式替换原来的，此拷贝原来数组

compact压缩    去掉nil,有！号模式

concat        追加后面的数组

delete        删除指定元素，返回删除元素,数组没有指定的元素返回nil，有block返回block[1,2].delete(1) {"sorry"}

delete_at     删除指定下标的

delete_if    有条件删除，调用block,返回剩余元素

each        循环数组

each_index    循环下标

empty?        判断是否为空

eql?        比较

fetch取来    用法a=[1,2,3] a.fetck(1)=>2,a.fetch(1,"b")=>1,a.fetch(5,"b")=>b,a.fetch(5){|i|i*i}=>25

fill填充,装满    参数型式(obj),(obj,range(范围)),{|i| i代表下标},(range){|i|操作}

flatten        扁平数组,!号模式

include?    包含 true or false

index        返回下标或nil

insert        插入只能指定下标，不能指定下标范围

join        合并，后面可以加参数('-')

last        返回最后一个，也可以加返回最后几个

length        数组长度

map        和collect同义

nitems        返回非nil的长度

pop        删除数组最后一个元素并返回,nil也返回nil

push        将指定参数加到数组中,可以任何对象

rassoc        不怎么明白有何用

reject        等同于delete_if

replace取代    替换元素

reverse相反    反序有！模式

reverse_each    逆序遍历数组

rindex        删除数组的最后一个指定的对象，没有返回nil

shift        删除第一个

slice        于[]同义

slice!        删除给定的索引，参数是range

sort        排序,有！模式

to_a,to_ary    转换成数组

tracspose    二维数组更换行和列

uniq        删除重复元素，有！模式

unshift        添加对象到数组首部

values_at    参数下标，返回数组。可以是范围
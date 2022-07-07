---
layout: post
title:  "[jQuery]增加 删除 修改select option"
date:   2013-05-07 16:26:49 +0800
categories: JQuery
---

 jQuery获取Select选择的Text和Value:

      1. var checkText=jQuery("#select_id").find("option:selected").text();   //获取Select选择的Text

      2. var checkValue=jQuery("#select_id").val();   //获取Select选择的option Value

      3. var checkIndex=jQuery("#select_id ").get(0).selectedIndex;   //获取Select选择的索引值

      4. var maxIndex=jQuery("#select_id option:last").attr("index");   //获取Select最大的索引值

jQuery添加/删除Select的Option项：

      1. jQuery("#select_id").append("
Text");   //为Select追加一个Option(下拉项)

      2. jQuery("#select_id").prepend("
请选择");   //为Select插入一个Option(第一个位置)

      3. jQuery("#select_id option:last").remove();   //删除Select中索引值最大Option(最后一个)

      4. jQuery("#select_id option[index='0']").remove();   //删除Select中索引值为0的Option(第一个)

      5. jQuery("#select_id option[value='3']").remove();   //删除Select中Value='3'的Option

      6. jQuery("#select_id option[text='4']").remove();   //删除Select中Text='4'的Option
内容
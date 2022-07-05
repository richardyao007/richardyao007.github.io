---
layout: post
title:  "[jQuery]中removeAttr方法在IE8以下版本中的Bug"
date:   2014-09-09-09 22:14:49 +0800
categories: JQuery
---


$("#inputid").removeAttr('data-validate')  //如果removeAttr不起作用，可以使用

$("#inputid").prop('data-validate',false)

或

$("#inputid").prop('checked',false) or .removeAttr('checked')?
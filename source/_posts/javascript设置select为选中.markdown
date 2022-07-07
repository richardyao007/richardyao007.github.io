---
layout: post
title:  "[JavaScript]设置select为选中"
date:   2013-03-20 09:47:49 +0800
categories: JavaScript
---


    function jsSelectItemByValue(objItemText)
    {
        //判断是否存在
        for(var i=0;i
        {
            if(objSelect.options[i].value ==objItemText)
            {
                objSelect.options[i].selected = true;
                break;
            }
        }
    }
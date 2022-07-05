---
layout: post
title:  "[javascript] highchart使用心得"
date:   2022-03-11 09:14:49 +0800
category: javascript
---




        let that = this;
        Highcharts.setOptions({
            lang: {
                thousandsSep: ','
            }
        });
        let max = 10;
	//根据X轴拿到的数据进行判断，没有超过10条就按照X轴拿到的数据总数显示
        if(that.xAxisCategories.length < 10) {
            max = that.xAxisCategories.length -1;
        }
        Highcharts.chart('chart', {
            chart: {
                type: 'column'
            },
            scrollbar: {
              enabled: true      //显示滚动条
            },
            legend: {
                enabled: false   //不现实图例
            },
            title: {
                text: ''      //不显示标题
            },
            credits: {
                enabled: false //去掉默认右下角的highchart.com
            },
            subtitle: {
                text: '' //不现实子标题
            },
            xAxis: {
                categories: that.xAxisCategories,   //X轴数据，如：['2022-01-01', '2022-01-02', '2022-01-03', '2022-01-04', '2022-01-05', '2022-01-06', '2022-01-07']
                tickWidth: 1,    //X轴刻度显示
		//很关键，控制超出多少个会出现滚动条
                min: 0,
                max: max
            },
            yAxis: {
                title: {
                    enabled: false     //Y轴标题是否显示
                },
                gridLineDashStyle: 'longdash',   //背景显示虚线格
                lineWidth: 1,                   //显示Y轴
                tickWidth: 1,                   //显示Y轴刻度
	       //Y轴值为0的时候不居中显示，使用以下两个属性
                min: 0,                       
                minRange: 1
            },
            plotOptions: {
                 //控制显示出来的柱状图样式，颜色等
                column: {
                    borderWidth: 0,
                    dataLabels: {
                        enabled: true，    //
                        style: {
                            fontWeight: 'normal',
                            color: '#666666'
                        }
                    },
                    color: '#45DDCC'
                }
            },
            series: [{
                name: that.typeText,    //鼠标放在柱状图上，显示的文字
                data: that.seriesData   //Y轴数据，如：[1,2,3,4,5,6,7]
            }]
        });
    
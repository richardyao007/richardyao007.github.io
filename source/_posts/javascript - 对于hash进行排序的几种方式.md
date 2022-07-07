---
title: javascript-对于hash进行排序的几种方式
date: 2021-09-30
---
### 1. 根据 string类型来排序，使用 localeCompare

``` bash
$ let elements = [ 
  {   year: 1, value: 1},   {year: 2, value: 2}
]
elements.filter(x => x)   // 这个是为了去重复，可以先不看了。
// 为year做排序
.sort( (a,b) => { return (a.year + '').localeCompare(b.year + '')})
```

More info: [Writing](https://hexo.io/docs/writing.html)

### 2. 根据 int类型来排序，使用 - 号即可

``` bash
$ let elements = [ 
  {   year: 1, value: 1},   {year: 2, value: 2}
]
// 为year做排序
elements.sort( (a,b) => { return a.year - b.year})
```

---
title: vuejs - 普通方法 ， watch 与 computed
date: 2021-07-15
---
## 例子参考

https://cn.vuejs.org/v2/guide/computed.html

一些时候，computed  也可以使用 methods 来实现。区别是

### computed

有缓存。 提供了getter, 但是也提供了setter

computed中的属性跟data中定义的变量是同等地位的（也就是说， computed中定义了，data中就不用出现了。都可以使用this.xx 来访问）

### methods

： 没有缓存， 每次都计算

### watch

可以使用watch来实现computed, 使用 异步操作时，把结果使用watch 来监听是合适的（只能由watch来实现，computed无法实现）
所有watch的变量都是data中定义的变量
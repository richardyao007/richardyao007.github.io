---
layout: post
title: '[node]自定义npm包，以及制作和使用流程'
date: 2022-08-10 22:14:49 +0800
categories:
- Npm, Node, Javascript
---

> 1. 首先，需要将需要打包的javascript文件所有的依赖文件从中剥离出来

> 2. 其次，把javascript文件和其依赖文件单独放在一个目录下

> 3. 最后使用npm相关命令，登录，发布


>> 需要提前注册好npm相关账号，注册地址：（https://www.npmjs.com/）

>> 请确保当前链接源是官网，使用nrm工具可以快速查看和切换

`
npm install nrm
`

`
nrm ls
`

`
npm config set registry https://registry.npmjs.org
`

1. 登录npm用户

    `
    npm adduser
    `

    > 命令执行后会需要依次输入以下信息

    1> 输入用户名
    
    2> 输入密码
    
    3> 输入邮箱
    
    4> 输入 OTP code（email中会收到的一个code）


2. 发布包

    `
    npm publish --access public
    `

- 引用和使用npm包

   - 下载安装依赖包(安装指定版本)
    
    `
     npm install -S your-package-name@1.0.0 
    `
        
   - 调用npm包
    
    `
     import {something} from 'your-package-name' 
    `    

  - 更新npm包
    - 每次修改完code后，一定要更新版本号
    
    `
    //直接修改package.json中的version
    "version": "1.1.0"
    `
    
    `
    //或者使用命令修改
    npm version 1.1.0
    `
    
    - 再次发布
        
      `
      npm publish --access public
      `
      
- 撤销发布的npm包

    如果因为某种原因需要撤销已经发布提交的npm包
  
    超过24小时后无法撤销

    `
    npm --force unpublish your-package-name
    `

> 注意
 
>> 1. 在24小时加上 --force强制执行才可以实现。即使撤销了发布的包，再次发布的时候也不能与之前被撤销的包的名称和版本其中之一相同，包名和包版本组成唯一标识，即使撤销也并不会消失，不能重复使用。

>> 2. 撤销的包不能立马再次发布，撤销24小时后才能再次发布。
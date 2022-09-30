---
layout: post
title:  "[Vuejs+Nginx] vuejs + nginx常见跨域问题解决方案"
date:   2022-07-10 09:14:49 +0800
category: vuejs Nginx
---




###一般只需要在nginx.conf配置文件的 location ~ \.php$ { 中添加如下配置：

``` bash
if ($request_method = 'OPTIONS') {
    add_header 'Access-Control-Allow-Origin' $http_origin always;
    add_header 'Access-Control-Allow-Credentials' 'true';
    add_header 'Access-Control-Allow-Methods' 'GET, POST, PATCH, DELETE, PUT, OPTIONS';
    add_header 'Access-Control-Allow-Headers' 'DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,  Access-Control-Expose-Headers, Token, Authorization';
    add_header 'Access-Control-Max-Age' 1728000;
    add_header 'Content-Type' 'text/plain charset=UTF-8';
    add_header 'Content-Length' 0;
    return 204;
}

if ($request_method = 'POST') {
    add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
    add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type';
}

if ($request_method = 'GET') {
    add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
    add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type';
}
```
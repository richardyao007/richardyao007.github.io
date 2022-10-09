---
layout: post
title: '[docker]docker常用基本操作'
date: 2022-04-10 22:14:49 +0800
categories: 
- Docker
---

### 两个非常重要的概念： image , container
> image: 镜像, 静态的东东,  可以被commit. 可以被删除。

> container:  docker "run" （注意是不是start ) image 之后的到的东东.   内容不会被自动保存。  docker run 命令 就会产生新的。 而且docker 的理念是container 可以随时随地产生和抛弃。

> docker run 命令： 根据image 来得到一个运行中的 container .这是一个崭新的container.

> docker start 命令： 把之前停止的 container 跑起来

可以通过 --help 来查看 详细命令，例如  $ docker run --help 会打印出详细的解释。

### docker ps  查看 运行中的container
```bash
CONTAINER ID        IMAGE                COMMAND                  CREATED             STATUS              PORTS                                           NAMES
fde1709c0722        xx_backend           "bundle exec puma -C…"   15 hours ago        Up 15 hours         0.0.0.0:8333->443/tcp, 0.0.0.0:3333->3000/tcp   xx_backend_1
a6cce4485a11        gate_rails           "sh -c 'rm -f tmp/pi…"   37 hours ago        Up 37 hours         0.0.0.0:8443->443/tcp, 0.0.0.0:3001->3000/tcp   gateapp
46e63e19f41f        redis                "docker-entrypoint.s…"   39 hours ago        Up 15 hours         0.0.0.0:6379->6379/tcp                          art-lesson_redis_1
```

### docker ps -a  查看所有的container
```bash
CONTAINER ID        IMAGE                          COMMAND                  CREATED             STATUS                       PORTS                                           NAMES
09eb05026ee3        art-lesson_operator_frontend   "docker-entrypoint.s…"   15 hours ago        Exited (1) 5 minutes ago                                                     art-lesson_operator_frontend_1
fde1709c0722        art-lesson_backend             "bundle exec puma -C…"   15 hours ago        Up 15 hours                  0.0.0.0:8333->443/tcp, 0.0.0.0:3333->3000/tcp   art-lesson_backend_1
b52fb63efbbe        c00d6886c4eb                   "docker-entrypoint.s…"   16 hours ago        Exited (0) 16 hours ago                                                      wizardly_goldstine
8b987c955e58        dc14bf43540d                   "/bin/sh -c 'set -e …"   16 hours ago        Exited (137) 16 hours ago                                                    sharp_perlman
a6cce4485a11        gate_rails                     "sh -c 'rm -f tmp/pi…"   37 hours ago        Up 37 hours                  0.0.0.0:8443->443/tcp, 0.0.0.0:3001->3000/tcp   gateapp
46e63e19f41f        redis                          "docker-entrypoint.s…"   39 hours ago        Up 15 hours                  0.0.0.0:6379->6379/tcp                          art-lesson_redis_1
f349047c5be2        933f6                          "/bin/bash"              14 months ago       Exited (0) 14 months ago                                                     competent_noether
43e658ea2787        933f6                          "/bin/bash"              14 months ago       Exited (0) 14 months ago                                                     jolly_turing
abda2002620b        933f6d242546                   "-v /workspace:/work…"   14 months ago       Created                                                                      relaxed_johnson
333d33e9ef2b        vulhub/nginx:heartbleed        "/usr/local/nginx/sb…"   15 months ago       Exited (255) 15 months ago   0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp        heartbleed_nginx_1
b9a24255799f        imagetragick_apache            "docker-php-entrypoi…"   15 months ago       Exited (0) 15 months ago                                                     imagetragick_apache_1
```

### docker run  <image_name>
根据已有的image  创建一个新的container 并运行

例子： 运行 image: 933f6,  使用host ip,  并且把 host 的 /workspace 文件夹加载到container 中的 /workspace

docker run -v /workspace:/workspace --net=host -it --hostname=admin-container 933f6

### docker create
创建一个新的container ,但是不启动

### docker start <id>
运行一个已经存在的,并且已经停止的container

### docker stop <id>
停止已经一个存在的container

### docker rm <container id>
删除一个或者多个container

### docker image ls   或者  $ docker images    
查看本地所有的image

### docker exec -it <container id> /bin/bash
直接类似于使用ssh 登录一个container

### docker attach <container id>
查看某个container

### docker logs <container id>
查看某个container 的shell的输出

### docker inspect <container id> , 查看某个container的详细情况. 包括ip 等。

``` bash
docker inspect c7180f611c13
[
{
"Id": "c7180f611c13d238755898e83f7fdefb06fad782f87e3ec9e260d3f62625c9a0",
"Created": "2020-12-14T09:44:03.290361691Z",
"Path": "/bin/bash",
"Args": [],
"State": {
"Status": "running",
"Running": true,
"Paused": false,
"Restarting": false,
"OOMKilled": false,
"Dead": false,
"Pid": 8122,
"ExitCode": 0,
"Error": "",
"StartedAt": "2020-12-14T09:44:03.899503111Z",
"FinishedAt": "0001-01-01T00:00:00Z"
},
```

### docker ps   列出运行中的container    ( 如果要列出所有，就 docker ps -a )

``` bash
# docker top c7180f611c13
UID                 PID                 PPID                C                   STIME               TTY                 TIME                CMD
root                8122                8096                0                   17:44               pts/0               00:00:00            /bin/bash
```

### docker commit  ( 记得要在 docker-compose停止之后, 否则会卡死)

先把docker停止,然后 docker ps -a 就可以看到所有的container. exit也没问题.

为某个image 进行内容的永久性修改.  记得: 务必要加上  <container id>   image:tag_name 作为结尾, 例如:

docker commit -a 'dashi' -m '增加tag名字' c7180f611c13 ubuntu:add_vim

sha256:4efbaa2d43fc40ac308297fe6e0df72fd2e55a9700abee5c9e4aa28b41cbf0a4

后面的:add_vim 不加的话,默认就是 :lastest  ,  -a 'dashi' 也可以不加.

### docker rmi <image_id> 删掉某个image
``` bash
$ sudo docker image ls
REPOSITORY         TAG              IMAGE ID       CREATED          SIZE
snexx_data_rails   latest           0de6f45596fa   34 seconds ago   1.19GB
snexx_data_rails   installed_gems   f8c24d5a9f1c   2 minutes ago    1.19GB
mysql              5.7              82d2d47667cf   18 hours ago     450MB
ubuntu             latest           825d55fb6340   2 weeks ago      72.8MB
hello-world        latest           feb5d9fea6a5   6 months ago     13.3kB
ruby               2.5.8            fc5e02c64ca4   12 months ago    843MB

$ sudo docker rmi f8c24d
Untagged: sneak_data_rails:installed_gems
Deleted: sha256:f8c24d5a9f1ccf3c70ab3ef3a67cae0124d506e8c8a1bb3d6461676daf3b344f
Deleted: sha256:1a585b5ce639cb9d2b569d0a372d75bae57496415d03322fd1b57325e1ac8462

$ sudo docker image ls
REPOSITORY         TAG       IMAGE ID       CREATED              SIZE
snexx_data_rails   latest    0de6f45596fa   About a minute ago   1.19GB
mysql              5.7       82d2d47667cf   18 hours ago         450MB
ubuntu             latest    825d55fb6340   2 weeks ago          72.8MB
hello-world        latest    feb5d9fea6a5   6 months ago         13.3kB
ruby               2.5.8     fc5e02c64ca4   12 months ago        843MB

```

### docker image ls  列出所有的docker image
REPOSITORY TAG IMAGE ID CREATED SIZE
ubuntu add_vim 4efbaa2d43fc About a minute ago 167MB

### docker export
把 container 导出 , 例如:   docker export -o rails_container.tar c7180f611c13

### docker save
把 image 导出, 例如：　docker save -o rails_image.tar 253ea174ad29

### docker load
docker import
把image 导入。（但是不运行，仅仅导入到本地的image 仓库）

### docker cp
把本地的copy到container 中。 或者反之

docker cp <containerId>:/file/path/within/container /host/path/target

或者  docker cp ~/.vim <containerid>:/root

### docker run 运行docker ，并且加上各种参数。
-v 加上本地存储

docker 不支持symlink, 参考：  https://stackoverflow.com/questions/38485607/mount-host-directory-with-a-symbolic-link-inside-in-docker-container/40322275

## docker-compose
运行某个指定的yml文件：

docker-compose -f ./docker-compose.yml up

另一个例子： （会在本地目录寻找  .privoxy, 然后运行里面的Dockerfile )

``` bash
version: '3'
services:

socks5tohttp_proxy:
build: ./privoxy
container_name: "socks5tohttp_proxy"
volumes:
- /g/workspace/temp_socks_to_http_proxy:/root
command: 'tail -f /dev/null'
#command: 'mysqld'
ports:
- "1080:1080"
stdin_open: true
tty: true
#environment:
#  - MYSQL_ROOT_PASSWORD=666666
#  - MYSQL_ROOT_HOST=%
```

./privoxy文件夹如下：

``` bash
FROM alpine:3.11

RUN apk update \
&& apk add privoxy \
&& rm -rf /var/cache/apk/*

# CMD ["privoxy","--no-daemon","/etc/privoxy/config"]
```

进来之后就可以随便操作了：

``` bash
/ # ps
PID   USER     TIME  COMMAND
1 root      0:00 tail -f /dev/null
15 root      0:00 sh
21 root      0:00 ps
```
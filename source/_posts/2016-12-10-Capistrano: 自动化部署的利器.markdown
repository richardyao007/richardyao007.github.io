---
layout: post
title:  "[部署]Capistrano: 自动化部署的利器"
date:   2016-12-10 09:14:49 +0800
category: 部署
---


Capistrano: 自动化部署的利器

注意： 以下的文档针对的版本是 2.12.0 capistrano 3.x 跟 2.x 的工作原理是差不多的. 掌握了其中一个, 就可以很快掌握第二个. 区别在于 3.x 只在 ruby 2.x 版本下工作. 很多项目都是 1.9.x的,所以我们以capistrano 2为例.

简介

Capistrano 是个好用的自动化部署工具, 能够快速自动的将自己的代码部署到正式服务器上面。 替代人肉的工作.

注意: (TODO 另起个章节,专门说安全问题)

绝对不要把 config/deploy.rb 放到代码仓库中. 绝对不要把 config/deploy.rb 放到代码仓库中. 绝对不要把 config/deploy.rb 放到代码仓库中.

同理, 不要把 配置信息 放到 代码仓库中. 比如:

数据库配置信息: database.yml 邮箱配置信息: mail.yml 应用服务器配置信息: thin.yml, unicorn.yml

如果你在公司中发现这样的人,直接把他开掉. 对服务器没有安全意识.

无数的服务器配置信息,都在github上的公共项目中的 部署脚本 文件中泄漏出去的. 端口号, 用户名, ip地址一泄漏出去的话,基本上对方拿个密码字典碰几天, 你的服务器就成了肉鸡了.

为什么不要人肉去做

很多同学在部署时,用的是自己写的脚本. 这个就不对了. 自己写的脚本永远不专业. 不要自大,相信我没错的.

哪怕是运维级别的同学,写出来的脚本,也无法轻易回滚. 因为这里的逻辑还是比较多的,光靠脚本不行. 还得 需要比较多的代码逻辑.

最常见的人肉脚本是:

进入到代码仓库
$ cd < your code repo>
更新代码:
$ git pull
重启
$ bundle exec thin restart
如果你有20个服务器,就可以这样使用脚本去做了.

但是上面最大的缺点:

无法回滚
你要祈祷工作顺风顺水,稍微有一个环节出了错, 就要手续继续处理剩下的环节.
安装方式：

进入到项目目录下面,并增加下面内容到 Gemfile 中：
group :development
  gem 'capistrano', '2.12.0'
  gem 'capistrano-rbenv', '1.0.1'
end
安装添加的gem
$ bundle install
再运行下面的命令：
$ capify .
capify .
[skip] './Capfile' already exists
[skip] './config/deploy.rb' already exists
[done] capified!
会生成两个关键性的文件： Capfile , config/deploy.rb

编辑后者config/deploy.rb 加上自己的capistrano配置信息
启动deploy中的setup任务,创建一些必要文件夹
下面是一个完整的 部署脚本( config/deploy.rb )的例子, 修改其中的 用户名,端口号, 目标服务器的域名 , 服务器的启动方式, 就可以直接运行了.:

# -*- encoding : utf-8 -*-
require 'capistrano-rbenv'
load 'deploy/assets'
SSH_USER = '你的用户名'
SSH_PORT = '你的端口号'
server = "目标服务器的域名或者ip"
FOLDER_IN_REMOTE_SERVER = '远程服务器上的目标文件夹'

ssh_options[:port] = SSH_PORT
set :rake, "bundle exec rake"
set :application, "app name"
set :repository, "."
set :scm, :none
set :deploy_via, :copy

role :web, server
role :app, server
role :db,  server, :primary => true
role :db,  server

set :deploy_to, FOLDER_IN_REMOTE_SERVER
default_run_options[:pty] = true

# change to your username
set :user, SSH_USER

namespace :deploy do
  task :start do
    run "cd #{release_path} && bundle exec thin start -C config/thin.yml"
  end
  task :stop do
    run "cd #{release_path} && bundle exec thin stop -C config/thin.yml"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    db_migrate
    stop
    sleep 2
    start
  end
  task :db_migrate do
    run "cd #{release_path} && bundle install"
    run "cd #{release_path} && bundle exec rake db:migrate RAILS_ENV=production"
  end

  namespace :assets do
    task :precompile do
      #run "bundle install"
      #run "cd #{release_path} && bundle exec rake RAILS_ENV=production RAILS_GROUPS=assets assets:precompile "
    end
  end
end


desc "Copy database.yml to release_path"
task :cp_database_yml do
  puts "=== executing my customized command: "
  run "cp -r #{shared_path}/config/* #{release_path}/config/"
  run "ln -s #{shared_path}/files #{release_path}/public/files"
  # 因为在开发机器上会存在这个文件夹，所以需要先把它删掉，再 ln
  run "rm #{release_path}/public/uploads -rf"
  run "ln -s #{shared_path}/public/uploads #{release_path}/public/uploads"
  puts "=== done (executing my customized command)"
end

before "deploy:assets:precompile", :cp_database_yml
#after "deploy", "deploy:restart"
第一次运行时,要先 配置好目标服务器上的文件夹.

$ cap deploy:setup
注意: 这里让它创建基本的目标文件夹目录层次就可以:

/opt/app:
    current (这是个软链接 soft link, )-> /opt/app/releases/20150518030114/
    releases/
    shared/
        assets
        config
        files
        log
        pids
        public
        system
不要让它做 : 安装rbenv, 安装ruby 版本, 安装第三方包的事儿.

注意： 这里务必记得， 盯紧控制台的输出， 看到它执行完 mkdir -p 之后， 赶紧按ctrl + c 暂停。否则它会默认在远程服务器上安装各种ruby 第三方包，安装各种linux 依赖包。一不小心就会把服务器环境搞砸了。

为 shared 目录下，增加各种配置文件，它们只需要被配置一遍。例如：
config/thin.yml       # 服务器的配置
config/database.yml   # 数据库的配置
config/log4r.yml      # 日志文件的配置
config/settings.yml   # 系统的配置
配置好ruby环境， mysql, thin, nginx 等
开始部署

$ cap deploy.
这个命令会执行下面的过程:

准备启动服务器:
安装各种新增的rubygem
做必要的数据库迁移
配置各种文件
修改上传文件夹的softlink
其他,每次使用裸代码做部署的时候,都要人肉做的事情. (修改保存日志的路径, 修改 rails server的配置, )
编译,压缩 js/ css
重启 服务器( $ nginx -s reload, $ kill -9 xxx , $ thin start -C config/thin.yml)
再次部署（更新版本）

只需要运行$ cap deploy即可。

使用命令行

下面是一个例子，在命令行中显示 User name: , 等用户输入完，按回车之后， 把输入的值赋给 user 变量。

set(:user) { Capistrano::CLI.ui.ask("User name: ") }
使用帮助：
$ cap --help
使用logger，特别是在其他语言调用CAP时，非常有用（例如被fabric 调用）:
$ cap setup --logger STDOUT
如何使用变量?
要记得: 使用@. . 例如，我们要设置 "deploy_type" 这个变量：

$ cap say_hi --set-before deploy_type=staging
然后在 config/deploy.rb 中这样使用：

DEFAULT_TYPE = "stable"

# deploy_type 仅仅在 begin 这个区域中生效, 在rescue, ensure中都不行。
begin
  deploy_type
  puts "deploy_type was set successfully"
  @deploy_type = deploy_type
  rescue Exception => e
  puts "deploy_type not set, use default: #{DEFAULT_TYPE}"
  deploy_type = DEFAULT_TYPE
  @deploy_type = deploy_type
end

task :say_hi do
  puts "hihihi, var_deploy_type: #{@deploy_type}"
end
输出：

deploy_type was set successfully
============= DEPLOY_PATH: /rails_apps/babble_portal/cutting_edge
* executing `say_hi'
hihihi, var_deploy_type: 444
最后，使用copy方式：

# 脚本中
set :scm, :none
set :repository, "."
set :deploy_via, :copy
capistrano的输出详解

TODO 各种屏幕截图。 建立文件夹， 打包，压缩，上传，解压缩， rake db.. assets等等

为什么要用capistrano

流行的工具都是有道理的（ best practices are best in most cases)

版本控制：SVN => GIT( scm : from SVN to GIT)

部署方式：人肉部署 => Capistrano

原来项目中用到的是SVN， 就一个分支，也不打tag。感觉用起来没啥。 ( there's not so much trouble when the project is going under SVN and manual deployment)

现在服务器的配置被运维同学限制了，无法连到SCM服务器 (同时无法连接到外网，无法连接到很多内部网络，比如LDAP，RADIUS等等）。肿么办???? (but one day, the server was limited its access to the internet, git repo and local LDAP , Radius service... what shall we do? )

如果用SVN的话，就得用SCP的方式，打包过去，然后修修改改，每次都要人肉来做，还出错。(if using SVN, we have to copy the entire code folder to the target server, easy to make mistake and really painful for me )

现在换成了GIT，不用capistrano的话，直接在本地把 git-patch 上传过去，然后 git am 就好。(now since we have migrated the SVN to GIT repo, it's very easy to achieve the same goal using 'git-patch' and 'git am' )

用了capistrano的话，用 deploy_via :scp 的 方式，我每次部署一行命令，自动搞定了。 ( and in capistrano, we just need to use 'deploy_via scp' to do the deployment job )

所以，老式的办法，在某些新问题出现的时刻，不是那么得心应手。业界流行的“最佳实践”，在大部分情况下，还是“最佳实践”的。 ^_^ ( the conclusion is: best practices are always best in most cases. )

—— 学习是王道！ ( keep STUDYING everyday! )

capistrano的原理

裸代码: 没有数据库的配置文件, 没有服务器相关的配置文件, 也没有压缩各种css/js , 一般都是从git上直接clone下来的代码。

传统的部署步骤:

ssh 登陆到服务器
git pull
restart command（重新启动）
坏处是:

无法回滚,
每次都人肉, 特别麻烦.
虽然上面3个步骤看似很少, 但是需要一直盯着(比如, ssh 需要10秒, git pull 需要20秒, restart 也需要人肉输入, 这些都是时间上的损耗, 而且人肉做重复性的事情, 无趣, 容易出错。

合理的部署是:

编写好一个配置文件之后, 运行代码: $ cap deploy (一个命令) , 之后的所有事情,都不用人参与了。

结构:

有三个角色:部署人员的机器,目标服务器,代码服务器(GIT)

TODO: 没xuan的图片

( 见譞的本本上的图 )

每次部署, 都要做的事情:

SSH 到目标服务器
把最新的代码,上传到目标服务器上。这时候的代码是裸代码，不能立刻部署, 因为很多配置文件都没有。

我们不能把配置文件也放到github里面跟踪, 比如: config/database.yml , 每个人或服务器的数据库的 mysql 密码都不一样。

以及其他的内容(上传文件夹)

项目的回滚

回滚的方式有几种:

code roll back

git checkout ... 这样不好,很多时候我们无法保证代码是没有被修改的。 被修改之后, checkout操作会涉及到代码合并的情况, 在某些 紧急 BUG 出现时, 会特别明显.

使用capistrano,将上一次的release回滚,每一个release都用一个文件夹(里面包含了完整的项目代码, 包括裸代码, 和 各种配置文件)。

目录结构

20150310010954, 20150319015536 这种时间戳命名的文件夹，代码某一个时间段部署的版本。

有一个特殊的softlink(软链接),current。

web服务器的nginx配置,thin配置可以指向这个softlink,这样就不需要每次都改nginx，thin 的配置文件了, 只需要把current这个softlink,重新指向不同的 release 文件夹就可以了。

shared文件夹中所保存的内容, 以及部分目录结构, 是由 config/deploy.rb 这个配置文件决定的

capistrano部署web应用的文件结构是:

/opt/rails_app:
    current -> /opt/app/happystock_web/releases/20150518030114/
    releases/
        20150310010954
        20150319015536
        20150518030114
    shared/
        assets
        config
        files
        log
        pids
        public
        system
常见问题

无法部署capistrano? Net::SSH::AuthenticationFailed: Authentication failed

对于capistrano 2.12.0,显式指定Gemfile中net-ssh 的版本，例如：

gem 'net-ssh', '2.7.0'
下面是一个完整的deploy.rb文件：

https://github.com/beijing-rubyist/bjrubyist/blob/master/config/deploy.rb





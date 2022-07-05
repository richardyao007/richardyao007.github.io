---
layout: post
title:  "[rails] 项目增加日志功能(log)"
date:   2017-01-10 09:14:49 +0800
category: rails
---


操作日志是几乎每一个项目所必须要有的

我本来希望把它做成一个rails plugin 或者gem, 但是时间有限...

下面是rails中的增加步骤:

1. Gemfile中
gem 'kaminari'
2. config/routes.rb
  namespace "monitor" do
    resources "logs"
  end 
3. app/controllers/monitor/logs_controller.rb :
class Monitor::LogsController < ApplicationController
  def index
    @logs = OperationLog.order('created_at desc').page(params[:page]).per(100)
  end
end
4. app/views/monitor/logs/index.hml.erb:
<h3>操作日志</h3>
<%= paginate @logs %> 
<table >
  <tr>
    <th>controller</th>
    <th>action</th>
    <th>时间</th>
    <th>用户名</th>
    <th>详情</th>
  </tr>
  <% @logs.each do |log| %>
  <tr>
    <td><%= log.controller %></td>
    <td><%= log.action %></td>
    <td><%= log.created_at.strftime '%y-%m-%d %H:%M:%S' %></td>
    <td><%= log.user_name %></td>
    <td><%= log.params %></td>
  </tr>
  <% end %>
    
</table>
<%= paginate @logs %>

5. lib/loggable_controller:

module LoggableController
  def save_log
    controller = params[:controller]
    action = params[:action]
    request_type = restful_method(params)
    OperationLog.create!(:action => action, :controller => controller,
        :user_name => current_user.try(:email),
        :parameters =>  params.inspect,
        :remote_ip=> request.remote_ip,
        :restful_method => restful_method(params)
    )   
  end 

  private

  # return: get, post, put or delete
  def restful_method(params)
    return request.method.downcase
    #params[:authenticity_token].blank? ? 'get' : ((params[:_method]) || 'post')
  end
end
6. 然后,在 app/controller/application_controller 中: 

class ApplicationController < ActionController::Base
  include LoggableController
  before_filter :save_log
end
7. 在 config/initializers/loggable_controller.rb中:
Dir[Rails.root + 'lib/loggable_controller.rb'].each do |file|
  require file
end

8 . 创建 logs表:

class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t| 
      t.string :controller
      t.string :action
      t.string :user_name
      t.text :parameters
      t.datetime :created_at
    end 
  end 
end

9. 创建 app/models/log.rb

# -*- encoding : utf-8 -*-
class Log < ActiveRecord::Base
end
10. 创建 migration $ bundle exec rails g migration create_operation_logs

class CreasteOperationLogs < ActiveRecord::Migration
  def change
    create_table :operation_logs, :comment => '操作日志表' do |t|
      t.string :controller
      t.string :action
      t.string :remote_ip, :comment => '远程ip'
      t.string :restful_method, :comment => '请求的方法,  get/post...'
      t.string :user_name, :comment => '当前用户'
      t.text :parameters, :comment => '各种参数'
      t.datetime :created_at, :comment => '创建时间'
    end
  end
end





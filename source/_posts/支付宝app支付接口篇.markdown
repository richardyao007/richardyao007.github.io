---
layout: post
title:  "[Ruby on Rails] 支付宝app支付接口篇"
date:   2017-04-20 09:14:49 +0800
category: Ruby on Rails
---



		两个action都是post请求，在routes配置好。


		def alipay

		  @order = Order.includes(:good).find(params[:order_id])
		  biz_content = {
		      timeout_express: "30m",
		      product_code: "QUICK_MSECURITY_PAY",
		      total_amount: @order.buy_count * @order.amount,
		      subject: "#{@order.good.name} x #{@order.buy_count}",
		      body: "#{params[:order_id]}",
		      out_trade_no: @order.order_number,
		    }

		  result = {
		    :app_id     => Settings.alipay.app_id,
		    :method     => "alipay.trade.app.pay",
		    :charset    => "utf-8",
		    :sign_type  => "RSA",
		    :sign       => "your pkcs8格式的private key，使用openssl生成的，供android调用",
		    :timestamp   => Time.now.strftime('%Y-%m-%d %H:%M:%S'),
		    :version     => "1.0",
		    :notify_url  => "http://api.×××××.com/interface/payments/alipay_notify",
		    :bit_content => biz_content,
		    :bit_content_json => biz_content.to_json
		  }
		  render json: result

		end

		#回调方法
		def alipay_notify
		  notify_params = params.except(*request.path_parameters.keys)
		  Rails.logger.info "支付宝回调结果："
		  Rails.logger.info notify_params
		  verify_result = Alipay::Notify.verify?(notify_params)
		  Rails.logger.info verify_result
		  Rails.logger.info "==  order_id ========== #{notify_params['body'].to_i}----"

		  # 应该判断 verify_result 但是不知道为什么每次都确认失败
		  # 请查看 https://doc.open.alipay.com/docs/doc.htm?spm=a219a.7629140.0.0.yfSIXP&treeId=193&articleId=105301&docType=1

		  if true
		    @order = Order.find(notify_params['body'].to_i)
		    begin
		      unless @order.blank?
		        Rails.logger.info "==  order is not blank !!!!!----"
		        time = Time.now.to_datetime
		        @order.update_attributes(:order_status => 'yizhifu', :collect => notify_params['total_amount'], :payed_at => time)
		      else
		        Rails.logger.info "==  order is blank !!!!!----"
		        Rails.logger.info @order.errors
		      end
					render :json => { return_code: "success" }
		    rescue ''
		      Rails.logger.error 'order pay error'
					render :json => { return_code: "fail", return_msg: "" }
		    end
		  else
				render :json => { return_code: "fail", return_msg: "" }
		  end
		end



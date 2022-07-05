---
layout: post
title:  "[Ruby On Rails] app微信支付Ruby on Rails接口篇"
date:   2017-03-15 09:14:49 +0800
category: Ruby On Rails
---




		使用gem 'wx_pay'


		payments_controller


		def information

			trade_type = params[:trade_type]
			WxPay.appid = Settings.wx_pay.android_and_ios.appid
			WxPay.key = Settings.wx_pay.android_and_ios.key
			WxPay.mch_id = Settings.wx_pay.android_and_ios.mch_id

			#开启调试模式
			WxPay.debug_mode = true

			Rails.logger.info "trade_type===#{trade_type}"
			Rails.logger.info "appid===#{Settings.wx_pay.android_and_ios.appid}"
			Rails.logger.info "key===#{Settings.wx_pay.android_and_ios.key}"
			Rails.logger.info "mch_id===#{Settings.wx_pay.android_and_ios.mch_id}"

			fee = params[:fee]
			order_sn = params[:order_sn]

			# 订单号, 需要每次都要变化.
			@order = Order.includes(:good).find(params[:order_id])

			payment_params = {
				body: "商品名称: #{@order.good.name}, 总价: #{fee}元",
				out_trade_no: order_sn,
				# 单位是 分, 所以要 乘以 100
				total_fee: (fee.to_f * 100).to_i,

				# 我们服务器的 IP
				spbill_create_ip: Settings.wx_pay.spbill_create_ip,
				# 微信服务器 在支付成功后, 调用我们服务器的接口, 来告诉我们.
				notify_url: Settings.wx_pay.notify_url,
				trade_type: trade_type, #'JSAPI', # could be "JSAPI", "NATIVE" or "APP",
				# 用户的open id
				#openid: params[:open_id]  # 当支付方式是 公众号内支付的时候, 用这个.
			}
			Rails.logger.info "== payment_params: #{payment_params.inspect}"

			# 第一次访问微信服务器, 主要目的是获取 prepay_id, 在这个r 中,  r['prepay_id'] 就是微信返回的值

			r = WxPay::Service.invoke_unifiedorder payment_params

			Rails.logger.info "== information-: #{r.inspect}"

			# 准备为第二次 访问 微信服务器做准备.
			if r.success? # => true
				@order.update_attribute('collect', fee)
				temp_return_code =  r["return_code"]
				temp_return_msg =  r["return_msg"]


				params_for_app = {
				  prepayid: r['prepay_id'],
				  noncestr: SecureRandom.uuid.tr('-', '')
				}

				# 第二次访问 微信服务器, 获取 app 支付所需要的参数:
				# 臭名昭著的 sign 问题就是在这个方法中被解决( 应该是还需要把sign 重新生成一遍)
				# 多亏有这个gem, 我们不必顾虑这个问题了.
				#

				r = WxPay::Service.generate_app_pay_req params_for_app

				Rails.logger.info "==== generate_app_pay_req : #{r.inspect}"

				result = {
				  appId: r[:appid],
				  partnerid: r[:partnerid],
				  prepay_id: r[:prepayid],
				  package: r[:package],
				  timeStamp: r[:timestamp],
				  nonceStr: r[:noncestr],
				  return_code: temp_return_code,  # 这个参数没太大用. 我们项目使用而已.
				  return_msg: temp_return_msg,# 这个参数没太大用. 我们项目使用而已.
				  sign: r[:sign],
				  order_id: @order.id
				}
			else
				result = { return_code: r["return_code"], return_msg: r["return_msg"], result_code: r["result_code"], err_code: r["err_code"], err_code_des: r["err_code_des"] }
			end

			Rails.logger.info "== 最终返回给app的结果 final_result :--#{result.inspect}-------"

			render json: result
		end

		def notify
			logger.info "== notify from weixin server: "
			logger.info params.inspect
			logger.info "== notify from weixin server( done ) : "

			# 请求是由 微信服务器 发送过来.
			result = Hash.from_xml(request.body.read)["xml"]

			Rails.logger.info "----notify-----result------#{result}-------"
			if WxPay::Sign.verify?(result)
				order_number = result["out_trade_no"].to_s
				logger.info "==  sign verified"
				Rails.logger.info "---------order_no------#{result["out_trade_no"]}-------"
				@order = Order.find_by_order_number(order_number)
				logger.info "==  #{@order.inspect} order !!!!!----"
				unless @order.blank?
				  logger.info "==  order is not blank !!!!!----"
				  time = Time.now.to_datetime
				  @order.update_attributes(:order_status => 'yizhifu', :collect => result["total_fee"], :payed_at => time)
				end
				render :xml => { return_code: "SUCCESS" }.to_xml(root: 'xml', dasherize: false)
			else
				logger.error "==  sign NOT verified"
				render :xml => { return_code: "FAIL", return_msg: "" }.to_xml(root: 'xml', dasherize: false)
			end
		end

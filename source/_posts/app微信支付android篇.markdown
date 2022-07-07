---
layout: post
title:  "[android] app微信支付android篇"
date:   2017-03-15 09:14:49 +0800
category: android
---


h5上需要提供一个javascript方法 ：

      global_function_weixin_pay = function () {
        return 'http://api.****.com/interface/payments/information?' + 'order_id=' + that.order.order_id + '&fee=' + that.order.amount + '&order_sn=' + that.order.order_number + '&trade_type=APP'
      }



/*********************************购买商品的activity**************************************/

    private String translateHtmlStringToLocal(String value) {
        return value.replace("\"", "");
    }

    public class shopShowWebViewClient extends WebViewClient {

        @TargetApi(Build.VERSION_CODES.KITKAT)
        @Override
        public boolean shouldOverrideUrlLoading(WebView view, String url) {
            Log.d(TAG, "ShopShowActivity shouldOverrideUrlLoading====" + url);
            //微信支付，h5请求的地址必须是带域名的
            Pattern pattern = Pattern.compile("http://h5.shangyunyijia.com/run_native_pay");
            Matcher matcher = pattern.matcher(url);
            if (matcher.find()) {
                Log.d(TAG, "微信开始支付");
                shopShowWebView.evaluateJavascript("global_function_weixin_pay()", new ValueCallback<String>() {
                    @Override
                    public void onReceiveValue(String value) {
                        Log.d(TAG, "global_function_weixin_pay value=" + value);
                        if (!value.contains("null") && !value.contains("NULL")) {
                            String payUrl = translateHtmlStringToLocal(value);
                            getPayInfoFromServer(payUrl);
                        }
                    }
                });
                return true;
            }

            view.loadUrl(url);

            return false;
        }

        @Override
        public void onPageFinished(WebView view, String url) {
            super.onPageFinished(view, url);

            Log.d(TAG, "onPageFinished, 触发的url是====" + url);

            Log.d(TAG, "取消小菊花开始...");
            // 取消小菊花 放在这里才可以.   针对myorder  打开的时候小菊花不会消失。
            try {
                dismissLoadingDialog();
            } catch (Exception e) {
                try {
                    dismissLoadingDialog();
                } catch (Exception e2) {
                    Log.e(TAG, "== 取消小菊花出错了: " + e.toString());
                }
            }
        }
    }



    /**
     * 微信获取支付信息
     * @param payUrl
     */
    public void getPayInfoFromServer(final String payUrl) {

        if (this != null) {
            this.showLoadingDialog();
        }

        com.lidroid.xutils.HttpUtils http = new com.lidroid.xutils.HttpUtils();
        http.send(HttpRequest.HttpMethod.GET,
                payUrl,
                null,
                new RequestCallBack<String>() {
                    @Override
                    public void onSuccess(ResponseInfo<String> responseInfo) {

                        if (ShopShowActivity.this != null) {
                            ShopShowActivity.this.dismissLoadingDialog();
                        }

                        if (responseInfo != null && responseInfo.result != null) {

                            WeiXinPayBean weiXinPayBean = JSON.parseObject(responseInfo.result, WeiXinPayBean.class);
                            Log.d(TAG, "ShopShowActivity=== getPayInfoFromServer() =========onSuccess(ResponseInfo<String> responseInfo)" + weiXinPayBean.getReturn_code().toUpperCase());

                            if (weiXinPayBean.getReturn_code().toUpperCase().equals("SUCCESS")) {
                                WXPayEntryActivity.show(ShopShowActivity.this, weiXinPayBean, REQUEST_WEIXIN_PAY);
//                                Intent intent = new Intent(ShopShowActivity.this, WXPayEntryActivity.class);
//                                intent.putExtra("weiXinPayBean", weiXinPayBean);
//                                startActivityForResult(intent, REQUEST_WEIXIN_PAY);

                                //WXPayEntryActivity.show(OrderPaySuccessFragment.newInstance(pageUrl, "支付成功", true), weiXinPayBean, REQUEST_WEIXIN_PAY);
                            } else {
                                Toast.makeText(ShopShowActivity.this, weiXinPayBean.getErr_code_des(), Toast.LENGTH_SHORT).show();
                            }
                        } else {
                            Toast.makeText(ShopShowActivity.this, "获取支付信息失败", Toast.LENGTH_SHORT).show();
                        }
                    }

                    @Override
                    public void onFailure(HttpException e, String s) {
                        Log.d(TAG, "=========onFailure(HttpException e, String s)" + s + "============" + e.toString());
                        e.printStackTrace();
                    }
                });
    }


/**********************************微信支付javabean******************************************/

		package com.***;

		import com.alibaba.fastjson.annotation.JSONField;

		import java.io.Serializable;

		public class WeiXinPayBean implements Serializable {

				private String appId;
				private String partnerid;
				private String prepay_id;
				private String order_id;
				@JSONField(name="package")
				private String packageX;
				private String timeStamp;
				private String nonceStr;
				private String return_code;
				private String return_msg;
				private String sign;
				private String err_code_des;

				public String getAppId() {
				    return appId;
				}

				public void setAppId(String appId) {
				    this.appId = appId;
				}

				public String getPartnerid() {
				    return partnerid;
				}

				public void setPartnerid(String partnerid) {
				    this.partnerid = partnerid;
				}

				public String getPrepay_id() {
				    return prepay_id;
				}

				public void setPrepay_id(String prepay_id) {
				    this.prepay_id = prepay_id;
				}

				public void setOrder_id(String order_id) {
				    this.order_id = order_id;
				}

				public String getOrder_id() {
				    return order_id;
				}

				public String getPackageX() {
				    return packageX;
				}

				public void setPackageX(String packageX) {
				    this.packageX = packageX;
				}

				public String getTimeStamp() {
				    return timeStamp;
				}

				public void setTimeStamp(String timeStamp) {
				    this.timeStamp = timeStamp;
				}

				public String getNonceStr() {
				    return nonceStr;
				}

				public void setNonceStr(String nonceStr) {
				    this.nonceStr = nonceStr;
				}

				public String getReturn_code() {
				    return return_code;
				}

				public void setReturn_code(String return_code) {
				    this.return_code = return_code;
				}

				public String getReturn_msg() {
				    return return_msg;
				}

				public void setReturn_msg(String return_msg) {
				    this.return_msg = return_msg;
				}

				public String getSign() {
				    return sign;
				}

				public void setSign(String sign) {
				    this.sign = sign;
				}

				public String getErr_code_des() {
				    return err_code_des;
				}

				public void setErr_code_des(String err_code_des) {
				    this.err_code_des = err_code_des;
				}
		}


/**********************************微信支付activity, 必须放在wxapi目录下******************************************/

		package com.***.wxapi;

		import android.app.Activity;
		import android.content.Context;
		import android.content.Intent;
		import android.os.Bundle;
		import android.support.v4.app.Fragment;
		import android.util.Log;
		import android.widget.Toast;

		import com.syyj.PageUrls;
		import com.syyj.R;
		import com.syyj.WeiXinPayBean;
		import com.syyj.shop.PayFailActivity;
		import com.syyj.shop.PaySuccessActivity;
		import com.tencent.mm.sdk.constants.ConstantsAPI;
		import com.tencent.mm.sdk.modelbase.BaseReq;
		import com.tencent.mm.sdk.modelbase.BaseResp;
		import com.tencent.mm.sdk.modelpay.PayReq;
		import com.tencent.mm.sdk.openapi.IWXAPI;
		import com.tencent.mm.sdk.openapi.IWXAPIEventHandler;
		import com.tencent.mm.sdk.openapi.WXAPIFactory;

		public class WXPayEntryActivity extends Activity implements IWXAPIEventHandler{

			private static final String PAY_SUCCESS_URL = PageUrls.BASE_URL + "/shop/paysuccess/";
			private static final String PAY_FAIL_URL = PageUrls.BASE_URL + "/shop/payfail/";

			private WeiXinPayBean weiXinPayBean;

			public static void show(Activity activity, WeiXinPayBean weiXinPayBean, int requestCode) {
				Intent intent = new Intent(activity, WXPayEntryActivity.class);
				intent.putExtra("weiXinPayBean", weiXinPayBean);
				activity.startActivityForResult(intent, requestCode);
			}
			public static void show(Fragment fragment, WeiXinPayBean weiXinPayBean, int requestCode) {
				Intent intent = new Intent(fragment.getActivity(), WXPayEntryActivity.class);
				intent.putExtra("weiXinPayBean", weiXinPayBean);
				fragment.startActivityForResult(intent, requestCode);
			}

			private static final String TAG = "WXPayEntryActivity";

			private IWXAPI api;

			@Override
			public void onCreate(Bundle savedInstanceState) {
				super.onCreate(savedInstanceState);
				setContentView(R.layout.pay_result);

				weiXinPayBean = (WeiXinPayBean) getIntent().getSerializableExtra("weiXinPayBean");
				api = WXAPIFactory.createWXAPI(getApplicationContext(), weiXinPayBean.getAppId());
				if (weiXinPayBean != null) {
					api = WXAPIFactory.createWXAPI(getApplicationContext(), weiXinPayBean.getAppId());
					pay(this, weiXinPayBean);
				} else {
					api = WXAPIFactory.createWXAPI(getApplicationContext(), weiXinPayBean.getAppId());
					api.handleIntent(getIntent(), this);
				}

			}

			@Override
			protected void onNewIntent(Intent intent) {
				super.onNewIntent(intent);
				setIntent(intent);
				api.handleIntent(intent, this);
			}

			@Override
			public void onReq(BaseReq baseReq) {

			}

			@Override
			public void onResp(BaseResp resp) {
				Log.d(TAG, "WXPayEntryActivity onResp, errCode = " + resp.errCode);

				Log.d(TAG, "WXPayEntryActivity onResp, getType = " + resp.getType());

				Log.d(TAG, "WXPayEntryActivity onResp, COMMAND_PAY_BY_WX = " + ConstantsAPI.COMMAND_PAY_BY_WX);

				if (resp.getType() == ConstantsAPI.COMMAND_PAY_BY_WX) {
					// errCode: 0 成功， -1 支付失败， -2 用户取消支付

					if (resp.errCode == 0)  {
						setResult(RESULT_OK);
						Toast.makeText(this, "支付成功", Toast.LENGTH_SHORT).show();

						Intent intent = new Intent(WXPayEntryActivity.this, PaySuccessActivity.class);
						intent.putExtra("id", weiXinPayBean.getOrder_id());
						startActivity(intent);
		//				WebViewActivity.show(WXPayEntryActivity.this, PAY_SUCCESS_URL+weiXinPayBean.getOrder_id(), "支付成功", WebViewActivity.FRAGMENT_ORDER_PAY_SUCCESS, true);
						finish();
					} else {
		//                AlertDialog.Builder builder = new AlertDialog.Builder(this);
		//                builder.setTitle("支付结果");
		//                builder.setMessage(String.valueOf(resp.errCode));
		//                builder.show();
		//                setResult(RESULT_CANCELED);
		//				WebViewActivity.show(WXPayEntryActivity.this, PAY_FAIL_URL+weiXinPayBean.getOrder_id(), "支付失败", WebViewActivity.FRAGMENT_ORDER_PAY_FAIL, true);

						Intent intent = new Intent(WXPayEntryActivity.this, PayFailActivity.class);
						intent.putExtra("id", weiXinPayBean.getOrder_id());
						startActivity(intent);
						finish();
					}
				}
			}


			public void pay(Context context, WeiXinPayBean weiXinPayBean) {
				final IWXAPI msgApi = WXAPIFactory.createWXAPI(context, null);
				// 将该app注册到微信
				msgApi.registerApp(weiXinPayBean.getAppId());

				PayReq request = new PayReq();
				request.appId = weiXinPayBean.getAppId();
				request.partnerId = weiXinPayBean.getPartnerid();
				request.prepayId= weiXinPayBean.getPrepay_id();
				request.packageValue = weiXinPayBean.getPackageX();
				request.nonceStr= weiXinPayBean.getNonceStr();
				request.timeStamp= weiXinPayBean.getTimeStamp();
				request.sign= weiXinPayBean.getSign();
				boolean sendSuccess = msgApi.sendReq(request);
				// 和微信交互可能失败, 失败时直接返回
				if (!sendSuccess) {
					finish();
				}
			}
		}

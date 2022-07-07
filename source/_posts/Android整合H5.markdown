---
layout: post
title:  "[Android]整合H5的WebView(微信支付，支付宝支付)"
date:   2016-10-19 09:14:49 +0800
category: Android
---

Android整合H5(vuejs)



1. Javascript命名规范以及调用需要注意的方法。



1.1 往往定义的共用(移动端[android])函数，都是在index.html中定义的



1.1.1 android对javascript的命名有一定要求

  函数定义，某个页面的某个动作的函数

  (举例：用户信息页面的新建函数=> create_user_page() [当然，不是说必须这样命名，  这样命名的好处是，一看就明白是什么意思了]

      不要写成: window.create_user_page() 或者: window.user.create_user_page()这样写的话，android不认识。会报出：ReferenceError  这样的错误而导致页面显示空白)



1.2 需要get_title() function，获取标题栏文字

　　由于个别标题是动态获取到的，例如：产品名称：西红柿炒蛋，这个是根据传递的产品id请求后端interface得到的。所以，需要等待javascript执行完毕后才可以获取到，不然，会出现问题。(ReferenceError: get_title() is not defined)



1.3 个别的h5页面提交或者保存按钮是在右上角，针对这种情况的处理方法

左上角一般情况下都是 > 返回按钮。所以，新建页面肯定需要，create_function()，编辑页面需要update_function()

  这里需要注意的就是：



     1.3.1 请一定要有返回值

这样才可以完成android和h5的一个交互的过程，不然，android无法得知是否成功。



     1.3.2 这种函数都需要发送ajax请求，所以在返回值的写法上一定要注意

赋值需要写在callback中，或者请求方式改为同步请求，这个我相信懂web端都知道。



1.4 android调用h5端javascript一般的写法：

    webview.evaluateJavascript("getPayOrderId()", new ValueCallback<String>() {

        @Override

        public void onReceiveValue(String value) {

            Log.d(TAG, "getPayOrderId value=" + value);

            if(!value.contains("null") && !value.contains("NULL")) {



          //这句用于调试

                Log.d(TAG, "运行到了这里getPayOrderId()" + value);

                orderId =  value;



            }

        }});

1.5 往往一个操作对应一个Activity或者一个Fragment，这个一定不要偷懒

2.关于集成微信支付

2.1 添加javabean:

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



2.2 添加Activity:

    public class WXPayEntryActivity extends Activity implements IWXAPIEventHandler{



       public static final String BASE_URL = "http://h5.touring.com.cn/#!";

       private static final String PAY_SUCCESS_URL = BASE_URL + "/orders/paysuccess/";

       private static final String PAY_FAIL_URL = BASE_URL + "/orders/payfail/";



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

            api = WXAPIFactory.createWXAPI(getApplicationContext(), AppCenter.getInstance().WeiXinPayAppId);

          if (weiXinPayBean != null) {

                AppCenter.getInstance().setWeiXinPayAppId(weiXinPayBean.getAppId());

                api = WXAPIFactory.createWXAPI(getApplicationContext(), AppCenter.getInstance().WeiXinPayAppId);

             pay(this, weiXinPayBean);

          } else {

                api = WXAPIFactory.createWXAPI(getApplicationContext(), AppCenter.getInstance().WeiXinPayAppId);

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

       public void onReq(BaseReq req) {

       }



       @Override

       public void onResp(BaseResp resp) {

          Log.d(TAG, "onPayFinish, errCode = " + resp.errCode);



          if (resp.getType() == ConstantsAPI.COMMAND_PAY_BY_WX) {

             // errCode: 0 成功， -1 支付失败， -2 用户取消支付



             if (resp.errCode == 0)  {

                setResult(RESULT_OK);

                Toast.makeText(this, "支付成功", Toast.LENGTH_SHORT).show();



                WebViewActivity.show(WXPayEntryActivity.this, PAY_SUCCESS_URL+weiXinPayBean.getOrder_id(), "支付成功", WebViewActivity.FRAGMENT_ORDER_PAY_SUCCESS, true);

                finish();

             } else {

    //                AlertDialog.Builder builder = new AlertDialog.Builder(this);

    //                builder.setTitle("支付结果");

    //                builder.setMessage(String.valueOf(resp.errCode));

    //                builder.show();

    //                setResult(RESULT_CANCELED);

                WebViewActivity.show(WXPayEntryActivity.this, PAY_FAIL_URL+weiXinPayBean.getOrder_id(), "支付失败", WebViewActivity.FRAGMENT_ORDER_PAY_FAIL, true);

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

2.3 修改android拦截部分的代码:



    //微信支付  global_function_weixin_pay()  是在h5上完成的微信支付方法

    Pattern pattern = Pattern.compile("run_native_pay");

    Matcher matcher = pattern.matcher(url);

    Log.d(TAG, "===== url=================== value=" + url);

    if (matcher.find()) {

        Log.d(TAG, "confirm order 微信开始支付");

        webview.evaluateJavascript("global_function_weixin_pay()", new ValueCallback<String>() {

            @Override

            public void onReceiveValue(String value) {

                Log.d(TAG, "global_function_weixin_pay value=" + value);

                if(!value.contains("null") && !value.contains("NULL")) {

                    String payUrl = translateHtmlStringToLocal(value);

                    getPayInfoFromServer(payUrl);

                }

            }});



        return true;

    }



2.4 微信获取支付信息



    com.lidroid.xutils.HttpUtils http = new com.lidroid.xutils.HttpUtils();

    http.send(HttpRequest.HttpMethod.GET,

            payUrl,

            null,

            new RequestCallBack<String>() {

                @Override

                public void onSuccess(ResponseInfo<String> responseInfo) {



                    if (getActivity() != null) {

                        ((TulingBaseActivity) getActivity()).dismissLoadingDialog();

                    }

                    if (responseInfo != null && responseInfo.result != null) {



                        WeiXinPayBean weiXinPayBean = JSON.parseObject(responseInfo.result, WeiXinPayBean.class);

                        Log.d(TAG, "=========onSuccess(ResponseInfo<String> responseInfo)" + weiXinPayBean.getReturn_code().toUpperCase());



                        if (weiXinPayBean.getReturn_code().toUpperCase().equals("SUCCESS")) {

                            WXPayEntryActivity.show(ConfirmOrderFragment.this, weiXinPayBean, REQUEST_WEIXIN_PAY);

                            //WXPayEntryActivity.show(OrderPaySuccessFragment.newInstance(pageUrl, "支付成功", true), weiXinPayBean, REQUEST_WEIXIN_PAY);

                        } else {

                            Toast.makeText(getActivity(), weiXinPayBean.getErr_code_des(), Toast.LENGTH_SHORT).show();

                        }

                    } else {

                        if (getActivity() != null) {

                            Toast.makeText(getActivity(), "获取支付信息失败", Toast.LENGTH_SHORT).show();

                        }

                    }

                }



                @Override

                public void onFailure(HttpException e, String s) {

                    Log.d(TAG, "=========onFailure(HttpException e, String s)" + s + "============" + e.toString());



                    if (getActivity() != null) {

                        ((TulingBaseActivity) getActivity()).dismissLoadingDialog();

                    }

                    e.printStackTrace();

                }

            });



3.关于集成支付宝支付

参照：　

    [https://doc.open.alipay.com/docs/doc.htm?spm=a219a.7629140.0.0.fBvhyw&treeId=193&articleId=105296&docType=1][https://doc.open.alipay.com/docs/doc.htm?spm=a219a.7629140.0.0.fBvhyw&treeId=193&articleId=105296&docType=1]

3.1 添加javabean:

    public class AlipayBean {

        /** 支付宝支付业务：入参app_id */

        private String app_id;

        private Map<String, String> biz_content;

        private String bit_content_json;

        private String method;

        private String charset;

        private String sign_type;

        /** 商户私钥，pkcs8格式 */

        private String sign;



        private String timestamp;

        private String version;

        private String notify_url;



        public String getApp_id() {

            return app_id;

        }



        public void setApp_id(String app_id) {

            this.app_id = app_id;

        }



        public Map<String, String> getBiz_content() {

            return biz_content;

        }



        public void setBiz_content(Map<String, String> biz_content) {

            this.biz_content = biz_content;

        }



        public String getBit_content_json() {

            return bit_content_json;

        }



        public void setBit_content_json(String bit_content_json) {

            this.bit_content_json = bit_content_json;

        }



        public String getMethod() {

            return method;

        }



        public void setMethod(String method) {

            this.method = method;

        }



        public String getCharset() {

            return charset;

        }



        public void setCharset(String charset) {

            this.charset = charset;

        }



        public String getSign_type() {

            return sign_type;

        }



        public void setSign_type(String sign_type) {

            this.sign_type = sign_type;

        }



        public String getSign() {

            return sign;

        }



        public void setSign(String sign) {

            this.sign = sign;

        }



        public String getTimestamp() {

            return timestamp;

        }



        public void setTimestamp(String timestamp) {

            this.timestamp = timestamp;

        }



        public String getVersion() {

            return version;

        }



        public void setVersion(String version) {

            this.version = version;

        }



        public String getNotify_url() {

            return notify_url;

        }



        public void setNotify_url(String notify_url) {

            this.notify_url = notify_url;

        }
    }



3.2 添加util:

    public class OrderInfoUtil2_0 {



       /**

        * 构造授权参数列表

        *

        * @param pid

        * @param app_id

        * @param target_id

        * @return

        */

       public static Map<String, String> buildAuthInfoMap(String pid, String app_id, String target_id) {

          Map<String, String> keyValues = new HashMap<String, String>();



          // 商户签约拿到的app_id，如：2013081700024223

          keyValues.put("app_id", app_id);



          // 商户签约拿到的pid，如：2088102123816631

          keyValues.put("pid", pid);



          // 服务接口名称， 固定值

          keyValues.put("apiname", "com.alipay.account.auth");



          // 商户类型标识， 固定值

          keyValues.put("app_name", "mc");



          // 业务类型， 固定值

          keyValues.put("biz_type", "openservice");



          // 产品码， 固定值

          keyValues.put("product_id", "APP_FAST_LOGIN");



          // 授权范围， 固定值

          keyValues.put("scope", "kuaijie");



          // 商户唯一标识，如：kkkkk091125

          keyValues.put("target_id", target_id);



          // 授权类型， 固定值

          keyValues.put("auth_type", "AUTHACCOUNT");



          // 签名类型

          keyValues.put("sign_type", "RSA");



          return keyValues;

       }



       /**

        * 构造支付订单参数列表

        */

       public static Map<String, String> buildOrderParamMap(AlipayBean alipayBean) {

          Map<String, String> keyValues = new HashMap<String, String>();



          keyValues.put("app_id", alipayBean.getApp_id());



          Log.d("OrderInfoUtil2_0", alipayBean.getBit_content_json());



          keyValues.put("biz_content", alipayBean.getBit_content_json());



          keyValues.put("charset", alipayBean.getCharset());



          keyValues.put("method", alipayBean.getMethod());



          keyValues.put("sign_type", alipayBean.getSign_type());



          Log.d("OrderInfoUtil2_0", "===========curDate=======" + alipayBean.getTimestamp());

          keyValues.put("timestamp", alipayBean.getTimestamp());

    //

          keyValues.put("version", alipayBean.getVersion());



    //    keyValues.put("timestamp", "2016-07-29 16:55:53");



    //    keyValues.put("version", "1.0");



          Log.d("OrderInfoUtil2_0", "notify_url===========" + alipayBean.getNotify_url());



          keyValues.put("notify_url", alipayBean.getNotify_url());



          return keyValues;

       }



       /**

        * 构造支付订单参数信息

        *

        * @param map

        * 支付订单参数

        * @return

        */

       public static String buildOrderParam(Map<String, String> map) {

          List<String> keys = new ArrayList<String>(map.keySet());

          //这句是后来添加的

          Collections.sort(keys);



          StringBuilder sb = new StringBuilder();

          for (int i = 0; i < keys.size() - 1; i++) {

             String key = keys.get(i);

             String value = map.get(key);

             sb.append(buildKeyValue(key, value, true));

             sb.append("&");

          }



          String tailKey = keys.get(keys.size() - 1);

          String tailValue = map.get(tailKey);

          sb.append(buildKeyValue(tailKey, tailValue, true));



          return sb.toString();

       }



       /**

        * 拼接键值对

        *

        * @param key

        * @param value

        * @param isEncode

        * @return

        */

       private static String buildKeyValue(String key, String value, boolean isEncode) {

          StringBuilder sb = new StringBuilder();

          sb.append(key);

          sb.append("=");

          if (isEncode) {

             try {

                sb.append(URLEncoder.encode(value, "UTF-8"));

             } catch (UnsupportedEncodingException e) {

                sb.append(value);

             }

          } else {

             sb.append(value);

          }

          return sb.toString();

       }



       /**

        * 对支付参数信息进行签名

        *

        * @param map

        * 待签名授权信息

        *

        * @return

        */

       public static String getSign(Map<String, String> map, String rsaKey) {

          List<String> keys = new ArrayList<String>(map.keySet());

          // key排序

          Collections.sort(keys);



          Log.d("OrderInfoUtil2_0", "===========================sort keys.toString()============" + keys.toString());



          StringBuilder authInfo = new StringBuilder();

          for (int i = 0; i < keys.size() - 1; i++) {

             String key = keys.get(i);

             String value = map.get(key);

             authInfo.append(buildKeyValue(key, value, false));

             authInfo.append("&");

          }



          String tailKey = keys.get(keys.size() - 1);

          String tailValue = map.get(tailKey);

          authInfo.append(buildKeyValue(tailKey, tailValue, false));



          String oriSign = SignUtils.sign(authInfo.toString(), rsaKey);

          String encodedSign = "";



          try {

             encodedSign = URLEncoder.encode(oriSign, "UTF-8");

          } catch (UnsupportedEncodingException e) {

             e.printStackTrace();

          }

          return "sign=" + encodedSign;

       }



       /**

        * 使用内部生成的订单号，不使用该方法生成了

        * 要求外部订单号必须唯一。

        * @return

        */

       private static String getOutTradeNo() {

          SimpleDateFormat format = new SimpleDateFormat("MMddHHmmss", Locale.getDefault());

          Date date = new Date();

          String key = format.format(date);



          Random r = new Random();

          key = key + r.nextInt();

          key = key.substring(0, 15);

          return key;

       }
    }



3.3 添加签名util:

    public class SignUtils {



        private static final String ALGORITHM = "RSA";



        private static final String SIGN_ALGORITHMS = "SHA1WithRSA";



        private static final String DEFAULT_CHARSET = "UTF-8";



        public static String sign(String content, String privateKey) {

            try {

                PKCS8EncodedKeySpec priPKCS8 = new PKCS8EncodedKeySpec(

                        Base64.decode(privateKey));

                KeyFactory keyf = KeyFactory.getInstance(ALGORITHM);

                PrivateKey priKey = keyf.generatePrivate(priPKCS8);



                java.security.Signature signature = java.security.Signature

                        .getInstance(SIGN_ALGORITHMS);



                signature.initSign(priKey);

                signature.update(content.getBytes(DEFAULT_CHARSET));



                byte[] signed = signature.sign();



                return Base64.encode(signed);

            } catch (Exception e) {

                e.printStackTrace();

            }



            return null;

        }



    }



3.4 获取支付信息，打开支付宝:



            Map<String, String> params = OrderInfoUtil2_0.buildOrderParamMap(alipayBean);

            String orderParam = OrderInfoUtil2_0.buildOrderParam(params);

            String sign = OrderInfoUtil2_0.getSign(params, alipayBean.getSign());

            final String payInfo = orderParam + "&" + sign;



            /**

             * 完整的符合支付宝参数规范的订单信息

             */

            Log.d(TAG, "==========payInfo=============" + payInfo);

            Runnable payRunnable = new Runnable() {

                @Override

                public void run() {

                    PayTask payTask = new PayTask(getActivity());

                    Map<String, String> result = payTask.payV2(payInfo, true);

                    Log.d(TAG, "=================result===" + result.toString());



                    Message msg = new Message();

                    msg.what = SDK_PAY_FLAG;

                    msg.obj = result;

                    handler.sendMessage(msg);

                }

            };



            Thread payThread = new Thread(payRunnable);

            payThread.start();









3.5 处理返回结果



// 判断resultStatus 为“9000”则代表支付成功，具体状态码代表含义可参考接口文档

if (TextUtils.equals(resultStatus, "9000")) {

    Toast.makeText(getActivity(), "支付成功", Toast.LENGTH_SHORT).show();

} else {

    // 判断resultStatus 为非"9000"则代表可能支付失败

    // "8000"代表支付结果因为支付渠道原因或者系统原因还在等待支付结果确认，最终交易是否成功以服务端异步通知为准（小概率状态）

    if (TextUtils.equals(resultStatus, "8000")) {

        Toast.makeText(getActivity(), "支付结果确认中", Toast.LENGTH_SHORT).show();

    } else {

        // 其他值就可以判断为支付失败，包括用户主动取消支付，或者系统返回的错误

        Toast.makeText(getActivity(), "支付失败", Toast.LENGTH_SHORT).show();

    }

}



3.6 关于支付宝后端接口的实现





3.6.1 首先将签名参数等信息需要放在接口端(即服务器端)

参照:

[https://doc.open.alipay.com/docs/doc.htm?spm=a219a.7629140.0.0.JMiXfS&treeId=193&articleId=105465&docType=1][https://doc.open.alipay.com/docs/doc.htm?spm=a219a.7629140.0.0.JMiXfS&treeId=193&articleId=105465&docType=1]



    def alipay

        @order = ShoppingOrder.find_by_id(params[:order_id])

        biz_content = {

            timeout_express: '30m',

            seller_id: '',

            product_code: "QUICK_MSECURITY_PAY",

            total_amount: @order.buy_couts * @order.shopping_product.price.to_f,

            subject: "#{@order.shopping_product.name} x #{@order.buy_couts}",

            body: "#{params[:order_id]}",

            out_trade_no: @order.order_number,

          }



        result = {

          :app_id      => YOURAPPID,

          :method      => 'alipay.trade.app.pay',

          :charset     => 'utf-8',

          :sign_type   => 'RSA',

          :sign        => YOURSIGN(商户私钥，pkcs8格式),

          :timestamp   => Time.now.strftime('%Y-%m-%d %H:%M:%S'),

          :version     => '1.0',

          :notify_url  => YOURNOTIFYURL,

          :bit_content => biz_content,

          :bit_content_json => biz_content.to_json

        }

        render json: result

    End



关于YOURSIGN, 即商户私钥的说明, 参照:

    https://doc.open.alipay.com/doc2/detail.htm?treeId=193&articleId=105310&docType=1#s0

使用OpenSSL工具生成的.





3.6.2 实现相应的回调地址action(即上面提到的notify_url)





    def alipay_notify

        notify_params = params.except(*request.path_parameters.keys)

        Rails.logger.info "支付宝回调结果："

        Rails.logger.info notify_params

        verify_result = Alipay::Notify.verify?(notify_params)

        Rails.logger.info verify_result

        Rails.logger.info "==  order_id ========== #{notify_params['body'].to_i}----"



            #判断返回结果

        if true

          @order = ShoppingOrder.find(notify_params['body'].to_i)

          begin

            unless @order.blank?

              Rails.logger.info "==  order is not blank !!!!!----"

              time = Time.now.to_datetime

              #修改相应的订单状态

              @order.update_attributes(:payment_status => 1, :order_status => 1, :collect => notify_params['total_amount'], :payed_at => time)

            else

              Rails.logger.info "==  order is blank !!!!!----"

              Rails.logger.info @order.errors

            end

                  render :json => { return_code: "success" }

          rescue ''

            Rails.logger.error 'shopping_order pay error'

                  render :json => { return_code: "fail", return_msg: "" }

          end

        else

                render :json => { return_code: "fail", return_msg: "" }

        end

    end

[https://doc.open.alipay.com/docs/doc.htm?spm=a219a.7629140.0.0.JMiXfS&treeId=193&articleId=105465&docType=1]: https://doc.open.alipay.com/docs/doc.htm?spm=a219a.7629140.0.0.JMiXfS&treeId=193&articleId=105465&docType=1
[https://doc.open.alipay.com/docs/doc.htm?spm=a219a.7629140.0.0.fBvhyw&treeId=193&articleId=105296&docType=1]: https://doc.open.alipay.com/docs/doc.htm?spm=a219a.7629140.0.0.fBvhyw&treeId=193&articleId=105296&docType=1
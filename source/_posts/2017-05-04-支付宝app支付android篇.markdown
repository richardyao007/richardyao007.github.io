---
layout: post
title:  "[android] 支付宝app支付android篇"
date:   2017-05-04 09:14:49 +0800
category: android
---

		/**********************************配置部分AndroidManifest.xml************************************/
		权限配置参考官网api文档

		<!-- alipay sdk begin -->
		<activity
				android:name="com.alipay.sdk.app.H5PayActivity"
				android:configChanges="orientation|keyboardHidden|navigation|screenSize"
				android:exported="false"
				android:screenOrientation="behind"
				android:windowSoftInputMode="adjustResize|stateHidden" >
		</activity>
		<activity
				android:name="com.alipay.sdk.app.H5AuthActivity"
				android:configChanges="orientation|keyboardHidden|navigation"
				android:exported="false"
				android:screenOrientation="behind"
				android:windowSoftInputMode="adjustResize|stateHidden" >
		</activity>

		<!-- alipay sdk end -->

		/**********************************支付部分************************************/

		h5需要实现一个function global_function_alipay_pay()返回请求接口的地址: http://api.***.com/interface/payments/alipay?order_id=1，
		点击支付请求***/zhi_fu_bao_pay

		//android拦截
		pattern = Pattern.compile("zhi_fu_bao_pay");
		matcher = pattern.matcher(url);
		if(matcher.find()) {
				Log.d(TAG, "confirm order 支付宝开始支付");
				shopShowWebView.evaluateJavascript("global_function_alipay_pay()", new ValueCallback<String>() {
					  @Override
					  public void onReceiveValue(String value) {
					      if(!value.contains("null") && !value.contains("NULL")) {
					          Log.d(TAG, "运行到了这里,开始支付宝支付=====" + value);
					          String payUrl = translateHtmlStringToLocal(value);

					          getAlipayInfoFromServer(payUrl);
					      }
					  }});
				return true;
		}

		/**
		 * 获取支付宝支付信息
		 * @param payUrl
		 * @return
		 */
		protected AlipayBean getAlipayInfoFromServer(final String payUrl) {

				final AlipayBean[] alipayBean = {new AlipayBean()};

				if (this != null) {
						this.showLoadingDialog();
				}
				com.lidroid.xutils.HttpUtils http = new com.lidroid.xutils.HttpUtils();
				http.send(HttpRequest.HttpMethod.POST,
							  payUrl,
							  null,
							  new RequestCallBack<String>() {
							      @Override
							      public void onSuccess(ResponseInfo<String> responseInfo) {

							          if (ShopShowActivity.this != null) {
							              ShopShowActivity.this.dismissLoadingDialog();
							          }
							          if (responseInfo != null && responseInfo.result != null) {
							              Log.d(TAG, "=========获取到的responseInfo.result为===" + responseInfo.result + "=========");
							              alipayBean[0] = JSON.parseObject(responseInfo.result, AlipayBean.class);

							              alipay(alipayBean[0]);
							          } else {
							              if (ShopShowActivity.this != null) {
							                  Toast.makeText(ShopShowActivity.this, "获取支付信息失败", Toast.LENGTH_SHORT).show();
							              }
							          }
							      }

							      @Override
							      public void onFailure(HttpException e, String s) {
							          Log.d(TAG, "=========onFailure(HttpException e, String s)" + s + "============" + e.toString());

							          if (ShopShowActivity.this != null) {
							              ShopShowActivity.this.dismissLoadingDialog();
							          }
							          e.printStackTrace();
							      }
							  });
				return alipayBean[0];
		}

		/**
		 * 支付宝支付方法
		 * @param alipayBean
		 */
		public void alipay(final AlipayBean alipayBean) {

				Map<String, String> params = OrderInfoUtil2_0.buildOrderParamMap(alipayBean);
				String orderParam = OrderInfoUtil2_0.buildOrderParam(params);
				String sign = OrderInfoUtil2_0.getSign(params, alipayBean.getSign());
		//        String sign = OrderInfoUtil2_0.getSign(params, RSA_PRIVATE);
				final String orderInfo = orderParam + "&" + sign;

				/**
				 * 完整的符合支付宝参数规范的订单信息
				 */
		//            final String payInfo = info + "&" + sign;

		//            PayTask alipay = new PayTask(getActivity());
		//            String result = alipay.pay(payInfo, true); // 调用支付接口进行支付

				Log.d(TAG, "==========orderInfo=============" + orderInfo);
				Runnable payRunnable = new Runnable() {
						@Override
						public void run() {

							  //for android 6.0
							  if (ActivityCompat.checkSelfPermission(ShopShowActivity.this, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
							      Log.d(TAG, "== in android 6.0, getting permission");
							      ActivityCompat.requestPermissions(ShopShowActivity.this, new String[]{Manifest.permission.READ_PHONE_STATE}, 1);
							  }

							  PayTask payTask = new PayTask(ShopShowActivity.this);
							  Map<String, String> result = payTask.payV2(orderInfo, true);

							  Log.d(TAG, "=================result===" + result.toString());

							  Message msg = new Message();
							  msg.what = SDK_PAY_FLAG;
							  msg.obj = result;
							  handler.sendMessage(msg);
						}
				};

				Thread payThread = new Thread(payRunnable);
				payThread.start();
		}

		/*
		 * 接收消息, 能触发对应的方法
		 */
		private Handler handler = new Handler() {
				@TargetApi(Build.VERSION_CODES.KITKAT)
				@Override
				public void handleMessage(Message msg) {
						switch (msg.what) {
							  case SDK_PAY_FLAG: {
							      Log.d(TAG, "======|||||||||||||||||||||..................");
							      Log.d(TAG, msg.obj.toString());

							      PayResult payResult = new PayResult((Map<String, String>) msg.obj);

							      /**
							       * 同步返回的结果必须放置到服务端进行验证，建议商户依赖异步通知
							       */
							      String resultInfo = payResult.getResult();// 同步返回需要验证的信息

							      Log.d(TAG, "=====alipay resultInfo====" + resultInfo);

							      final String resultStatus = payResult.getResultStatus();

							      Log.d(TAG, "=====alipay resultStatus====" + resultStatus);

							      shopShowWebView.evaluateJavascript("getPayOrderId()", new ValueCallback<String>() {
							          @Override
							          public void onReceiveValue(String value) {
							              Log.d(TAG, "getPayOrderId value=" + value);
							              if(!value.contains("null") && !value.contains("NULL")) {

							                  Log.d(TAG, "运行到了这里getPayOrderId()===支付的订单id为=========" + value);
							                  // 判断resultStatus 为“9000”则代表支付成功，具体状态码代表含义可参考接口文档
							                  if (TextUtils.equals(resultStatus, "9000")) {
							                      Toast.makeText(ShopShowActivity.this, "支付成功", Toast.LENGTH_SHORT).show();

							                      Intent intent = new Intent(ShopShowActivity.this, PaySuccessActivity.class);
							                      intent.putExtra("id", value);
							                      startActivity(intent);
							                      finish();
							                  } else {
							                      // 判断resultStatus 为非"9000"则代表可能支付失败
							                      // "8000"代表支付结果因为支付渠道原因或者系统原因还在等待支付结果确认，最终交易是否成功以服务端异步通知为准（小概率状态）
							                      if (TextUtils.equals(resultStatus, "8000")) {
							                          Toast.makeText(ShopShowActivity.this, "支付结果确认中", Toast.LENGTH_SHORT).show();
							                      } else {
							                          // 其他值就可以判断为支付失败，包括用户主动取消支付，或者系统返回的错误
							                          Toast.makeText(ShopShowActivity.this, "支付失败", Toast.LENGTH_SHORT).show();
							                      }
							                      Intent intent = new Intent(ShopShowActivity.this, PayFailActivity.class);
							                      intent.putExtra("id", value);
							                      startActivity(intent);
							                      finish();

							                  }
							              }
							          }});
							      break;
							  }
						}
				};
		};


		/**************************下面都是支付宝支付工具类****************************/
		package com.***.utils;

		public final class Base64 {

			private static final int BASELENGTH = 128;
			private static final int LOOKUPLENGTH = 64;
			private static final int TWENTYFOURBITGROUP = 24;
			private static final int EIGHTBIT = 8;
			private static final int SIXTEENBIT = 16;
			private static final int FOURBYTE = 4;
			private static final int SIGN = -128;
			private static char PAD = '=';
			private static byte[] base64Alphabet = new byte[BASELENGTH];
			private static char[] lookUpBase64Alphabet = new char[LOOKUPLENGTH];

			static {
				for (int i = 0; i < BASELENGTH; ++i) {
					base64Alphabet[i] = -1;
				}
				for (int i = 'Z'; i >= 'A'; i--) {
					base64Alphabet[i] = (byte) (i - 'A');
				}
				for (int i = 'z'; i >= 'a'; i--) {
					base64Alphabet[i] = (byte) (i - 'a' + 26);
				}

				for (int i = '9'; i >= '0'; i--) {
					base64Alphabet[i] = (byte) (i - '0' + 52);
				}

				base64Alphabet['+'] = 62;
				base64Alphabet['/'] = 63;

				for (int i = 0; i <= 25; i++) {
					lookUpBase64Alphabet[i] = (char) ('A' + i);
				}

				for (int i = 26, j = 0; i <= 51; i++, j++) {
					lookUpBase64Alphabet[i] = (char) ('a' + j);
				}

				for (int i = 52, j = 0; i <= 61; i++, j++) {
					lookUpBase64Alphabet[i] = (char) ('0' + j);
				}
				lookUpBase64Alphabet[62] = (char) '+';
				lookUpBase64Alphabet[63] = (char) '/';

			}

			private static boolean isWhiteSpace(char octect) {
				return (octect == 0x20 || octect == 0xd || octect == 0xa || octect == 0x9);
			}

			private static boolean isPad(char octect) {
				return (octect == PAD);
			}

			private static boolean isData(char octect) {
				return (octect < BASELENGTH && base64Alphabet[octect] != -1);
			}

			/**
			 * Encodes hex octects into Base64
			 *
			 * @param binaryData
			 *            Array containing binaryData
			 * @return Encoded Base64 array
			 */
			public static String encode(byte[] binaryData) {

				if (binaryData == null) {
					return null;
				}

				int lengthDataBits = binaryData.length * EIGHTBIT;
				if (lengthDataBits == 0) {
					return "";
				}

				int fewerThan24bits = lengthDataBits % TWENTYFOURBITGROUP;
				int numberTriplets = lengthDataBits / TWENTYFOURBITGROUP;
				int numberQuartet = fewerThan24bits != 0 ? numberTriplets + 1
						: numberTriplets;
				char encodedData[] = null;

				encodedData = new char[numberQuartet * 4];

				byte k = 0, l = 0, b1 = 0, b2 = 0, b3 = 0;

				int encodedIndex = 0;
				int dataIndex = 0;

				for (int i = 0; i < numberTriplets; i++) {
					b1 = binaryData[dataIndex++];
					b2 = binaryData[dataIndex++];
					b3 = binaryData[dataIndex++];

					l = (byte) (b2 & 0x0f);
					k = (byte) (b1 & 0x03);

					byte val1 = ((b1 & SIGN) == 0) ? (byte) (b1 >> 2)
							: (byte) ((b1) >> 2 ^ 0xc0);
					byte val2 = ((b2 & SIGN) == 0) ? (byte) (b2 >> 4)
							: (byte) ((b2) >> 4 ^ 0xf0);
					byte val3 = ((b3 & SIGN) == 0) ? (byte) (b3 >> 6)
							: (byte) ((b3) >> 6 ^ 0xfc);

					encodedData[encodedIndex++] = lookUpBase64Alphabet[val1];
					encodedData[encodedIndex++] = lookUpBase64Alphabet[val2 | (k << 4)];
					encodedData[encodedIndex++] = lookUpBase64Alphabet[(l << 2) | val3];
					encodedData[encodedIndex++] = lookUpBase64Alphabet[b3 & 0x3f];
				}

				// form integral number of 6-bit groups
				if (fewerThan24bits == EIGHTBIT) {
					b1 = binaryData[dataIndex];
					k = (byte) (b1 & 0x03);

					byte val1 = ((b1 & SIGN) == 0) ? (byte) (b1 >> 2)
							: (byte) ((b1) >> 2 ^ 0xc0);
					encodedData[encodedIndex++] = lookUpBase64Alphabet[val1];
					encodedData[encodedIndex++] = lookUpBase64Alphabet[k << 4];
					encodedData[encodedIndex++] = PAD;
					encodedData[encodedIndex++] = PAD;
				} else if (fewerThan24bits == SIXTEENBIT) {
					b1 = binaryData[dataIndex];
					b2 = binaryData[dataIndex + 1];
					l = (byte) (b2 & 0x0f);
					k = (byte) (b1 & 0x03);

					byte val1 = ((b1 & SIGN) == 0) ? (byte) (b1 >> 2)
							: (byte) ((b1) >> 2 ^ 0xc0);
					byte val2 = ((b2 & SIGN) == 0) ? (byte) (b2 >> 4)
							: (byte) ((b2) >> 4 ^ 0xf0);

					encodedData[encodedIndex++] = lookUpBase64Alphabet[val1];
					encodedData[encodedIndex++] = lookUpBase64Alphabet[val2 | (k << 4)];
					encodedData[encodedIndex++] = lookUpBase64Alphabet[l << 2];
					encodedData[encodedIndex++] = PAD;
				}

				return new String(encodedData);
			}

			/**
			 * Decodes Base64 data into octects
			 *
			 * @param encoded
			 *            string containing Base64 data
			 * @return Array containind decoded data.
			 */
			public static byte[] decode(String encoded) {

				if (encoded == null) {
					return null;
				}

				char[] base64Data = encoded.toCharArray();
				// remove white spaces
				int len = removeWhiteSpace(base64Data);

				if (len % FOURBYTE != 0) {
					return null;// should be divisible by four
				}

				int numberQuadruple = (len / FOURBYTE);

				if (numberQuadruple == 0) {
					return new byte[0];
				}

				byte decodedData[] = null;
				byte b1 = 0, b2 = 0, b3 = 0, b4 = 0;
				char d1 = 0, d2 = 0, d3 = 0, d4 = 0;

				int i = 0;
				int encodedIndex = 0;
				int dataIndex = 0;
				decodedData = new byte[(numberQuadruple) * 3];

				for (; i < numberQuadruple - 1; i++) {

					if (!isData((d1 = base64Data[dataIndex++]))
							|| !isData((d2 = base64Data[dataIndex++]))
							|| !isData((d3 = base64Data[dataIndex++]))
							|| !isData((d4 = base64Data[dataIndex++]))) {
						return null;
					}// if found "no data" just return null

					b1 = base64Alphabet[d1];
					b2 = base64Alphabet[d2];
					b3 = base64Alphabet[d3];
					b4 = base64Alphabet[d4];

					decodedData[encodedIndex++] = (byte) (b1 << 2 | b2 >> 4);
					decodedData[encodedIndex++] = (byte) (((b2 & 0xf) << 4) | ((b3 >> 2) & 0xf));
					decodedData[encodedIndex++] = (byte) (b3 << 6 | b4);
				}

				if (!isData((d1 = base64Data[dataIndex++]))
						|| !isData((d2 = base64Data[dataIndex++]))) {
					return null;// if found "no data" just return null
				}

				b1 = base64Alphabet[d1];
				b2 = base64Alphabet[d2];

				d3 = base64Data[dataIndex++];
				d4 = base64Data[dataIndex++];
				if (!isData((d3)) || !isData((d4))) {// Check if they are PAD characters
					if (isPad(d3) && isPad(d4)) {
						if ((b2 & 0xf) != 0)// last 4 bits should be zero
						{
							return null;
						}
						byte[] tmp = new byte[i * 3 + 1];
						System.arraycopy(decodedData, 0, tmp, 0, i * 3);
						tmp[encodedIndex] = (byte) (b1 << 2 | b2 >> 4);
						return tmp;
					} else if (!isPad(d3) && isPad(d4)) {
						b3 = base64Alphabet[d3];
						if ((b3 & 0x3) != 0)// last 2 bits should be zero
						{
							return null;
						}
						byte[] tmp = new byte[i * 3 + 2];
						System.arraycopy(decodedData, 0, tmp, 0, i * 3);
						tmp[encodedIndex++] = (byte) (b1 << 2 | b2 >> 4);
						tmp[encodedIndex] = (byte) (((b2 & 0xf) << 4) | ((b3 >> 2) & 0xf));
						return tmp;
					} else {
						return null;
					}
				} else { // No PAD e.g 3cQl
					b3 = base64Alphabet[d3];
					b4 = base64Alphabet[d4];
					decodedData[encodedIndex++] = (byte) (b1 << 2 | b2 >> 4);
					decodedData[encodedIndex++] = (byte) (((b2 & 0xf) << 4) | ((b3 >> 2) & 0xf));
					decodedData[encodedIndex++] = (byte) (b3 << 6 | b4);

				}

				return decodedData;
			}

			/**
			 * remove WhiteSpace from MIME containing encoded Base64 data.
			 *
			 * @param data
			 *            the byte array of base64 data (with WS)
			 * @return the new length
			 */
			private static int removeWhiteSpace(char[] data) {
				if (data == null) {
					return 0;
				}

				// count characters that's not whitespace
				int newSize = 0;
				int len = data.length;
				for (int i = 0; i < len; i++) {
					if (!isWhiteSpace(data[i])) {
						data[newSize++] = data[i];
					}
				}
				return newSize;
			}
		}


		package com.***.utils;

		import android.util.Log;

		import com.alibaba.fastjson.JSON;
		import com.syyj.javabean.AlipayBean;

		import org.json.JSONObject;

		import java.io.UnsupportedEncodingException;
		import java.net.URLEncoder;
		import java.text.SimpleDateFormat;
		import java.util.ArrayList;
		import java.util.Collections;
		import java.util.Date;
		import java.util.HashMap;
		import java.util.List;
		import java.util.Locale;
		import java.util.Map;
		import java.util.Random;


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

				Log.d("OrderInfoUtil2_0", "=======biz_content_json=======" + JSON.toJSONString(alipayBean.getBit_content_json()));

				keyValues.put("biz_content", alipayBean.getBit_content_json());

				keyValues.put("charset", alipayBean.getCharset());

				keyValues.put("method", alipayBean.getMethod());

				keyValues.put("sign_type", alipayBean.getSign_type());

				Log.d("OrderInfoUtil2_0", "===========curDate=======" + alipayBean.getTimestamp());
				keyValues.put("timestamp", alipayBean.getTimestamp());
		//
				keyValues.put("version", alipayBean.getVersion());

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

				Log.d("OrderInfoUtil2_0", "最终签名为:===sign=" + encodedSign);

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



		package com.***.utils;


		import java.util.Map;

		import android.text.TextUtils;

		public class PayResult {
				private String resultStatus;
				private String result;
				private String memo;

				public PayResult(Map<String, String> rawResult) {
						if (rawResult == null) {
							  return;
						}

						for (String key : rawResult.keySet()) {
							  if (TextUtils.equals(key, "resultStatus")) {
							      resultStatus = rawResult.get(key);
							  } else if (TextUtils.equals(key, "result")) {
							      result = rawResult.get(key);
							  } else if (TextUtils.equals(key, "memo")) {
							      memo = rawResult.get(key);
							  }
						}
				}

				@Override
				public String toString() {
						return "resultStatus={" + resultStatus + "};memo={" + memo
							      + "};result={" + result + "}";
				}

				/**
				 * @return the resultStatus
				 */
				public String getResultStatus() {
						return resultStatus;
				}

				/**
				 * @return the memo
				 */
				public String getMemo() {
						return memo;
				}

				/**
				 * @return the result
				 */
				public String getResult() {
						return result;
				}
		}


		package com.***.utils;

		import java.security.KeyFactory;
		import java.security.PrivateKey;
		import java.security.spec.PKCS8EncodedKeySpec;

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




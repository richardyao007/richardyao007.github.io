---
layout: post
title:  "[android] android使用umeng分享"
date:   2017-05-02 09:14:49 +0800
category: android
---

		微信支付包会和umeng分享包冲突，删除掉微信支付包就可以了libammsdk.jar

		/**********************************配置部分AndroidManifest.xml************************************/

    <!--添加友盟appkey-->
    <meta-data
        android:name="UMENG_APPKEY"
        android:value="你申请的umeng的appkey" >
    </meta-data>

    <!--新浪-->
    <activity
        android:name=".WBShareActivity"
        android:configChanges="keyboardHidden|orientation"
        android:screenOrientation="portrait" >
        <intent-filter>
            <action android:name="com.sina.weibo.sdk.action.ACTION_SDK_REQ_ACTIVITY" />
            <category android:name="android.intent.category.DEFAULT" />
        </intent-filter>
    </activity>
    <activity
        android:name="com.sina.weibo.sdk.component.WeiboSdkBrowser"
        android:configChanges="keyboardHidden|orientation"
        android:windowSoftInputMode="adjustResize"
        android:exported="false" >
    </activity>
    <service android:name="com.sina.weibo.sdk.net.DownloadService"
        android:exported="false"></service>

    <!--微信-->
    <activity
        android:name=".wxapi.WXEntryActivity"
        android:configChanges="keyboardHidden|orientation|screenSize"
        android:exported="true"
        android:screenOrientation="portrait"
        android:theme="@android:style/Theme.Translucent.NoTitleBar" />
		application标签添加android:name=".App"属性

    //完成App.java
		package com.****;

		import android.app.Activity;
		import android.app.Application;
		import android.os.Bundle;

		import com.umeng.socialize.Config;
		import com.umeng.socialize.PlatformConfig;
		import com.umeng.socialize.UMShareAPI;
		import com.umeng.socialize.common.QueuedWork;


		public class App extends Application {

				@Override
				public void onCreate() {

				    super.onCreate();
				    //开启debug模式，方便定位错误，具体错误检查方式可以查看http://dev.umeng.com/social/android/quick-integration的报错必看，正式发布，请关闭该模式
				    Config.DEBUG = true;
				    QueuedWork.isUseThreadPool = false;
				    UMShareAPI.get(this);
				}

				//各个平台的配置，建议放在全局Application或者程序入口
				{
				    PlatformConfig.setWeixin("wx07db41d675c7396c", "31cdc662cac10fe53f64356af9b6c32a");
				    //豆瓣RENREN平台目前只能在服务器端配置
				    PlatformConfig.setSinaWeibo("3921700954", "04b48b094faeb16683c32669824ebdad","http://sns.whalecloud.com");
						//        PlatformConfig.setYixin("yxc0614e80c9304c11b0391514d09f13bf");
						//        PlatformConfig.setQQZone("100424468", "c7394704798a158208a74ab60104f0ba");
						//        PlatformConfig.setTwitter("3aIN7fuF685MuZ7jtXkQxalyi", "MK6FEYG63eWcpDFgRYw4w9puJhzDl0tyuqWjZ3M7XJuuG7mMbO");
						//        PlatformConfig.setAlipay("2015111700822536");
						//        PlatformConfig.setLaiwang("laiwangd497e70d4", "d497e70d4c3e4efeab1381476bac4c5e");
						//        PlatformConfig.setPinterest("1439206");
						//        PlatformConfig.setKakao("e4f60e065048eb031e235c806b31c70f");
						//        PlatformConfig.setDing("dingoalmlnohc0wggfedpk");
						//        PlatformConfig.setVKontakte("5764965","5My6SNliAaLxEm3Lyd9J");
						//        PlatformConfig.setDropbox("oz8v5apet3arcdy","h7p2pjbzkkxt02a");

				}
		}


		/***********************************准备好分享所需的activity************************************/
    //新浪分享activity

		package com.******;//import com.umeng.socialize.media.WBShareCallBackActivity;

		import com.umeng.socialize.media.WBShareCallBackActivity;


		public class WBShareActivity extends WBShareCallBackActivity {
		}


    //微信分享activity,这块一定要注意要放在com.***.wxapi包下
		package com.****.wxapi;


		//import com.umeng.weixin.callback.WXCallbackActivity;

		import com.umeng.socialize.weixin.view.WXCallbackActivity;

		public class WXEntryActivity extends WXCallbackActivity {



		}

		/***********************分享按钮点击事件，分享开始, 为需要分享的按钮添加一个onclick事件，id为fenxiangBtn***********/


    UMShareListener umShareListener = new UMShareListener() {
        @Override
        public void onStart(SHARE_MEDIA platform) {
        }

        @Override
        public void onResult(SHARE_MEDIA platform) {
            Toast.makeText(MineActivity.this, "分享成功.", Toast.LENGTH_LONG).show();
        }

        @Override
        public void onError(SHARE_MEDIA platform, Throwable t) {
        }

        @Override
        public void onCancel(SHARE_MEDIA platform) {
            Toast.makeText(MineActivity.this, "取消分享.", Toast.LENGTH_LONG).show();
        }
    };


    public void fenxiangClick(View view){
        switch (view.getId()) {
            case R.id.fenxiangBtn:

                UMWeb web = new UMWeb("分享出去之后，点击所跳转的地址");
                web.setTitle("分享标题");//标题
                web.setThumb(new UMImage(MineActivity.this, R.mipmap.icon));  //缩略图
                web.setDescription("分享文字描述");//描述

                //打开分享面板
                new ShareAction(MineActivity.this).withText("分享文字描述")
                        .withMedia(web)
												//分享面板中显示分享到微信朋友圈，分享给微信好友，分享到新浪微搏
                        .setDisplayList(SHARE_MEDIA.SINA,SHARE_MEDIA.WEIXIN_CIRCLE,SHARE_MEDIA.WEIXIN)
                        .setCallback(umShareListener).open();
                break;
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        UMShareAPI.get(this).onActivityResult(requestCode, resultCode, data);

    }

    /**
     * 内存泄漏
     */
    @Override
    protected void onDestroy() {
        super.onDestroy();
        UMShareAPI.get(this).release();
    }

    /**
     * qq微信新浪授权防杀死
     * @param outState
     */
		@Override
		protected void onSaveInstanceState(Bundle outState) {
				super.onSaveInstanceState(outState);
				UMShareAPI.get(this).onSaveInstanceState(outState);
		}


		/*******************res显示面板********************/
		使用的官网提供的面板socialize_share_menu_item.xml，umeng_socialize_oauth_dialog.xml





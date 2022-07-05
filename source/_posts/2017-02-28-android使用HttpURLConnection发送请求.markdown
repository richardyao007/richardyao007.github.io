---
layout: post
title:  "[android] 使用HttpURLConnection发送请求"
date:   2017-02-28 09:14:49 +0800
category: android
---


android部分, 需要使用URLEncoder.encode单独对中文参数部分进行编码(URLDecoder.decode(name, "UTF-8");   可以将url中的编码转译)

    public String getCityIdByName() {
        Log.d(TAG, "方法==getCityIdByName===cityName是===" + cityName);

        //在子线程中操作网络请求
        new Thread(new Runnable() {
            @Override
            public void run() {
                //urlConnection请求服务器，验证
                try {
                    //1：url对象

                    URL url = new URL(PageUrls.SERVER_URL + "/interface/cities/get_city_id_by_name?name=" + URLEncoder.encode(cityName));
                    Log.d(TAG, "==========================url=" + url);
                    //2;url.openconnection
                    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                    //3
                    conn.setRequestMethod("GET");
                    conn.setConnectTimeout(10 * 1000);
                    //4
                    int code = conn.getResponseCode();
                    Log.d(TAG, "=====code====" + code);
                    if (code == 200) {
                        InputStream inputStream = conn.getInputStream();
                        byte[] result = HttpURLConnHelper.streamToByte(new BufferedInputStream(inputStream));
                        Log.d(TAG, "=====================服务器返回的信息：：" + result);


                        JSONObject obj1 = new JSONObject(new String(result, "utf-8"));
                        Log.d(TAG, "处理后的返回结果为===" + obj1);

                        Message message = Message.obtain();
                        message.what = 5;
                        message.obj = obj1.getString("city_id");
                        handler.sendMessage(message);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }).start();


        return cityId;
    }







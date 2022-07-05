---
layout: post
title:  "[android] 对于webview中type为file无法选择文件以及上传"
date:   2017-03-01 09:14:49 +0800
category: android
---


android部分， 通过setWebChromeClient实现文件选择：

        WebSettings settings = webview.getSettings();
        settings.setUseWideViewPort(true);
        settings.setLoadWithOverviewMode(true);
        settings.setJavaScriptEnabled(true);
        webview.setWebChromeClient(new WebChromeClient() {

            // For Android < 3.0
            public void openFileChooser(ValueCallback<Uri> valueCallback) {
                uploadMessage = valueCallback;
                openImageChooserActivity();
            }

            // For Android  >= 3.0
            public void openFileChooser(ValueCallback valueCallback, String acceptType) {
                uploadMessage = valueCallback;
                openImageChooserActivity();
            }

            //For Android  >= 4.1
            public void openFileChooser(ValueCallback<Uri> valueCallback, String acceptType, String capture) {
                uploadMessage = valueCallback;
                openImageChooserActivity();
            }

            // For Android >= 5.0
            @Override
            public boolean onShowFileChooser(WebView webView, ValueCallback<Uri[]> filePathCallback, WebChromeClient.FileChooserParams fileChooserParams) {
                uploadMessageAboveL = filePathCallback;
                openImageChooserActivity();
                return true;
            }
        });



				private void openImageChooserActivity() {
				    Intent i = new Intent(Intent.ACTION_GET_CONTENT);
				    i.addCategory(Intent.CATEGORY_OPENABLE);
				    i.setType("image/*");
				    startActivityForResult(Intent.createChooser(i, "Image Chooser"), FILE_CHOOSER_RESULT_CODE);
				}

				@Override
				protected void onActivityResult(int requestCode, int resultCode, Intent data) {
				    super.onActivityResult(requestCode, resultCode, data);
				    if (requestCode == FILE_CHOOSER_RESULT_CODE) {
				        if (null == uploadMessage && null == uploadMessageAboveL) return;
				        Uri result = data == null || resultCode != RESULT_OK ? null : data.getData();
				        if (uploadMessageAboveL != null) {
				            onActivityResultAboveL(requestCode, resultCode, data);
				        } else if (uploadMessage != null) {
				            uploadMessage.onReceiveValue(result);
				            uploadMessage = null;
				        }
				    }
				}

				@TargetApi(Build.VERSION_CODES.LOLLIPOP)
				private void onActivityResultAboveL(int requestCode, int resultCode, Intent intent) {
				    if (requestCode != FILE_CHOOSER_RESULT_CODE || uploadMessageAboveL == null)
				        return;
				    Uri[] results = null;
				    if (resultCode == Activity.RESULT_OK) {
				        if (intent != null) {
				            String dataString = intent.getDataString();
				            ClipData clipData = intent.getClipData();
				            if (clipData != null) {
				                results = new Uri[clipData.getItemCount()];
				                for (int i = 0; i < clipData.getItemCount(); i++) {
				                    ClipData.Item item = clipData.getItemAt(i);
				                    results[i] = item.getUri();
				                }
				            }
				            if (dataString != null)
				                results = new Uri[]{Uri.parse(dataString)};
				        }
				    }
				    uploadMessageAboveL.onReceiveValue(results);
				    uploadMessageAboveL = null;
				}


webview部分：

        <input @change="change_icon" type="file" id="file-input" style="width: 20%;
          float: right;
          opacity: 0;
          height: 154%;
          margin-left: 5%;
          border-radius: 45px;
          margin-top: -6%;" />


				 change_icon (e) {
						console.log('进入了change_icon----------')
						console.info('change icon')
						var files = e.target.files || e.dataTransfer.files;
						console.log('--------------files.length==' + files.length)
						if (!files.length)
							return;
						var reader = new FileReader();
						var vm = this
						reader.onload = (e) => {
							this.$http.post(
							  'api/interface/users/update_user_icon', {
							     icon: e.target.result,
							    //icon: data,
							    id: this.$store.state.userInfo.id,
							}).then((response) => {
							  console.log('=====上传成功了=====')
							  console.log(response.body)
							  vm.icon = response.body.icon
							}, (error) => {
							  console.error(error)
							  console.log('=====上传失败了=====')
							});
						};
						reader.readAsDataURL(files[0]);
				 }







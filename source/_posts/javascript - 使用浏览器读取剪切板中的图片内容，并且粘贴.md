---
title: javascript - 使用浏览器读取剪切板中的图片内容，并且粘贴到对应的HTML编辑器中
date: 2021-08-12
---
参考：https://stackoverflow.com/questions/60503912/get-image-using-paste-from-the-browser

``` bash
$ // 1. 必须使用 onpaste方法。不能使用 click的方式来调用
document.onpaste = function(pasteEvent) {
  var item = pasteEvent.clipboardData.items[0];

  if (item.type.indexOf("image") === 0) {
    var blob = item.getAsFile();

    var reader = new FileReader();

    // 3. 记得要定义好 onload方法
    reader.onload = function(event) {
      // 4. 就可以看到图片的内容了。这个是最最重要的。 
      console.info('==',event.target.result)
      // 接下来可以把这个图片的内容通过SDK上传到 CDN服务器上，并且在本地进行回显。 
      $('#image_preview').html("<img src=" + event.target.result +" />")
    };

    // 2. 使用这个方法
    reader.readAsDataURL(blob);
  }
}
```

---
layout: post
title:  "[php] laravel中使用ckeditor+ckfinder实现图片上传等功能"
date:   2022-03-19 09:14:49 +0800
category: laravel ckeditor ckfinder
---




        ckeditor部分：

        在http://ckeditor.com下载最新版本ckeditor，然后将文件包放在项目根目录下。

        访问以下地址可以测试，是否安装成功：
        http://www.example.com/ckeditor/samples/index.htmlz
        真正实现的项目中可以删掉samples相关。



        ckfinder部分：

        1. composer require ckfinder/ckfinder-laravel-package

        2. php artisan ckfinder:download

        3. php artisan vendor:publish --tag=ckfinder-assets --tag=ckfinder-config

        php artisan vendor:publish --tag=ckfinder-views
        php artisan vendor:publish --tag=ckfinder
        4. 创建上传文件目录，并且修改目录权限：

        mkdir -m 777 public/userfiles
        5. 修改Middleware

        // app/Http/Middleware/EncryptCookies.php

        namespace App\Http\Middleware;

        use Illuminate\Cookie\Middleware\EncryptCookies as Middleware;

        class EncryptCookies extends Middleware
        {
            /**
            * The names of the cookies that should not be encrypted.
            *
            * @var array
            */
            protected $except = [
                'ckCsrfToken',
                // ...
            ];
        }
        // app/Http/Middleware/VerifyCsrfToken.php

        namespace App\Http\Middleware;

        use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken as Middleware;

        class VerifyCsrfToken extends Middleware
        {
            /**
            * The URIs that should be excluded from CSRF verification.
            *
            * @var array
            */
            protected $except = [
                'ckfinder/*',
                // ...
            ];
        }
        新建Middleware

        php artisan make:middleware CustomCKFinderAuth
        public function handle(Request $request, Closure $next)
        {
            config(['ckfinder.authentication' => function() {
                return true;
            }]);
            return $next($request);
        }
        修改`config/ckfinder.php`

        $config['authentication'] = '\App\Http\Middleware\CustomCKFinderAuth';
        $config['csrfProtection'] = false;


        routes/web.php添加下面两个路由

        Route::any('/ckfinder/connector', 'App\Http\Controllers\CKFinderController@requestAction')
            ->name('ckfinder_connector');

        Route::any('/ckfinder/browser', 'App\Http\Controllers\CKFinderController@browserAction')
            ->name('ckfinder_browser');
        把vendor/ckfinder/ckfinder-laravel-package/src/Controller/CKFinderController.php， 复制到App/Http/Controllers下，记得修改namespace。

        把vendor/ckfinder/ckfinder-laravel-package/src/CKFinderMiddleware.php

        /复制到App/Http/Middleware下，记得修改namespace。



        记得修改views/ckfinder中browser.blade.php的title等，改成你自己的信息。





        页面调用：

        引入ckeditor， introduction_detail为你的页面textarea的name

        CKEDITOR.replace('introduction_detail', {
            language: 'ja',  //语言设置
            filebrowserBrowseUrl: "{{route('ckfinder_browser')}}",
            filebrowserUploadUrl: "{{route('ckfinder_connector')}}?command=QuickUpload&type=Files"  //参数不能去掉哦
        });


        ckfinder在views/setup.blade.php中有引用，所以这里不需要再次引用了。






    
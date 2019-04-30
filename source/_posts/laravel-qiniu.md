---
title: Laravel 简单使用七牛云服务
date: 2015-10-04 21:30:41
updated: 2015-10-04 21:56:13
tags: [Laravel, Qiniu]
---

## 前言

路漫漫其修远兮，吾将上下而求索。学习 Laravel 之初觉得所有东西都很厉害的样子，现在看来就是很厉害啊！最近在写一个项目上传的模块，要上传图片到七牛云，昨天看了一下午七牛云官方的文档感觉还是迷迷糊糊的，今天尝试着写一写感觉满足我的要求还是蛮简单的，于是赶紧记录一下，每一篇博客都将是我进步的基石。

<!-- more -->

## 安装七牛云 SDK

``` bash
$ composer require qiniu/php-sdk
```

## 获取密钥

首先到[七牛云的官网](http://www.qiniu.com/)注册账号登陆后，账号->密钥->创建新密钥，然后新建一个空间，获取七牛域名。

最后将这些信息写到配置文件中:

```
QINIU_BUCKET=stu2e   //刚刚创建的空间名称，用来保存图片
QINIU_ACCESSKEY=ja_fS4iONGxJgX7h11oxmA0-KhJfrUmHkSMEb_7s
QINIU_SECRETKEY=aO36g6wnLyItch6jgIwglJR17TsR0IlcO5beooxt   // AK 和 SK 用来鉴权
QINIU_DOMAIN=7xn855.com1.z0.glb.clouddn.com   //图片上传成功后会返回一个 Key 值，domain/key 就是上传的资源的路径
```

## SDK 使用

为了方便使用七牛云服务，于是我将它封装成一个服务，顺便复习以下 Laravel 的 Service 和 Facade 模式。具体的流程就不写了，直接写方法的实现吧~

``` php
require_once base_path().'/vendor/autoload.php';  
//base_path()获取 laravel 项目的根目录，引入 SDK

use Qiniu\Auth;
use Qiniu\Storage\UploadManager;

class QiniuService
{
    protected $domain = null;
    protected $bucket = null;
    protected $accessKey = null;
    protected $secretKey = null;
    protected $auth;

    public function __construct()
    {
        $this->domain = env('QINIU_DOMAIN');
        $this->bucket = env('QINIU_BUCKET');
        $this->accessKey = env('QINIU_ACCESSKEY');
        $this->secretKey = env('QINIU_SECRETKEY');

        $this->auth = new Auth($this->accessKey, $this->secretKey); //鉴权
    }

    public function upLoad($filePath)
    {
        $token = $this->getToken();   
        //上传时会对比上传表单中 post 过来的 token 是否正确
        $uploadMgr = new UploadManager();
        list($ret, $err) = $uploadMgr->putFile($token, null, $filePath); 
        //第二个参数是保存到空间的图片的名字，默认就好了。
        if ($err !== null) {
            return $err;
        } else {
            return $ret;
        }
    }
    
    public function getDomain()
    {
        return $this->domain;
    }

    public function getToken()
    {
        return $this->auth->uploadToken($this->bucket);  
        //給上传表单生成上传  token
    }
}
```

## 路由

``` php
use App\Http\Requests;
use Illuminate\Http\Request;

Route::get('/test', function(){
    $token = Qiniu::getToken();
    return view('test')->with('token', $token);
});
    
Route::post('/test',function(Request $request){
    $payload = $request->all();
    $result = Qiniu::upLoad($payload['file']);
    return Qiniu::getDomain().'/'.$result['key'];
});
```

## HTML 页面

``` html
@extends('app')

@section('content')
<div class="container">
    <form method="post" action="{{ url('test') }}" enctype="multipart/form-data">
        <input type="hidden" name="_token" value="{{ csrf_token() }}">
        <input name="token" type="hidden" value="{{ $token }}">
        <input name="file" type="file" />
        <input type="submit" value="上传"/>
    </form>
</div>
@endsection
```

关于这个 token 问题，Laravel 默认开启了csrf防御机制，所以上传表单应该包括两个 token 。
ok，简单的上传图片就完成了，打开页面，选择一张图片，上传后就会返回该图片在七牛云空间里的资源路径，拷贝到浏览器地址栏，进入就能看到图片了。

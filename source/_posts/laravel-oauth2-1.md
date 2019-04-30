---
title: Laravel OAuth2 (一) ---简单获取用户信息
date: 2015-09-29 18:00:05
updated: 2015-09-29 18:44:11
tags: Laravel
---

## 前言

本来要求是使用微信进行第三方登陆，所以想着先用 github 测试成功再用微信测试，可是最近拖了好久都还没申请好微信开放平台的 AppID ，所以就只写 github 的第三方登陆吧，估计微信的实现也差不多~

<!-- more -->

## 关于OAuth2

关于OAuth2的理解，推荐大家先去看一下阮一峰的文章[理解OAuth 2.0](http://www.ruanyifeng.com/blog/2014/05/oauth_2_0.html)，看完这个之后相信就能对 OAuth2 有了一定的了解，因为在 Laravel 里面很多东西都已经封装好了，如果只是单纯的实现功能感觉并不能学到多少东西，Laravel 使用的授权模式是授权码模式。从 Laravel 的[官方文档](http://www.golaravel.com/laravel/docs/5.1/authentication/)来看，其实几行代码就能实现第三方登陆的功能，但是不一定能满足我们的项目需求。这篇文章也简单记录了博主在学着使用 Laravel 的 **Facaces** 和 **Service** 模式。

## 准备工作

### github

首先去 github 上面注册一个 Application :

Personal settings->Applications->Developer applications->Register new application 填写相关信息，然后就可以得到一个 Client ID 和 Client Secret :

![](https://s1.ax2x.com/2018/03/14/Ltrha.jpg)

好，到此为止，github上面的准备工作就完成了。

---

## 配置

首先在命令行中执行以下命令安装插件：

``` bash
$ composer require laravel/socialite
```

然后在 **config/app.php** 文件中注册服务提供者和添加 Socialite 的 facade ：

``` ini
'providers' => [
    // Other service providers...

    Laravel\Socialite\SocialiteServiceProvider::class,
],

'aliases' => [
    // Other facades...
    'Socialite' => Laravel\Socialite\Facades\Socialite::class,
],
```

然后我们就要到`services.php`中去配置 github 的 Client ID 和 Client Secret：

``` ini
'github' => [    
        'client_id' => env('GITHUB_KEY'),
        'client_secret' => env('GITHUB_SECRET'),
        'redirect' => env('GITHUB_REDIRECT_URI'),
    ],
```

在.env文件中添加以下信息(就是在github上面注册的信息)：

```
GITHUB_KEY=02e00704589a50f7f58d
GITHUB_SECRET=5793aefaa0ee643d8d78b3cf4dc7101a477fd406
GITHUB_REDIRECT_URI=http://suip.app/login/github/callback
```

上面回调的URL一定要和 github 上面填写的一样，不然 github 的服务器检查到不一样会拒绝服务。

## 开始使用

### 添加路由

``` php
Route::get('login/{provider}', 'Auth\AuthController@redirectToProvider');
Route::get('login/{provider}/callback', 'Autu\AuthController@handleProviderCallback');
```

### 控制器

到 **Auth\AuthController** 控制器中实现 redirectToProvider 和 handleProviderCallback 函数：

``` php   
public function redirectToProvider()
{
    return Socialite::driver('github')->redirect();
}

public function handleProviderCallback()
{
    $user = Socialite::driver('github')->user();
    dd($user);
}
```

ok，现在访问 **suip.app/login/github** 就会重定向到 github 认证的界面，确认授权后就会重定向到 **suip.app/login/github/callback** ,由于在控制器中 dd 了 $user ,所以就能直接显示用户信息了:

![](https://s1.ax2x.com/2018/03/14/LtLDS.jpg)

到此为止获取用户信息就结束了